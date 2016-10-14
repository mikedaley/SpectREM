//
//  AudioCore.m
//  ZXRetroEmulator
//
//  Created by Mike Daley on 03/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AudioCore.h"
#import "ZXSpectrum48.h"
#import "AudioQueue.h"

#pragma mark - Private interface

@interface AudioCore ()

// Reference to the machine using the audio core
@property (strong) ZXSpectrum48 *machine;

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

@end

#pragma mark - C Variables

// Signature of the CoreAudio render callback. This is called by CoreAudio when it needs more data in its buffer.
// By using AudioQueue we can generate another new frame of data at 50.08 fps making sure that the audio stays in
// sync with the frames.
static OSStatus renderAudio(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData);

// Used to store audio values used in both Obj-C and C functions
int         samplesPerFrame;
UInt32      formatBytesPerFrame;
UInt32      formatChannelsPerFrame;
UInt32      formatBitsPerChannel;
UInt32      formatFramesPerPacket;
UInt32      formatBytesPerPacket;

#pragma mark - Implementation

@implementation AudioCore

- (instancetype)initWithSampleRate:(int)sampleRate framesPerSecond:(float)fps emulationQueue:queue machine:(ZXSpectrum48 *)machine
{
    self = [super init];
    if (self)
    {
        _emulationQueue = queue;
        _queue = [AudioQueue queue];
        _machine = machine;
        samplesPerFrame = sampleRate / fps;
        
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
        
        // Set the frames per slice property on the converter node
        AudioUnit convert;
        CheckError(AUGraphNodeInfo(_graph, _converterNode, NULL, &convert), "AUGraphNodeInfo");
        CheckError(AudioUnitSetProperty(convert, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &bufferFormat, sizeof(bufferFormat)), "AudioUnitSetProperty");
        
        uint32 framesPerSlice = 882;
        CheckError(AudioUnitSetProperty(convert, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Input, 0, &framesPerSlice, sizeof(framesPerSlice)), "AudioUnitSetProperty");
        
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

#pragma mark - Setters

- (void)setLowPassFilter:(double)lowPassFilter
{
    _lowPassFilter = lowPassFilter;
    AudioUnit filterUnit;
    AUGraphNodeInfo(_graph, _lowPassNode, NULL, &filterUnit);
    AudioUnitSetParameter(filterUnit, 0, kAudioUnitScope_Global, 0, lowPassFilter, 0);
}

- (void)setHighPassFilter:(double)highPassFilter
{
    _highPassFilter = highPassFilter;
    AudioUnit filterUnit;
    AUGraphNodeInfo(_graph, _highPassNode, NULL, &filterUnit);
    AudioUnitSetParameter(filterUnit, 0, kAudioUnitScope_Global, 0, highPassFilter, 0);
}

#pragma mark - C Functions

static OSStatus renderAudio(void *inRefCon,AudioUnitRenderActionFlags *ioActionFlags,const AudioTimeStamp *inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList *ioData)
{
    AudioCore *audioCore = (__bridge AudioCore *)inRefCon;
    
    // Grab the buffer that core audio has passed in and reset its contents to 0.
    // The format being used has 4 bytes per frame so multiply inNumberFrames by 4
    int16_t *buffer = ioData->mBuffers[0].mData;
    memset(buffer, 0, inNumberFrames << 2);
    
    // Update the queue with the reset buffer
    [audioCore.queue read:buffer count:(inNumberFrames << 1)];
    
    // Check if we have used a frames worth of buffer storage.
    if ([audioCore.queue used] < (samplesPerFrame << 1))
    {
        dispatch_sync(audioCore.emulationQueue, ^
        {
            [audioCore.machine doFrame];
        });
        
        // Populate the audio buffer on the same thread as the Core Audio callback otherwise there are timing
        // problems
        [audioCore.queue write:audioCore.machine.audioBuffer count:(samplesPerFrame << 1)];
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
