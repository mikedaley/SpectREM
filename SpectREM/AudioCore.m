//
//  AudioCore.m
//  ZXRetroEmulator
//
//  Created by Mike Daley on 03/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AudioCore.h"
#import "ZXSpectrum.h"
#import "AudioQueue.h"

#pragma mark - Private interface

@interface AudioCore ()
{
@public
    int             samplesPerFrame;
    UInt32          formatBytesPerFrame;
    UInt32          formatChannelsPerFrame;
    UInt32          formatBitsPerChannel;
    UInt32          formatFramesPerPacket;
    UInt32          formatBytesPerPacket;
    
    
    unsigned int    random;
    unsigned int    AYOutput;
    unsigned int    AYChannelCount[3];
    unsigned int    noiseCount;
    unsigned int    envelopeCount;
    int             envelopeStep;
    unsigned char	AYRegisters[eAY_MAX_REGISTERS];
    unsigned char	currentAYRegister;
    signed short	AYVolumes[16];
    unsigned int	channelOutputCount;
    signed int		channelOutput[3];
    bool			envelopeHolding;
    bool			envelopeHold;
    bool			envelopeAlt;
    bool			envelope;
    unsigned int	attackEndVol;
}

// Reference to the machine using the audio core
@property (weak) ZXSpectrum *machine;

// reference to the emulation queue that is being used to drive the emulation
@property (assign) dispatch_queue_t emulationQueue;

// Queue used to control the samples being provided to Core Audio
@property (strong) AudioQueue *queue;

// Properties used to store the CoreAudio graph and nodes, including the high and low pass effects nodes
@property (assign) AUGraph graph;
@property (assign) AUNode outNode;
@property (assign) AUNode converterNode;
@property (assign) AUNode lowPassNode;
@property (assign) AUNode highPassNode;
@property (assign) AudioUnit convert;

// Signature of the CoreAudio render callback. This is called by CoreAudio when it needs more data in its buffer.
// By using AudioQueue we can generate another new frame of data at 50.08 fps making sure that the audio stays in
// sync with the frames.
static OSStatus renderAudio(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData);

@end

#pragma mark - Static

static float fAYVolBase[] = {0.0000f, 0.0137f, 0.0205f, 0.0291f, 0.0423f, 0.0618f, 0.0847f, 0.1369f, 0.1691f, 0.2647f, 0.3527f, 0.4499f, 0.5704f, 0.6873f, 0.8482f, 1.0000f};

#pragma mark - Implementation

@implementation AudioCore

- (void)dealloc
{
    NSLog(@"Deallocating AudioCore");
    CheckError(AUGraphStop(_graph), "AUGraphStop");
    CheckError(AUGraphUninitialize(_graph), "AUGraphUninitilize");
    CheckError(AUGraphClose(_graph), "AUGraphClose");
}

- (instancetype)initWithSampleRate:(int)sampleRate framesPerSecond:(float)fps emulationQueue:queue machine:(ZXSpectrum *)machine
{
    self = [super init];
    if (self)
    {
        _emulationQueue = queue;
        _queue = [AudioQueue queue];
        _machine = machine;
        samplesPerFrame = sampleRate / fps;

        // Generate AY volumes
        for (int i = 0; i < 16; i++)
        {
            AYVolumes[i] = (signed short)(fAYVolBase[i] * 8192);
        }
    
        CheckError(NewAUGraph(&_graph), "NewAUGraph");
        
        // Output Node
        AudioComponentDescription componentDescription;
        componentDescription.componentType = kAudioUnitType_Output;
        componentDescription.componentSubType = kAudioUnitSubType_DefaultOutput;
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        CheckError(AUGraphAddNode(_graph, &componentDescription, &_outNode), "AUGraphAddNode");
        
        // Low pass effect node
        componentDescription.componentType = kAudioUnitType_Effect;
        componentDescription.componentSubType = kAudioUnitSubType_LowPassFilter;
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        CheckError(AUGraphAddNode(_graph, &componentDescription, &_lowPassNode), "AUGraphAddNode");
        
        CheckError(AUGraphConnectNodeInput(_graph, _lowPassNode, 0, _outNode, 0), "AUGraphConnectNodeInput");
        
        // High pass effect node
        componentDescription.componentType = kAudioUnitType_Effect;
        componentDescription.componentSubType = kAudioUnitSubType_HighPassFilter;
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        CheckError(AUGraphAddNode(_graph, &componentDescription, &_highPassNode), "AUGraphAddNode");
        
        CheckError(AUGraphConnectNodeInput(_graph, _highPassNode, 0, _lowPassNode, 0), "AUGraphConnectNodeInput");
        
        // Converter node
        componentDescription.componentType = kAudioUnitType_FormatConverter;
        componentDescription.componentSubType = kAudioUnitSubType_AUConverter;
        componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        CheckError(AUGraphAddNode(_graph, &componentDescription, &_converterNode), "AUGraphAddNode");
        
        CheckError(AUGraphConnectNodeInput(_graph, _converterNode, 0, _highPassNode, 0), "AUGraphConnectNodeInput");
        
        CheckError(AUGraphOpen(_graph), "AUGraphOpen");
        
        // Buffer format
        formatBitsPerChannel = 16;
        formatChannelsPerFrame = 2;
        formatBytesPerFrame = 4;
        formatFramesPerPacket = 1;
        formatBytesPerPacket = 4;

        AudioStreamBasicDescription bufferFormat;
        bufferFormat.mFormatID = kAudioFormatLinearPCM;
        bufferFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian;
        bufferFormat.mSampleRate = sampleRate;
        bufferFormat.mBitsPerChannel = formatBitsPerChannel;
        bufferFormat.mChannelsPerFrame = formatChannelsPerFrame;
        bufferFormat.mBytesPerFrame = formatBytesPerFrame;
        bufferFormat.mFramesPerPacket = formatFramesPerPacket;
        bufferFormat.mBytesPerPacket = formatBytesPerPacket;
        
        CheckError(AUGraphNodeInfo(_graph, _converterNode, NULL, &_convert), "AUGraphNodeInfo");
        CheckError(AudioUnitSetProperty(_convert, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &bufferFormat, sizeof(bufferFormat)), "AudioUnitSetProperty");
        
        // Set the frames per slice property on the converter node
        uint32 framesPerSlice = 882;
        CheckError(AudioUnitSetProperty(_convert, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Input, 0, &framesPerSlice, sizeof(framesPerSlice)), "AudioUnitSetProperty");

        // define the callback for rendering audio
        AURenderCallbackStruct renderCallbackStruct;
        renderCallbackStruct.inputProc = renderAudio;
        renderCallbackStruct.inputProcRefCon = (__bridge void *)self;
        
        // Attach the audio callback to the converterNode
        CheckError(AUGraphSetNodeInputCallback(_graph, _converterNode, 0, &renderCallbackStruct), "AUGraphNodeInputCallback");
        CheckError(AUGraphInitialize(_graph), "AUGraphInitialize");
        CheckError(AUGraphStart(_graph), "AUGraphStart");
        
        // Initial filter settings
        self.lowPassFilter = 3500;
        self.highPassFilter = 1;
        
    }
    return self;
}

- (void)stop
{
    CheckError(AUGraphStop(_graph), "AUGraphStop");
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"soundLowPassFilter"])
    {
        AudioUnit filterUnit;
        AUGraphNodeInfo(_graph, _lowPassNode, NULL, &filterUnit);
        AudioUnitSetParameter(filterUnit, 0, kAudioUnitScope_Global, 0, [change[NSKeyValueChangeNewKey] doubleValue], 0);
    }
    else if ([keyPath isEqualToString:@"soundHighPassFilter"])
    {
        AudioUnit filterUnit;
        AUGraphNodeInfo(_graph, _highPassNode, NULL, &filterUnit);
        AudioUnitSetParameter(filterUnit, 0, kAudioUnitScope_Global, 0, [change[NSKeyValueChangeNewKey] doubleValue], 0);
    }
    else if ([keyPath isEqualToString:@"soundVolume"])
    {
        CheckError(AudioUnitSetParameter (_convert, kHALOutputParam_Volume, kAudioUnitScope_Global, 0, [change[NSKeyValueChangeNewKey] floatValue], 0), "AudioUnitSetProperty");
    }
}

#pragma mark - AY Chip

- (void)setAYRegister:(unsigned char)reg
{
    if (reg < eAY_MAX_REGISTERS)
    {
        currentAYRegister = reg;
    }
}

- (void)writeAYData:(unsigned char)data
{
    switch (currentAYRegister) {
        case eAYREGISTER_A_FINE:
        case eAYREGISTER_B_FINE:
        case eAYREGISTER_C_FINE:
        case eAYREGISTER_ENABLE:
        case eAYREGISTER_E_FINE:
        case eAYREGISTER_E_COARSE:
        case eAYREGISTER_PORT_A:
        case eAYREGISTER_PORT_B:
            break;

        case eAYREGISTER_A_COARSE:
        case eAYREGISTER_B_COARSE:
        case eAYREGISTER_C_COARSE:
            data &= 0x0f;
            break;
            
        case eAYREGISTER_E_SHAPE:
            envelopeHolding = NO;
            envelopeStep = 15;
            data &= 0x0f;
            
            // Set the end volume
            attackEndVol = (data & eENVFLAG_ATTACK) != 0 ? 15 : 0;
            
            // If we are not continuous then we hold but with alternate set if attack = 0
            if ((data & eENVFLAG_CONTINUE) == 0)
            {
                envelopeHold = YES;
                envelopeAlt = (data & eENVFLAG_ATTACK) ? YES: NO;
            }
            else
            {
                envelopeHold = (data & eENVFLAG_HOLD) ? YES : NO;
                envelopeAlt = (data & eENVFLAG_ALTERNATE) ? YES : NO;
            }
            break;
            
        case eAYREGISTER_NOISEPER:
        case eAYREGISTER_A_VOL:
        case eAYREGISTER_B_VOL:
        case eAYREGISTER_C_VOL:
            data &= 0x1f;
            break;
            
        default:
            break;
    }
    
    AYRegisters[ currentAYRegister ] = data;
}

- (unsigned char)readAYData
{
    return AYRegisters[ currentAYRegister ];
}

- (unsigned int)getNoiseFrequency
{
    int freq = AYRegisters[ eAYREGISTER_NOISEPER ];
    
    // A 0 is assumed to be 1
    if (freq == 0)
    {
        freq = 1;
    }
    
    return freq;
}

unsigned int getChannelFrequency(int c, void* ac)
{
    AudioCore *audioCore = (__bridge AudioCore *)ac;
    
    int freq = audioCore->AYRegisters[ (c << 1) + eAYREGISTER_A_FINE ] | (audioCore->AYRegisters[ (c << 1) + eAYREGISTER_A_COARSE] << 8);
    
    if (freq == 0)
    {
        freq = 1;
    }
    
    return freq;
}

unsigned int getEnvelopePeriod(void* ac)
{
    AudioCore *audioCore = (__bridge AudioCore *)ac;
    return (audioCore->AYRegisters[ eAYREGISTER_E_FINE ] | (audioCore->AYRegisters[ eAYREGISTER_E_COARSE] << 8));
}

- (void)updateAY:(int)audioSteps
{
    while (audioSteps != 0)
    {
        // Process the envelope
        if (!envelopeHolding)
        {
            envelopeCount++;
            
            if ( envelopeCount >= getEnvelopePeriod((__bridge void*)self))
            {
                // Go through the step
                envelopeCount = 0;
                envelopeStep--;
                
                // Step on?
                if (envelopeStep < 0)
                {
                    // Reset
                    envelopeStep = 15;
                    
                    // Do we need to flip our attack
                    if ( envelopeAlt )
                    {
                        attackEndVol ^= 15;
                    }
                    
                    // Should we hold here
                    if (envelopeHold)
                    {
                        envelopeHolding = true;
                    }
                }
            }
        }
        
        // Process the noise (only if one is enabled - remember the enable flag is /enable)
        if ((AYRegisters[eAYREGISTER_ENABLE] & 0x38) != 0x38)
        {
            noiseCount++;
            
            if (noiseCount >= [self getNoiseFrequency])
            {
                noiseCount = 0;
                
                // Is the output going to flip
                if (((random & 1) ^ ((random >> 1) & 1)) == 1)
                {
                    // Yes
                    AYOutput ^= (1 << 3);
                }
                
                // Now the doc says 'The Random Number Generator of the 8910 is a 17-bit shift register. The input to the shift register is bit0 XOR bit3 (bit0 is the output)'
                random = (((random & 1) ^ ((random >> 3) & 1)) << 16) | ((random >> 1) & 0x1ffff);
            }
        }
        
        // Process the Tone frequency and mix the final output
        for (int c = 0; c < 3; c++)
        {
            // Update the channel
            AYChannelCount[c] += 2;
            
            // Get the frequency
            if (AYChannelCount[c] >= getChannelFrequency(c, (__bridge void*)self))
            {
                // Reset and flip the output bit
                AYChannelCount[c]  -= getChannelFrequency(c, (__bridge void*)self);
                AYOutput ^= (1 << c);
            }
            
            // If the enable bit is 0 for tone and/or noise then we need to handle the output, docs say disabled output (a 1 bit in the /enable) should write a hi value out
            unsigned int tone_output = ((AYOutput >> c) & 1) | ((AYRegisters[eAYREGISTER_ENABLE] >> c) & 1);
            unsigned int noise_output = ((AYOutput >> 3) & 1) | ((AYRegisters[eAYREGISTER_ENABLE] >> (c + 3)) & 1);
            
            if ((tone_output & noise_output) == 1)
            {
                int vol = AYRegisters[eAYREGISTER_A_VOL + c];
                
                // Fixed or Envelope?
                if ((vol & 0x10) != 0)
                {
                    // This should be the envelope stuff
                    vol = envelopeStep ^ attackEndVol;
                }
                
                // Write out this data
                channelOutput[c] += AYVolumes[vol];
            }
        }
        
        // Mark we have updated the audio some more
        channelOutputCount++;
        
        audioSteps--;
    }
}

- (signed int)getChannel0
{
    return channelOutput[0] / channelOutputCount;
}

- (signed int)getChannel1
{
    return channelOutput[1] / channelOutputCount;
}

- (signed int)getChannel2
{
    return channelOutput[2] / channelOutputCount;
}

//void reset()
//{
//    channelOutput[0] = 0;
//    channelOutput[1] = 0;
//    channelOutput[2] = 0;
//    channelOutputCount = 0;
//}

- (void)reset
{
    channelOutput[0] = 0;
    channelOutput[1] = 0;
    channelOutput[2] = 0;
    channelOutputCount = 0;
}

#pragma mark - Audio Render

static OSStatus renderAudio(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData)
{
    AudioCore *audioCore = (__bridge AudioCore *)inRefCon;
    
    // Grab the buffer that core audio has passed in and reset its contents to 0.
    // The format being used has 4 bytes per frame so multiply inNumberFrames by 4
    int16_t *buffer = ioData->mBuffers[0].mData;
    memset(buffer, 0, inNumberFrames << 2);
    
    // Update the queue with the reset buffer
    [audioCore.queue read:buffer count:(inNumberFrames << 1)];
    
    // Check if we have used a frames worth of buffer storage and if so then its time to generate another frame.
    if ([audioCore.queue used] < (audioCore->samplesPerFrame << 1))
    {
        dispatch_sync(audioCore.emulationQueue, ^
        {
            [audioCore.machine doFrame];
        });
        
        // Populate the audio buffer on the same thread as the Core Audio callback otherwise there are timing
        // problems
        [audioCore.queue write:audioCore.machine.audioBuffer count:(audioCore->samplesPerFrame << 1)];
    }
    
    // Set the size of the buffer to be the number of frames requested by the Core Audio callback. This is
    // multiplied by the number of bytes per frame which is 4.
    ioData->mBuffers[0].mDataByteSize = (inNumberFrames << 2);
    
    return noErr;
    
}

// Routine to help detect and display OSStatus errors generated when using the Core Audio API
// It works out of the error is a C string to be displayed or an integer value. This allows them
// to be logged in a consistent manor.
// Taken from "Learning Core Audio" by Chris Adams and Kevin Avila
static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr)
    {
        return;
    }
    
    char str[20];
    *(UInt32 *) (str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4]))
    {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    }
    else
    {
        sprintf(str, "%d", (int)error);
    }
    
    fprintf(stderr, "[Error] %s (%s)\n", operation, str);
    exit(1);
}

@end
