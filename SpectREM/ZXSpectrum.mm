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

// Structure of pixel data used in the emulation display buffer
struct PixelData {
    uint8 r;
    uint8 g;
    uint8 b;
    uint8 a;
};

// Pallette
struct PixelData pallette[] = {
    
    // Normal colours
    {0, 0, 0, 255},         // Black
    {0, 0, 205, 255},       // Blue
    {205, 0, 0, 255},       // Red
    {205, 0, 205, 255},     // Green
    {0, 205, 0, 255},       // Magenta
    {0, 205, 205, 255},     // Cyan
    {205, 205, 0, 255},     // Yellow
    {205, 205, 205, 255},   // White
    
    // Bright colours
    {0, 0, 0, 255},
    {0, 0, 255, 255},
    {255, 0, 0, 255},
    {255, 0, 255, 255},
    {0, 255, 0, 255},
    {0, 255, 255, 255},
    {255, 255, 0, 255},
    {255, 255, 255, 255}
};

@interface ZXSpectrum ()

@end

@implementation ZXSpectrum

- (void)dealloc
{
    NSLog(@"gone");
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController
{
    self = [super init];
    return self;
}

- (void)loadSnapshot {}
- (void)loadZ80Snapshot {}
- (void)loadSnapshotWithPath:(NSString *)path
{
    // This will be called from the main thread so it needs to by sync'd with the emulation queue
    dispatch_sync(self.emulationQueue, ^{
        
        self.snapshotPath = path;
        NSString *extension = [[path pathExtension] lowercaseString];
        
        if ([extension isEqualToString:@"sna"])
        {
            event = Snapshot;
        }
        
        if ([extension isEqualToString:@"z80"])
        {
            event = Z80Snapshot;
        }
        
    });
}

- (void)generateFrame {}

#pragma mark - Binding

- (void)setupObservers
{
    [self addObserver:self.audioCore forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self.audioCore forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self.audioCore forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark -

- (void)start
{
    [self resetFrame];
    [self doFrame];
}

- (void)pause
{
    
}

- (void)stop
{
    [self removeObserver:self.audioCore forKeyPath:@"soundLowPassFilter"];
    [self removeObserver:self.audioCore forKeyPath:@"soundHighPassFilter"];
    [self removeObserver:self.audioCore forKeyPath:@"soundVolume"];
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
    audioBeeperValue = 0;
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
                           case None:
                               break;
                               
                           case Reset:
                               event = None;
                               [self reset];
                               break;
                               
                           case Snapshot:
                               [self reset];
                               [self loadSnapshot];
                               event = None;
                               break;
                               
                           case Z80Snapshot:
                               [self reset];
                               [self loadZ80Snapshot];
                               event = None;
                               break;
                               
                           default:
                               break;
                       }
                       
                       [self resetFrame];
                       [self generateFrame];
                   });
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
            case kDisplayRetrace:
                break;
                
            case kDisplayBorder:
                for (int i = 0; i < 8; i++)
                {
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].r;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].g;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].b;
                    machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = pallette[machine->borderColour].a;                    
                }
                break;
                
            case kDisplayPaper:
            {
                int y = line - (machine->pxVerticalBlank + machine->pxTopBorder);
                int x = (ts >> 2) - 4;
                
                uint pixelAddress = machine->emuTsLine[y] + x;
                uint attributeAddress = kBitmapSize + ((y >> 3) << 5) + x;
                
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
                emuDisplayTsTable[line][ts] = kDisplayRetrace;
            }
            
            if (line >= 8  && line < pxVerticalBlank + pxTopBorder)
            {
                if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = kDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
            }
            
            if (line >= (pxVerticalBlank + pxTopBorder + pxVerticalDisplay) && line < pxVerticalTotal)
            {
                if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = kDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
            }
            
            if (line >= (pxVerticalBlank + pxTopBorder) && line < (pxVerticalBlank + pxTopBorder + pxVerticalDisplay))
            {
                if ((ts >= 0 && ts < 16) || (ts >= 144 && ts < 176))
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
                else if (ts >= 176 && ts < tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = kDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = kDisplayPaper;
                }
            }
        }
    }
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

@end
