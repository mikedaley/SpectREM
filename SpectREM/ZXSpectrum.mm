//
//  ZXSpectrum.m
//  SpectREM
//
//  Created by Mike Daley on 26/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ZXSpectrum.h"
#import "KeyboardMatrix.h"
#import "Z80Core.h"

@interface ZXSpectrum ()

@end

@implementation ZXSpectrum

- (void)dealloc
{
    NSLog(@"Deallocating ZXSpectrum");
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController
{
    if (self == [super init])
    {
        
    }
    return self;
}

- (void)generateFrame
{
    // Implemented in specific machine classes
}

#pragma mark - Binding

- (void)setupObservers
{
    [self addObserver:self.audioCore forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self.audioCore forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self.audioCore forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObservers
{
    [self removeObserver:self.audioCore forKeyPath:@"soundLowPassFilter"];
    [self removeObserver:self.audioCore forKeyPath:@"soundHighPassFilter"];
    [self removeObserver:self.audioCore forKeyPath:@"soundVolume"];
}

#pragma mark -

- (void)start
{
    [self resetFrame];
    [self doFrame];
}

- (void)stop
{
    [self removeObservers];
    [self.audioCore stop];
}

#pragma mark - Reset

- (void)reset
{
    frameCounter = 0;
    [self resetKeyboardMap];
    [self resetSound];
    [self resetFrame];
}

- (void)resetSound
{
    memset(self.audioBuffer, 0, audioBufferSize);
    audioBufferIndex = 0;
    audioTsCounter = 0;
    audioTsStepCounter = 0;
    audioBeeperLeft = 0;
    audioBeeperRight = 0;
    [self.audioCore reset];
}

- (void)resetFrame
{
    // Reset display
    emuDisplayBufferIndex = 0;
    emuDisplayTs = 0;
    
    // Reset audio
    audioBufferIndex = 0;
    audioTsCounter = 0;
    audioTsStepCounter = 0;
}

- (void)doFrame
{
    dispatch_async(self.emulationQueue, ^
    {
       switch (event)
       {
           case eNone:
               break;
               
           case eReset:
               event = eNone;
               [self reset];
               break;
               
           case eSnapshot:
               [self reset];
               [self loadSnapshot];
               event = eNone;
               break;
               
           case eZ80Snapshot:
               [self reset];
               [self loadZ80Snapshot];
               event = eNone;
               break;
               
           default:
               break;
       }
       
       [self resetFrame];
       [self generateFrame];
    });
}

#pragma mark - Audio

void updateAudioWithTStates(int numberTs, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    // Loop over each tState so that the necessary audio samples can be generated
    for(int i = 0; i < numberTs; i++)
    {
        // Grab the current state of the audio ear output
        signed int beeperLevelLeft = (machine->audioEar * cAudioBeeperVolumeMultiplier) * machine.soundVolume;
        signed int beeperLevelRight = beeperLevelLeft;
        double leftMix = 0.5;
        double rightMix = 0.5;
        
        machine->audioAYTStates++;
        if (machine->audioAYTStates >= machine->audioAYTStatesStep)
        {
            [machine.audioCore updateAY:1];
            if (machine.AYChannelA)
            {
                if (machine.AYChannelABalance > 0.5)
                {
                    leftMix = 1.0 - machine.AYChannelABalance;
                    rightMix = machine.AYChannelABalance;
                }
                else if (machine.AYChannelABalance < 0.5)
                {
                    leftMix = 1.0 - (machine.AYChannelABalance * 2);
                    rightMix = 1.0 - (1.0 - machine.AYChannelABalance);
                }
                signed int channelA = [machine.audioCore getChannelA];
                beeperLevelLeft += channelA * leftMix;
                beeperLevelRight += channelA * rightMix;
            }
            if (machine.AYChannelB)
            {
                leftMix = 0.5;
                rightMix = 0.5;
                if (machine.AYChannelBBalance > 0.5)
                {
                    leftMix = 1.0 - machine.AYChannelBBalance;
                    rightMix = machine.AYChannelBBalance;
                }
                else if (machine.AYChannelBBalance < 0.5)
                {
                    leftMix = 1.0 - (machine.AYChannelBBalance * 2);
                    rightMix = 1.0 - (1.0 - machine.AYChannelBBalance);
                }
                signed int channelB = [machine.audioCore getChannelB];
                beeperLevelLeft += channelB * leftMix;
                beeperLevelRight += channelB * rightMix;
            }
            if (machine.AYChannelC)
            {
                leftMix = 0.5;
                rightMix = 0.5;
                if (machine.AYChannelCBalance > 0.5)
                {
                    leftMix = 1.0 - machine.AYChannelCBalance;
                    rightMix = machine.AYChannelCBalance;
                }
                else if (machine.AYChannelCBalance < 0.5)
                {
                    leftMix = 1.0 - (machine.AYChannelCBalance * 2);
                    rightMix = 1.0 - (1.0 - machine.AYChannelCBalance);
                }
                signed int channelC = [machine.audioCore getChannelC];
                beeperLevelLeft += channelC * leftMix;
                beeperLevelRight += channelC * rightMix;
            }
            
            [machine.audioCore endFrame];
            machine->audioAYTStates -= machine->audioAYTStatesStep;
        }
        
        // If we have done more cycles now than the audio step counter, generate a new sample
        if (machine->audioTsCounter++ >= machine->audioTsStepCounter)
        {
            // Quantize the value loaded into the audio buffer e.g. if cycles = 19 and step size is 18.2
            // 0.2 of the beeper value goes into this sample and 0.8 goes into the next sample
            double delta1 = fabs(machine->audioTsStepCounter - (machine->audioTsCounter - 1));
            double delta2 = (1 - delta1);
            
            // Quantize for the current sample
            machine->audioBeeperLeft += beeperLevelLeft * delta1;
            machine->audioBeeperRight += beeperLevelRight * delta1;
            
            // Load the buffer with the sample for both left and right channels
            machine.audioBuffer[ machine->audioBufferIndex++ ] = (signed short)machine->audioBeeperLeft;
            machine.audioBuffer[ machine->audioBufferIndex++ ] = (signed short)machine->audioBeeperRight;
            
            // Quantize for the next sample
            machine->audioBeeperLeft = beeperLevelLeft * delta2;
            machine->audioBeeperRight = beeperLevelRight * delta2;
            
            // Increment the step counter so that the next sample will be taken after another 18.2 T-States
            machine->audioTsStepCounter += machine->audioTsStep;
        }
        else
        {
            machine->audioBeeperLeft += beeperLevelLeft;
            machine->audioBeeperRight += beeperLevelRight;
        }
    }
}

#pragma mark - Display

void updateScreenWithTStates(int numberTs, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    while (numberTs > 0)
    {
        int line = machine->emuDisplayTs / machine->tsPerLine;
        int ts = machine->emuDisplayTs % machine->tsPerLine;
        
        switch (machine->emuDisplayTsTable[line][ts]) {
            case cDisplayRetrace:
                break;
                
            case cDisplayBorder:
                for (int i = 0; i < 8; i++)
                {
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].r;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].g;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].b;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].a;                    
                }
                break;
                
            case cDisplayPaper:
            {
                int y = line - (machine->pxVerticalBlank + machine->pxTopBorder);
                int x = (ts >> 2) - 4;
                
                uint pixelAddress = machine->emuTsLine[y] + x;
                uint attributeAddress = cBitmapSize + ((y >> 3) << 5) + x;
                
                int pixelByte = machine->memory[(machine->displayPage * 16384) + pixelAddress];
                int attributeByte = machine->memory[(machine->displayPage * 16384) + attributeAddress];
                
                // Extract the ink and paper colours from the attribute byte read in
                int ink = (attributeByte & 0x07) + ((attributeByte & 0x40) >> 3);
                int paper = ((attributeByte >> 3) & 0x07) + ((attributeByte & 0x40) >> 3);
                
                // Switch ink and paper if the flash phase has changed
                if ((machine->frameCounter & 16) && (attributeByte & 0x80))
                {
                    int tempPaper = paper;
                    paper = ink;
                    ink = tempPaper;
                }
                
                for (int b = 0x80; b; b >>= 1)
                {
                    if (pixelByte & b) {
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[ink].r;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[ink].g;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[ink].b;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[ink].a;
                    }
                    else
                    {
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[paper].r;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[paper].g;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[paper].b;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[paper].a;
                    }
                }
                break;
            }
                
            default:
                break;
        }
        
        machine->emuDisplayTs += machine->tsPerChar;
        numberTs -= machine->tsPerChar;
    }
}

#pragma mark - Build Display Tables

- (void)buildScreenLineAddressTable
{
    for(int i = 0; i < 3; i++)
    {
        for(int j = 0; j < 8; j++)
        {
            for(int k = 0; k < 8; k++)
            {
                emuTsLine[(i << 6) + (j << 3) + k] = (i << 11) + (j << 5) + (k << 8);
            }
        }
    }
}

- (void)buildDisplayTsTable
{
    for(int line = 0; line < pxVerticalTotal; line++)
    {
        for(int ts = 0 ; ts < tsPerLine; ts++)
        {
            if (line >= 0  && line < pxVerticalBlank)
            {
                emuDisplayTsTable[line][ts] = cDisplayRetrace;
            }
            
            if (line >= pxVerticalBlank  && line < pxVerticalBlank + pxTopBorder)
            {
                if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = cDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = cDisplayBorder;
                }
            }
            
            if (line >= (pxVerticalBlank + pxTopBorder + pxVerticalDisplay) && line < pxVerticalTotal)
            {
                if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = cDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = cDisplayBorder;
                }
            }
            
            if (line >= (pxVerticalBlank + pxTopBorder) && line < (pxVerticalBlank + pxTopBorder + pxVerticalDisplay))
            {
                if ((ts >= 0 && ts < 16) || (ts >= 144 && ts < 176))
                {
                    emuDisplayTsTable[line][ts] = cDisplayBorder;
                }
                else if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = cDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = cDisplayPaper;
                }
            }
        }
    }
}

#pragma mark - Contention Tables

- (void)buildContentionTable
{
    for (int i = 0; i < tsPerFrame; i++)
    {
        memoryContentionTable[i] = 0;
        ioContentionTable[i] = 0;
        
        if (i >= tsToOrigin)
        {
            uint32 line = (i - tsToOrigin) / tsPerLine;
            uint32 ts = (i - tsToOrigin) % tsPerLine;
            
            if (line < 192 && ts < 128)
            {
                memoryContentionTable[i] = cContentionValues[ ts & 0x07 ];
                ioContentionTable[i] = cContentionValues[ ts & 0x07 ];
            }
        }
    }
}

#pragma mark - Snapshot Loading

- (void)loadSnapshot
{
    // Implemented in the specific machine class
}

- (void)loadZ80Snapshot
{
    // Implemented in the specific machine class
}

- (void)loadSnapshotWithPath:(NSString *)path
{
    // This will be called from the main thread so it needs to by sync'd with the emulation queue
    dispatch_sync(self.emulationQueue, ^
    {
        
        self.snapshotPath = path;
        NSString *extension = [[path pathExtension] uppercaseString];
        
        if ([extension isEqualToString:@"SNA"])
        {
            event = eSnapshot;
        }
        
        if ([extension isEqualToString:@"Z80"])
        {
            event = eZ80Snapshot;
        }
    });
}

#pragma mark - View Event Protocol Methods

- (void)keyDown:(NSEvent *)theEvent
{
    if (!theEvent.isARepeat && !(theEvent.modifierFlags & NSEventModifierFlagCommand))
    {
        // Because keyboard updates are called on the main thread, changes to the keyboard map
        // must be done on the emulation queue to prevent a race condition
        dispatch_sync(self.emulationQueue, ^{
            switch (theEvent.keyCode)
            {
                case 51: // Backspace
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[4] &= ~0x01; // 0
                    break;
                    
                case 126: // Arrow up
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[4] &= ~0x08; // 7
                    break;
                    
                case 125: // Arrow down
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[4] &= ~0x10; // 6
                    break;
                    
                case 123: // Arrow left
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[3] &= ~0x10; // 5
                    break;
                    
                case 124: // Arrow right
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[4] &= ~0x04; // 8
                    break;
                    
                default:
                    for (NSUInteger i = 0; i < sizeof(keyboardLookup) / sizeof(keyboardLookup[0]); i++)
                    {
                        if (keyboardLookup[i].keyCode == theEvent.keyCode)
                        {
                            keyboardMap[keyboardLookup[i].mapEntry] &= ~(1 << keyboardLookup[i].mapBit);
                            break;
                        }
                    }
                    break;
            }
        });
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    if (!theEvent.isARepeat && !(theEvent.modifierFlags & NSEventModifierFlagCommand))
    {
        // Because keyboard updates are called on the main thread, changes to the keyboard map
        // must be done on the emulation queue to prevent a race condition
        dispatch_sync(self.emulationQueue, ^{
            switch (theEvent.keyCode)
            {
                case 51: // Backspace
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[4] |= 0x01; // 0
                    break;
                    
                case 126: // Arrow up
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[4] |= 0x08; // 7
                    break;
                    
                case 125: // Arrow down
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[4] |= 0x10; // 6
                    break;
                    
                case 123: // Arrow left
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[3] |= 0x10; // 5
                    break;
                    
                case 124: // Arrow right
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[4] |= 0x04; // 8
                    break;
                    
                default:
                    for (NSUInteger i = 0; i < sizeof(keyboardLookup) / sizeof(keyboardLookup[0]); i++)
                    {
                        if (keyboardLookup[i].keyCode == theEvent.keyCode)
                        {
                            keyboardMap[keyboardLookup[i].mapEntry] |= (1 << keyboardLookup[i].mapBit);
                            break;
                        }
                    }
                    break;
            }
        });
    }
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    if (!(theEvent.modifierFlags & NSEventModifierFlagCommand))
    {
        // Because keyboard updates are called on the main thread, changes to the keyboard map
        // must be done on the emulation queue to prevent a race condition
        dispatch_sync(self.emulationQueue, ^{
            switch (theEvent.keyCode)
            {
                case 58: // Alt Right - This puts the keyboard into extended mode in a single keypress
                case 61: // Alt Left
                    if (theEvent.modifierFlags & NSEventModifierFlagOption)
                    {
                        keyboardMap[0] &= ~0x01;
                        keyboardMap[7] &= ~0x02;
                    }
                    else
                    {
                        keyboardMap[0] |= 0x01;
                        keyboardMap[7] |= 0x02;
                    }
                    break;
                    
                case 56: // Left Shift
                case 60: // Right Shift
                    if (theEvent.modifierFlags & NSEventModifierFlagShift)
                    {
                        keyboardMap[0] &= ~0x01;
                    }
                    else
                    {
                        keyboardMap[0] |= 0x01;
                    }
                    break;
                    
                case 59: // Control
                    if (theEvent.modifierFlags & NSEventModifierFlagControl)
                    {
                        keyboardMap[7] &= ~0x02;
                    }
                    else
                    {
                        keyboardMap[7] |= 0x02;
                    }
                    
                default:
                    break;
            }
        });
    }
}

- (void)resetKeyboardMap
{
    for (int i = 0; i < 8; i++)
    {
        keyboardMap[i] = 0xff;
    }
}

- (void *)getCore;
{
    return nil;
}

@end
