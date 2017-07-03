//
//  ZXSpectrum.m
//  SpectREM
//
//  Created by Mike Daley on 26/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ZXSpectrum.h"
#import "KeyboardMatrix.h"
#import "Snapshot.h"
#import "SZX.h"
#import "Z80Core.h"
#import "SmartLink.h"
#import "SLNetwork.hpp"

#pragma mark - Type Definitions

// Defines an enum for each type of display action used when drawing the screen
typedef NS_ENUM(NSUInteger, DisplayAction)
{
    eDisplayBorder = 1,
    eDisplayPaper,
    eDisplayRetrace
};

// Defines an enum for each event type that can be encountered
typedef NS_ENUM(NSUInteger, EmulatorEventType)
{
    eNone,
    eReset,
    eSnapshot,
    eZ80Snapshot
};

// Defines an enum for the different values that are retrieved as part of the floating bus method
typedef NS_ENUM(NSUInteger, FloatingBusValueType)
{
    ePixel = 1,
    eAttribute = 2
};

typedef NS_ENUM(int, TapeLoadingState)
{
    ePilotPulseHeader = 0,
    ePilotPulseData,
    eFirstSyncPulse,
    eSecondSyncPulse,
    eDataPulse
};

typedef NS_ENUM(int, ULAplusMode)
{
    eULAplusPaletteGroup = 0,
    eULAplusModeGroup
};

#pragma mark - Interface


@interface ZXSpectrum ()
{
@public
    // Keyboard matrix data
    unsigned char keyboardMap[8];

    // Emulation display sizes
    int emuLeftBorderPx;
    int emuRightBorderPx;
    int emuBottomBorderPx;
    int emuTopBorderPx;
    int emuDisplayPxWidth;
    int emuDisplayPxHeight;

    // Stores the memory address for the first byte in each row of the bitmap screen
    uint16 emuTsLine[192];

    // Stores the screen action based on the current frames tstate e.g. draw border, draw bitmap or beam retrace
    uint8 emuDisplayTsTable[313][225];

    // Holds the texture horiz and vert scale used when only selecting a subset of the texture to be displayed.
    // The full Spectrum screen size is generated so to display equal border sizes a sub rect of the full texture
    // is used for the display. Also reducing the size of the border is perfored in the same way e.g. making a smaller
    // rect from which to take the texture data
    float emuHScale;
    float emuVScale;

    // Used to track the flash phase
    int frameCounter;

    // ULAplus
    int ulaPlusMode;
    int ulaPlusPaletteOn;
    int ulaPlusCurrentReg;
    char clut[64];
    struct PixelColor ulaColor[256];

    // Audio
    double audioBeeperLeft;
    double audioBeeperRight;
    int audioEarBit;
    int audioMicBit;
    int audioBufferIndex;
    int audioTStates;
    int audioTsCounter;
    double audioTsStepCounter;
    double audioTsStep;
    int audioBufferSize;
    int audioAYTStates;
    int audioAYTStatesStep;
    unsigned char lastfffd;

    // SpecDrum
    int specDrumOutput;

    // Tape loading
    int tapeLoadingState;
    int tapeLoadingSubState;
    int pilotPulseTs;
    int pilotPulses;
    BOOL flipTapeBit;
    int tapeInputBit;


    // Holds the kempston joystick last byte value read either through the emulator or SmartLINK
    char smartlinkKempston;

    // Byte request used to get data from SmartLink
    NSData *smartLinkRequest;
}

@end


#pragma mark - Implementation


@implementation ZXSpectrum
{
    // Used to connect over the network to the smart card server
    SLNetwork *smart_card;

    // Thread event e.g. should a snap shot be loaded
    EmulatorEventType event;
}


- (void)dealloc
{
    NSLog(@"Deallocating %@", [self className]);
    free (memory);
    free (rom);
    free(emuDisplayBuffer);
    free(self.audioBuffer);
}


- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController machineInfo:(MachineInfo)info
{
    if (self = [super init])
    {
        machineInfo = info;
        _emulationViewController = emulationViewController;
        
        _preferences = [NSUserDefaults standardUserDefaults];
        
        event = EmulatorEventType::eNone;
        
        borderColor = 7;
        frameCounter = 0;
        
        emuLeftBorderPx = 32;
        emuRightBorderPx = 32;
        
        emuBottomBorderPx = 32;
        emuTopBorderPx = 32;
        
        emuDisplayPxWidth = 256 + emuLeftBorderPx + emuRightBorderPx;
        emuDisplayPxHeight = 192 + emuTopBorderPx + emuBottomBorderPx;
        
        emuHScale = 1.0 / emuDisplayPxWidth;
        emuVScale = 1.0 / emuDisplayPxHeight;
        
        emuDisplayTs = 0;
        
        // Setup the display buffer and length used to store the output from the emulator
        emuDisplayBufferLength = (emuDisplayPxWidth * emuDisplayPxHeight) * sizeof(PixelColor);
        emuDisplayBuffer = (unsigned char *)calloc(emuDisplayBufferLength, sizeof(unsigned char));
        
        float fps = 50;
        
        audioBufferSize = (cAUDIO_SAMPLE_RATE / fps) * 6;
        audioTsStep = machineInfo.tsPerFrame / (cAUDIO_SAMPLE_RATE / fps);
        audioAYTStatesStep = 32;
        self.audioBuffer = (int16_t *)malloc(audioBufferSize);
        
        self.accelerated = NO;
        
        self.keystrokesBuffer = [NSMutableArray new];
        
        [self resetFrame];
        [self resetSound];
        [self resetNext];
        [self buildContentionTable];
        [self buildScreenLineAddressTable];
        [self buildDisplayTsTable];
        [self buildULAColorTable];
        [self resetKeyboardMap];
        [self setupSmartLink];
        
        self.emulationQueue = dispatch_queue_create("emulationQueue", nil);
        self.audioCore = [[AudioCore alloc] initWithSampleRate:cAUDIO_SAMPLE_RATE
                                               framesPerSecond:fps
                                                emulationQueue:self.emulationQueue
                                                       machine:self];
        [self.audioCore reset];
        [self setupObservers];
        
        // DEBUGGING SZX
        //        NSURL *url = [[NSBundle mainBundle] URLForResource:@"AgentX" withExtension:@"szx"];
        //        BOOL szxValid = [SZX isSZXValidWithURL:url];
    }
    return self;
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


#pragma mark - Emulation Control

- (void)enableSmartCard
{
    if (self.smartCardEnabled)
    {
        smart_card = new SLNetwork;
        smart_card->connect();
    }
}

- (void)disableSmartCard
{
    if (smart_card)
    {
        delete smart_card;
    }
}

- (void)start
{
    [self.audioCore start];
    [self resetFrame];
    [self doFrame];
}


- (void)stop
{
    [self removeObservers];
    [self.audioCore stop];
}


#pragma mark - SMARTLink setup


- (void)setupSmartLink
{
    // SmartLINK. A request byte of 0x77 causes SmartLINK to respond
    smartlinkKempston = 0x0;
    char smartLinkRequestBuffer[1];
    smartLinkRequestBuffer[0] = 0x77;
    smartLinkRequest = [NSData dataWithBytes:smartLinkRequestBuffer length:1];
    
    self.smartLink = [SmartLink new];
}


#pragma mark - Various Reset Entry points


- (void)reset:(BOOL)hard
{
    CZ80Core *core = (CZ80Core *)[self getCore];
    core->Reset(hard);
    if (hard)
    {
        [self loadDefaultROM];
    }
        
    frameCounter = 0;
    saveTrapTriggered = false;
    loadTrapTriggered = false;
    ulaPlusPaletteOn = 0;
    multifacePagedIn = false;
    multifaceLockedOut = false;
    smartCardActive = true;
    [self resetNext];
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
    specDrumOutput = 0;
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

- (void)resetNext
{
    // Reset the sprite palette
    for (int i = 0; i < 256; i++)
    {
        spritePalette[i] = i;
    }
    
    // Reset the sprite info
    for (int i = 0; i < cMAX_SPRITES; i++)
    {
        spriteInfo[i][SpriteInfo::eXPosition] = 0;
        spriteInfo[i][SpriteInfo::eYPosition] = 0;
        spriteInfo[i][SpriteInfo::ePaletteMirrorRotate] = 0;
        spriteInfo[i][SpriteInfo::eVisible] = 0;
    }
    
    // Reset sprite list
    for (int i = 0; i < cSPRITE_VERT_LINES; i++)
    {
        for (int j = 0; j < cMAX_SPRITES_PER_SCANLINE; j++)
        {
            spriteLineList[i][j] = -1;
        }
    }
}

- (void)randomizeFramesVar
{
    int frames = arc4random_uniform(2^24);
    CZ80Core *core = (CZ80Core *)[self getCore];
    
    core->Z80CoreDebugMemWrite(cFRAMES, frames & 0xff, NULL);
    core->Z80CoreDebugMemWrite(cFRAMES + 1, frames & 0xff00, NULL);
    core->Z80CoreDebugMemWrite(cFRAMES + 2, frames & 0xff0000, NULL);
}

- (void)NMI
{
    CZ80Core *core = (CZ80Core *)[self getCore];
    if (!multifacePagedIn && (self.multiface1 || self.multiface128))
    {
        multifacePagedIn = true;
    }
    core->setNMIReq(true);
}

#pragma mark - CPU Frames


- (void)doFrame
{
    // Ensure that the frame is run on the emulation queue
    dispatch_sync(self.emulationQueue, ^
                  {
                      @autoreleasepool {
                          switch (event)
                          {
                              case EmulatorEventType::eNone:
                                  break;
                                  
                              case EmulatorEventType::eReset:
                                  break;
                                  
                              case EmulatorEventType::eSnapshot:
                                  [self loadSnapshot];
                                  break;
                                  
                              case EmulatorEventType::eZ80Snapshot:
                                  [self loadZ80Snapshot];
                                  break;
                                  
                              default:
                                  break;
                          }
                          event = EmulatorEventType::eNone;
                          [self resetFrame];
                          [self generateFrame];
                      }
                  });
}


- (void)generateFrame
{
    CZ80Core *core = (CZ80Core *)[self getCore];
    
    int count = machineInfo.tsPerFrame;
    
    while (count > 0 && !self.paused)
    {
        int tsCPU = core->Execute(1, machineInfo.intLength);
        
        if (self.step)
        {
            self.paused = YES;
        }
        
        if (self.zxTape.playing)
        {
            [self.zxTape updateTapeWithTStates:tsCPU];
        }
        
        // Deal with save/load if traps have been triggered
        if (saveTrapTriggered)
        {
            [self.zxTape saveTAPBlockWithMachine:self];
        }
        else if (loadTrapTriggered)
        {
            [self.zxTape loadTAPBlockWithMachine:self];
        }
        else
        {
            count -= tsCPU;
            
            if (!self.accelerated) {
                updateAudioWithTStates(tsCPU, (__bridge void *)self);
            }
            
            if (core->GetTStates() >= machineInfo.tsPerFrame )
            {
                // Must reset count to ensure we leave the while loop at the correct point
                count = 0;
                
                core->ResetTStates( machineInfo.tsPerFrame );
                core->SignalInterrupt();
                
                updateScreenWithTStates(machineInfo.tsPerFrame - emuDisplayTs, (__bridge void *)self);
                
                if (self.accelerated)
                {
                    if (frameCounter % cACCELERATED_SKIP_FRAMES)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.emulationViewController updateEmulationViewWithPixelBuffer:emuDisplayBuffer
                                                                                      length:(CFIndex)emuDisplayBufferLength
                                                                                        size:(CGSize){(float)emuDisplayPxWidth, (float)emuDisplayPxHeight}];
                        });
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.emulationViewController updateEmulationViewWithPixelBuffer:emuDisplayBuffer
                                                                                  length:(CFIndex)emuDisplayBufferLength
                                                                                    size:(CGSize){(float)emuDisplayPxWidth, (float)emuDisplayPxHeight}];
                    });
                }
                
                
                frameCounter++;
            }
        }
    }
    
    // If smartlink is activated and a serial port has been selected then try to read from
    // SmartLINK and if successful this will update the keyboard map and Kempston joystick port
    //    if (self.smartLink.serialPort && self.useSmartLink)
    //    {
    //        [self.smartLink sendData:smartLinkRequest code:0x77 waitForResponse:NO];
    //    }
    
}

#pragma mark - Debugging methods

- (void)stepInstruction
{
    CZ80Core *core = (CZ80Core *)[self getCore];
    core->Execute(1, machineInfo.intLength);
    
    if (core->GetTStates() >= machineInfo.tsPerFrame)
    {
        core->ResetTStates();
        core->SignalInterrupt();
        updateScreenWithTStates(machineInfo.tsPerFrame - emuDisplayTs, (__bridge void *)self);
        frameCounter ++;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.emulationViewController updateEmulationViewWithPixelBuffer:emuDisplayBuffer
                                                                  length:(CFIndex)emuDisplayBufferLength
                                                                    size:(CGSize){(float)emuDisplayPxWidth, (float)emuDisplayPxHeight}];
    });
}

#pragma mark - Load IF2 ROM


- (void)loadROMWithPath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    const char *fileBytes = (const char*)[data bytes];
    memcpy(memory, fileBytes, data.length);
}


#pragma mark - Load Default ROM


- (void)loadDefaultROM
{
    // Implemented in subclasses
}


#pragma mark - Audio


void updateAudioWithTStates(int numberTs, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    if (machine.paused)
    {
        return;
    }
    
    // Grab the current state of the audio ear output & the tapeLevel which is used to register input when loading tapes.
    // Only need to do this once per audio update
    signed int localBeeperLevel = ((machine->audioEarBit | machine->_zxTape->tapeInputBit) * cAUDIO_BEEPER_VOL_MULTIPLIER) | machine->specDrumOutput;
    signed int beeperLevelLeft = localBeeperLevel;
    signed int beeperLevelRight = localBeeperLevel;
    
    double leftMixA = 0.5;
    double rightMixA = 0.5;
    double leftMixB = 0.5;
    double rightMixB = 0.5;
    double leftMixC = 0.5;
    double rightMixC = 0.5;
    
    AudioCore *aCore = machine.audioCore;
    
    if (machine->_AYChannelABalance > 0.5)
    {
        leftMixA = 1.0 - machine->_AYChannelABalance;
        rightMixA = machine->_AYChannelABalance;
    }
    else if (machine->_AYChannelABalance < 0.5)
    {
        leftMixA = 1.0 - (machine->_AYChannelABalance / 2);
        rightMixA = 1.0 - (1.0 - machine->_AYChannelABalance);
    }
    
    if (machine->_AYChannelBBalance > 0.5)
    {
        leftMixB = 1.0 - machine->_AYChannelBBalance;
        rightMixB = machine->_AYChannelBBalance;
    }
    else if (machine->_AYChannelBBalance < 0.5)
    {
        leftMixB = 1.0 - (machine->_AYChannelBBalance / 2);
        rightMixB = 1.0 - (1.0 - machine->_AYChannelBBalance);
    }
    
    if (machine->_AYChannelCBalance > 0.5)
    {
        leftMixC = 1.0 - machine->_AYChannelCBalance;
        rightMixC = machine->_AYChannelCBalance;
    }
    else if (machine->_AYChannelCBalance < 0.5)
    {
        leftMixC = 1.0 - (machine->_AYChannelCBalance / 2);
        rightMixC = 1.0 - (1.0 - machine->_AYChannelCBalance);
    }
    
    // Loop over each tState so that the necessary audio samples can be generated
    for(int i = 0; i < numberTs; i++)
    {
        if (machine->machineInfo.hasAY || (machine->machineInfo.machineType == eZXSpectrum48 && machine->_useAYOn48k))
        {
            machine->audioAYTStates++;
            
            if (machine->audioAYTStates >= machine->audioAYTStatesStep)
            {
                [aCore updateAY:1];
                
                if (machine->_AYChannelA)
                {
                    signed int channelA = aCore->channelOutput[0];
                    beeperLevelLeft += (channelA * leftMixA);
                    beeperLevelRight += (channelA * rightMixA);
                }
                
                if (machine->_AYChannelB)
                {
                    signed int channelB = aCore->channelOutput[1];
                    beeperLevelLeft += (channelB * leftMixB);
                    beeperLevelRight += (channelB * rightMixB);
                }
                
                if (machine->_AYChannelC)
                {
                    signed int channelC = aCore->channelOutput[2];
                    beeperLevelLeft += (channelC * leftMixC);
                    beeperLevelRight += (channelC * rightMixC);
                }
                
                // Reset the core channel values
                aCore->channelOutput[0] = 0;
                aCore->channelOutput[1] = 0;
                aCore->channelOutput[2] = 0;
                
                machine->audioAYTStates -= machine->audioAYTStatesStep;
            }
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
        
        beeperLevelLeft = beeperLevelRight = localBeeperLevel;
    }
}


#pragma mark - Display


void updateScreenWithTStates(int numberTs, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    if (machine->_accelerated && machine->frameCounter % cACCELERATED_SKIP_FRAMES)
    {
        return;
    }
    
    while (numberTs > 0)
    {
        int line = machine->emuDisplayTs / machine->machineInfo.tsPerLine;
        int ts = machine->emuDisplayTs % machine->machineInfo.tsPerLine;
        
        switch (machine->emuDisplayTsTable[line][ts])
        {
            case DisplayAction::eDisplayRetrace:
                break;
                
            case DisplayAction::eDisplayBorder:
                
                if (machine->ulaPlusPaletteOn)
                {
                    int index = machine->borderColor + 8;
                    for (int i = 0; i < 8; i++)
                    {
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = ((machine->clut[index] & 28) >> 2) * 36;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = ((machine->clut[index] & 224) >> 5) * 36;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = (((machine->clut[index] & 3) << 1) | (machine->clut[index] & 2) | (machine->clut[index] & 1)) * 36;
                        machine->emuDisplayBufferIndex++;
                    }
                }
                else
                {
                    for (int i = 0; i < 8; i++)
                    {
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[machine->borderColor].r;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[machine->borderColor].g;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[machine->borderColor].b;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[machine->borderColor].a;
                    }
                }
                break;
                
            case DisplayAction::eDisplayPaper:
            {
                int y = line - (machine->machineInfo.pxVerticalBlank + machine->machineInfo.pxTopBorder);
                int x = (ts >> 2) - 4;
                
                uint pixelAddress = machine->emuTsLine[y] + x;
                uint attributeAddress = cBITMAP_SIZE + ((y >> 3) << 5) + x;
                
                int pixelByte = machine->memory[(machine->displayPage * 16384) + pixelAddress];
                int attributeByte = machine->memory[(machine->displayPage * 16384) + attributeAddress];
                
                if (machine->ulaPlusPaletteOn)
                {
                    int flash = (attributeByte & 0x80) ? 1 : 0;
                    int bright = (attributeByte & 0x40) ? 1 : 0;
                    int ulaPlusInk = (attributeByte & 0x07);
                    int ulaPlusPaper = ((attributeByte >> 3) & 0x07);
                    int index = 0;
                    char ulaPlusColor = 0;
                    
                    int bit = 0;
                    for (int b = 0x80; b; b >>= 1)
                    {
                        if (pixelByte & b) {
                            index = (flash * 2 + bright) * 16 + ulaPlusInk;
                            ulaPlusColor = machine->clut[index];
                        }
                        else
                        {
                            index = (flash * 2 + bright) * 16 + ulaPlusPaper + 8;
                            ulaPlusColor = machine->clut[index];
                        }
                        
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = ((ulaPlusColor & 28) >> 2) * 36;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = ((ulaPlusColor & 224) >> 5) * 36;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = (((ulaPlusColor & 3) << 1) | (ulaPlusColor & 2) | (ulaPlusColor & 1)) * 36;
                        machine->emuDisplayBufferIndex++;
                        
                        if (machine->machineInfo.machineType == eZXSpectrumNext)
                        {
                            drawSprites((x * 8) + bit + 32, y + machine->emuTopBorderPx, machine);
                        }
                        
                        bit++;
                    }
                }
                else
                {
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
                    
                    int bit = 0;
                    for (int b = 0x80; b; b >>= 1)
                    {
                        if (pixelByte & b) {
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[ink].r;
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[ink].g;
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[ink].b;
                            machine->emuDisplayBufferIndex++;

                        }
                        else
                        {
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[paper].r;
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[paper].g;
                            machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = palette[paper].b;
                            machine->emuDisplayBufferIndex++;
                        }
                        
                        if (machine->machineInfo.machineType == eZXSpectrumNext)
                        {
                            drawSprites((x * 8) + bit + 32, y + machine->emuTopBorderPx, machine);
                        }
                        
                        bit++;
                    }
                }
            
                break;
            }
                
            default:
                break;
        }
        
        machine->emuDisplayTs += machine->machineInfo.tsPerChar;
        numberTs -= machine->machineInfo.tsPerChar;
    }
}

void drawSprites(int x, int y, ZXSpectrum *machine)
{
    for (int i = 0; i < cMAX_SPRITES_PER_SCANLINE; i++)
    {
        if (machine->spriteLineList[y][i] != -1)
        {
            int spriteName = machine->spriteLineList[y][i];
            
            if (machine->spriteInfo[spriteName][SpriteInfo::eVisible])
            {
                int spriteX = machine->spriteInfo[spriteName][SpriteInfo::eXPosition];
                int spriteY = machine->spriteInfo[spriteName][SpriteInfo::eYPosition];
                
                // X MSB bit
                if (machine->spriteInfo[spriteName][SpriteInfo::ePaletteMirrorRotate] & 0x01)
                {
                    spriteX += 256;
                }
                
                if (x >= spriteX && x < (spriteX + 16) && y >= spriteY && y < (spriteY + 16))
                {
                    int paletteOffset = machine->spriteInfo[spriteName][SpriteInfo::ePaletteMirrorRotate] >> 4;
                    
                    int offsetX = x - spriteX;
                    int offsetY = y - spriteY;
                    
                    // Rotate
                    if (machine->spriteInfo[i][SpriteInfo::ePaletteMirrorRotate] & 0x02)
                    {
                        int t = offsetX;
                        offsetX = offsetY;
                        offsetY = t;
                    }
                    
                    // Mirror Y
                    if (machine->spriteInfo[i][SpriteInfo::ePaletteMirrorRotate] & 0x04)
                    {
                        offsetY = 15 - offsetY;
                    }
                    
                    // Mirror X
                    if (machine->spriteInfo[i][SpriteInfo::ePaletteMirrorRotate] & 0x08)
                    {
                        offsetX = 15 - offsetX;
                    }
                    
                    unsigned int pixelData = machine->sprites[spriteName][(offsetY * cSPRITE_HEIGHT) + offsetX];
                    unsigned int pixelColor = machine->spritePalette[(paletteOffset + pixelData) & 0xff];
                    
                    if (pixelColor != cSPRITE_TRANSPARENT_COLOR)
                    {
                        machine->emuDisplayBufferIndex -= 4;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = (pixelColor & 0xe0) << 0;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = (pixelColor & 0x1c) << 3;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = (pixelColor & 0x03) << 6;
                        machine->emuDisplayBuffer[machine->emuDisplayBufferIndex++] = 255;
                    }
                }
            }
        }
    }
}

#pragma mark - ULA


/**
 Calculate the necessary contention based on the Port number being accessed and if the port belongs to the ULA.
 All non-even port numbers below to the ULA. N:x means no contention to be added and just advance the tStates.
 C:x means that contention should be calculated based on the current tState value and then x tStates are to be
 added to the current tState count
 
 in 40 - 7F?| Low bit | Contention pattern
 ------------+---------+-------------------
 No    |  Reset  | N:1, C:3
 No    |   Set   | N:4
 Yes   |  Reset  | C:1, C:3
 Yes   |   Set   | C:1, C:1, C:1, C:1
 **/
unsigned char coreIORead(unsigned short address, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    bool contended = false;
    int page = address / c16k;
    
    // Identify contention on the 48k
    if (!machine->machineInfo.hasPaging && page == 1)
    {
        contended = true;
    }
    
    // Identify contention on the 128k
    if (machine->machineInfo.hasPaging &&
        (page == 1 ||
         (page == 3 && (machine->currentRAMPage == 1 || machine->currentRAMPage == 3 || machine->currentRAMPage == 5 || machine->currentRAMPage == 7))))
    {
        contended = true;
    }
    
    // Apply contention
    if (contended)
    {
        if ((address & 1) == 0)
        {
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
        }
    } else {
        if ((address & 1) == 0)
        {
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddTStates(4);
        }
    }
    
    // Handle ULA Un-owned ports
    if (address & 0x01)
    {
        // Add Kemptston joystick support. Until then return 0. Byte returned by a Kempston joystick is in the
        // format: 000FDULR. F = Fire, D = Down, U = Up, L = Left, R = Right
        // Joystick is read first as it takes priority if you read from a port that activates the keyboard as well on a
        // real machine.
        if ((address & 0xff) == 0x1f)
        {
            if (machine->multifacePagedIn)
            {
                machine->multifacePagedIn = false;
            }
            else if (machine.useSmartLink)
            {
                return machine->smartlinkKempston;
            }
            else
            {
                return 0x0;
            }
        }
        
        if ((address & 0xff) == 0x3f && machine->machineInfo.machineType == eZXSpectrum128)
        {
            if (machine->multifacePagedIn)
            {
                machine->multifacePagedIn = false;
                return 0x0;
            }
        }
        
        // AY-3-8912 ports
        else if ((address & 0xc002) == 0xc000 && (machine->machineInfo.hasAY ||
                                                  (machine->machineInfo.machineType == eZXSpectrum48 &&
                                                   machine.useAYOn48k) ))
        {
            return [machine.audioCore readAYData];
        }
        
        // ULAplus
        else if (address == 0xff3b)
        {
            if (machine->ulaPlusMode == eULAplusPaletteGroup)
            {
                return machine->clut[machine->ulaPlusCurrentReg] & 63;
            }
        }
        
        // Multiface 1
        else if ((address & 0xff) == 0x9f
                 && !machine->multifacePagedIn
                 && machine->machineInfo.machineType == eZXSpectrum48
                 && machine.multiface1)
        {
            machine->multifacePagedIn = true;
            [machine.audioCore reset];
        }
        
        // Multiface 128
        else if ((address & 0xff) == 0xbf
                 && !machine->multifacePagedIn
                 && machine->machineInfo.machineType == eZXSpectrum128
                 && machine.multiface128)
        {
            machine->multifacePagedIn = true;
            [machine.audioCore reset];
            if (machine->displayPage == 7)
            {
                return 0xff;
            }
            else
            {
                return 0x7f;
            }
        }
        
        // Retroleum SmartCard
        else if ((address & 0xfff1) == 0xfaf1 && machine.smartCardEnabled && machine->smart_card)
        {
            if(address == 0xfaf3)
            {
                return machine->smartCardPortFAF3;
            }
            else if(address == 0xfafb)
            {
                return machine->smartCardPortFAFB;
            }
            else
            {
                return machine->smart_card->read_port(address);
            }
        }
        
        // Getting here means that nothing has handled that port read so based on a real Spectrum return the floating bus value
        return floatingBus(m);
    }
    
    // Handle ULA Owned Ports
    int result = 0xff;
    
    // Check to see if the keyboard is being read and if so return any keys currently pressed
    if (address & 0xfe)
    {
        for (int i = 0; i < 8; i++)
        {
            if (!(address & (0x100 << i)))
            {
                result &= machine->keyboardMap[i];
            }
        }
    }
    
    // To emulate a series 3, the result of reading a ULA port should have bits 5+7 set and bit 6 should be set
    // to the last value of bit 4 when writing to port 0xFE.
    result = (result & 191) | (machine->audioEarBit << 6) | (machine->_zxTape->tapeInputBit << 6);
    
    return result;
}


void coreIOWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    bool contended = false;
    int page = address / c16k;
    
    // Identify contention in the 48k
    if (!machine->machineInfo.hasPaging && page == 1)
    {
        contended = true;
    }
    
    // Identify contention in the 128k
    if (machine->machineInfo.hasPaging &&
        (page == 1 ||
         (page == 3 && (machine->currentRAMPage == 1 ||
                        machine->currentRAMPage == 3 ||
                        machine->currentRAMPage == 5 ||
                        machine->currentRAMPage == 7))))
    {
        contended = true;
    }
    
    // Apply contention
    if (contended)
    {
        if ((address & 1) == 0)
        {
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(1);
        }
    }
    else
    {
        if ((address & 1) == 0)
        {
            core->AddTStates(1);
            core->AddContentionTStates( machine->memoryContentionTable[core->GetTStates() % machine->machineInfo.tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddTStates(4);
        }
    }
    
    // Port: 0xFE
    //   7   6   5   4   3   2   1   0
    // +---+---+---+---+---+-----------+
    // |   |   |   | E | M |  BORDER   |
    // +---+---+---+---+---+-----------+
    if (!(address & 0x01))
    {
        updateScreenWithTStates((core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.borderDrawingOffset, m);
        machine->audioEarBit = (data & 0x10) >> 4;
        machine->audioMicBit = (data & 0x08) >> 3;
        machine->borderColor = data & 0x07;
    }
    
    // Memory paging port
    if ( (address & 0x8002) == 0 && machine->disablePaging == NO)
    {
        // Save the last byte set, used when generating a Z80 snapshot
        machine->last7ffd = data;
        
        if (machine->displayPage != ((data & 0x08) == 0x08) ? 7 : 5)
        {
            updateScreenWithTStates((core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.borderDrawingOffset, m);
        }
        
        // You should only be able to disable paging once. To enable paging again then a reset is necessary.
        if (data & 0x20 && machine->disablePaging != YES)
        {
            machine->disablePaging = YES;
        }
        machine->currentROMPage = ((data & 0x10) == 0x10) ? 1 : 0;
        machine->displayPage = ((data & 0x08) == 0x08) ? 7 : 5;
        machine->currentRAMPage = (data & 0x07);
    }
    
    // AY-3-8912 ports
    if(address == 0xfffd && (machine->machineInfo.hasAY ||
                             (machine->machineInfo.hasAY ||
                              (machine->machineInfo.machineType == eZXSpectrum48 &&
                               machine.useAYOn48k) )))
    {
        machine->lastfffd = data;
        [machine.audioCore setAYRegister:data];
    }
    
    if ((address & 0xc002) == 0x8000 && (machine->machineInfo.hasAY ||
                                         (machine->machineInfo.hasAY ||
                                          (machine->machineInfo.machineType == eZXSpectrum48 &&
                                           machine.useAYOn48k) )))
    {
        [machine.audioCore writeAYData:data];
    }
    
    // SPECDRUM port, all ports ending in 0xdf
    if ((address & 0xff) == 0xdf && machine.specDrum)
    {
        // Adjust the output from SpecDrum to get the right volume. This value is then merged into the overall sound output
        machine->specDrumOutput = ((data * 128) - 16384) / 12;
    }
    
    // ULAplus ports
    if (address == 0xbf3b)
    {
        updateScreenWithTStates((core->GetTStates() - machine->emuDisplayTs), m);
        
        if (data & 0x40)
        {
            machine->ulaPlusMode = eULAplusModeGroup;
        }
        else if (machine->ulaPlusMode == eULAplusModeGroup)
        {
            machine->ulaPlusMode = eULAplusPaletteGroup;
        }
        
        if (machine->ulaPlusMode == eULAplusPaletteGroup)
        {
            machine->ulaPlusCurrentReg = (data & 63);
        }
    }
    
    if (address == 0xff3b)
    {
        updateScreenWithTStates((core->GetTStates() - machine->emuDisplayTs), m);
        
        if (machine->ulaPlusMode == eULAplusModeGroup)
        {
            machine->ulaPlusPaletteOn = (data & 0x01);
        }
        else
        {
            machine->clut[machine->ulaPlusCurrentReg] = data;
        }
    }
    
    // Multiface 128
    if ((address & 0xff) == 0x1f && machine->machineInfo.machineType == eZXSpectrum128 && machine.multiface128)
    {
        machine->multifaceLockedOut = (machine->multifaceLockedOut) ? false : true;
    }
    
    // Retroleum SmartCard
    if ((address & 0xfff1) == 0xfaf1 && machine.smartCardEnabled && machine->smart_card)
    {
        if(address == 0xfaf3)
        {
            machine->smartCardPortFAF3 = data;
        }
        else if(address == 0xfafb)
        {
            machine->smartCardPortFAFB = data;
        }
        else
        {
            machine->smart_card->write_port(address, data);
        }
    }
    
    // Next Sprites
    if (machine->machineInfo.machineType == eZXSpectrumNext)
    {
        if (address == 0x303B)
        {
            machine->currentSprite = data;
            machine->currentPalette = data;
            machine->currentSpriteInfo = data;
            machine->spriteDataOffset = 0;
            machine->spriteInfoOffset = SpriteInfo::eXPosition;
        }
        
        // Set palette colour info
        if ((address & 0xff) == 0x53)
        {
            machine->spritePalette[machine->currentPalette++] = data;
        }
        
        // Set sprite pattern info
        if ((address & 0xff) == 0x55)
        {
            machine->sprites[machine->currentSprite][machine->spriteDataOffset++] = data;
            if (machine->spriteDataOffset == 0)
            {
                machine->currentSprite++;
            }
        }
        
        // Set sprite attribute info
        if ((address & 0xff) == 0x57)
        {
            // If Y pos being changed
            if (machine->spriteInfoOffset == SpriteInfo::eYPosition || machine->spriteInfoOffset == SpriteInfo::eVisible)
            {
                int y = machine->spriteLineList[machine->currentSpriteInfo][SpriteInfo::eYPosition];
                int visible = machine->spriteLineList[machine->currentSpriteInfo][SpriteInfo::eVisible] & 0x80;
                
                // No point in updating anything if the new value is the same as the old value
                if (data != y || !visible)
                {
                    int spriteName = (machine->spriteInfo[machine->currentSpriteInfo][SpriteInfo::eVisible] & 63);

                    // Reset all the sprite lines that contain this sprite as its moving
                    for (int i = y; i < y + cSPRITE_HEIGHT; i++)
                    {
                        for (int j = 0; j < cMAX_SPRITES_PER_SCANLINE; j++)
                        {
                            if (i <= cSPRITE_VERT_LINES)
                            {
                                if (machine->spriteLineList[i][j] == spriteName)
                                {
                                    machine->spriteLineList[i][j] = -1;
                                    break;
                                }
                            }
                        }
                    }
                    
                    // Update the sprite lines list based on the sprites new position
                    y = data;
                    for (int i = y; i < y + cSPRITE_HEIGHT; i++)
                    {
                        for (int j = 0; j < cMAX_SPRITES_PER_SCANLINE; j++)
                        {
                            if (i <= cSPRITE_VERT_LINES)
                            {
                                if (machine->spriteLineList[i][j] == -1)
                                {
                                    machine->spriteLineList[i][j] = spriteName;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            machine->spriteInfo[machine->currentSpriteInfo][machine->spriteInfoOffset++] = data;
            machine->spriteInfoOffset &= 0x03;
            if (machine->spriteInfoOffset == 0)
            {
                machine->currentSpriteInfo++;
            }
        }
        
    }
    
}

/** 
 When the Z80 reads from an unattached port, such as 0xFF, it actually reads the data currently on the
 Spectrums ULA data bus. This may happen to be a byte being transferred from screen memory. If the ULA
 is building the border then the bus is idle and the return value is 0xFF, otherwise its possible to
 predict if the ULA is reading a pixel or attribute byte based on the current t-state.
 This routine works out what would be on the ULA bus for a given tstate and returns the result
 **/
static unsigned char floatingBus(void *m)
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    int cpuTs = core->GetTStates() - 1;
    int currentDisplayLine = (cpuTs / machine->machineInfo.tsPerLine);
    int currentTs = (cpuTs % machine->machineInfo.tsPerLine);
    
    // If the line and tState are within the paper area of the screen then grab the
    // pixel or attribute value which is determined by looking at the current tState
    if (currentDisplayLine >= (machine->machineInfo.pxTopBorder + machine->machineInfo.pxVerticalBlank)
        && currentDisplayLine < (machine->machineInfo.pxTopBorder + machine->machineInfo.pxVerticalBlank + machine->machineInfo.pxVerticalDisplay)
        && currentTs <= machine->machineInfo.tsHorizontalDisplay)
    {
        unsigned char ulaValueType = cFLOATING_BUS_TABLE[ currentTs & 0x07 ];
        
        int y = currentDisplayLine - (machine->machineInfo.pxTopBorder + machine->machineInfo.pxVerticalBlank);
        int x = currentTs >> 2;
        
        if (ulaValueType == FloatingBusValueType::ePixel)
        {
            return machine->memory[cBITMAP_ADDRESS + machine->emuTsLine[y] + x];
        }
        
        if (ulaValueType == FloatingBusValueType::eAttribute)
        {
            return machine->memory[cBITMAP_ADDRESS + cBITMAP_SIZE + ((y >> 3) << 5) + x];
        }
    }
    
    return 0xff;
}


#pragma mark - Build Contention Tables


- (void)buildContentionTable
{
    for (int i = 0; i < machineInfo.tsPerFrame; i++)
    {
        memoryContentionTable[i] = 0;
        ioContentionTable[i] = 0;
        
        if (i >= machineInfo.tsToOrigin)
        {
            uint32 line = (i - machineInfo.tsToOrigin) / machineInfo.tsPerLine;
            uint32 ts = (i - machineInfo.tsToOrigin) % machineInfo.tsPerLine;
            
            if (line < machineInfo.pxVerticalDisplay && ts < 128)
            {
                memoryContentionTable[i] = cCONTENTION_VALUES[ ts & 0x07 ];
                ioContentionTable[i] = cCONTENTION_VALUES[ ts & 0x07 ];
            }
        }
    }
}


#pragma mark - Build Display Tables


// Stores the memory address for the start of each paper line on the screen
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


/**
 Generates a table that holds what screen activity should be happening based on each T-States within a Frame e.g. should the
 border be drawn, bitmap screen or beam retrace. The values have been adjusted to ensure that the image drawn will be 320x256.
 **/
- (void)buildDisplayTsTable
{
    for(int line = 0; line < machineInfo.pxVerticalTotal; line++)
    {
        for(int ts = 0 ; ts < machineInfo.tsPerLine; ts++)
        {
            if (line >= 0  && line < machineInfo.pxVerticalBlank)
            {
                emuDisplayTsTable[line][ts] = DisplayAction::eDisplayRetrace;
            }
            
            // Top Border
            if (line >= machineInfo.pxVerticalBlank && line < machineInfo.pxVerticalBlank + machineInfo.pxTopBorder)
            {
                if ((ts >= 160 && ts < machineInfo.tsPerLine) || line < machineInfo.pxVerticalBlank + machineInfo.pxTopBorder - emuTopBorderPx)
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayBorder;
                }
            }
            
            // Border + Paper + Border
            if (line >= (machineInfo.pxVerticalBlank + machineInfo.pxTopBorder) && line < (machineInfo.pxVerticalBlank + machineInfo.pxTopBorder + machineInfo.pxVerticalDisplay))
            {
                if ((ts >= 0 && ts < 16) || (ts >= 144 && ts < 160))
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayBorder;
                }
                else if (ts >= 160 && ts < machineInfo.tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayPaper;
                }
            }
            
            // Bottom Border
            if (line >= (machineInfo.pxVerticalBlank + machineInfo.pxTopBorder + machineInfo.pxVerticalDisplay) && line < machineInfo.pxVerticalTotal - 24)
            {
                if (ts >= 160 && ts < machineInfo.tsPerLine)
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = DisplayAction::eDisplayBorder;
                }
            }
            
        }
    }
}


/**
 Build a table of all the possible ULAplus colours using G3R3B2.
 **/
- (void)buildULAColorTable
{
    char r, g, b;
    
    for (int color = 0; color <= 256; color++)
    {
        g = ((color & 224) >> 5) * 36;
        r = ((color & 28) >> 2) * 36;
        b = (((color & 3) << 1) | (color & 2) | (color & 1)) * 36;
        
        ulaColor[color].g = g;
        ulaColor[color].r = r;
        ulaColor[color].b = b;
        ulaColor[color].a = 255;
    }
    
    // Blank out the CLUT (Color Lookup Table)
    for (int i = 0; i < 64; i++)
    {
        clut[i] = 0x00;
    }
}


#pragma mark - View Event Protocol Methods


- (void)keyDown:(NSEvent *)theEvent
{
    if (!theEvent.isARepeat && !(theEvent.modifierFlags & NSEventModifierFlagCommand) && !self.useSmartLink )
    {
        // Because keyboard updates are called on the main thread, changes to the keyboard map
        // must be done on the emulation queue to prevent a race condition
        dispatch_sync(self.emulationQueue, ^{
            switch (theEvent.keyCode)
            {
                case 30: // Inv Video
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[3] &= ~0x08; // 4
                    break;
                    
                case 33: // True Video
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[3] &= ~0x04; // 3
                    break;
                    
                case 39: // "
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[5] &= ~0x01; // P
                    break;
                    
                case 41: // ;
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[5] &= ~0x02; // O
                    break;
                    
                case 43: // ,
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[7] &= ~0x08; // N
                    break;
                    
                case 27: // -
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[6] &= ~0x08; // J
                    break;
                    
                case 24: // +
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[6] &= ~0x04; // K
                    break;
                    
                case 47: // .
                    keyboardMap[7] &= ~0x02; // Sym
                    keyboardMap[7] &= ~0x04; // M
                    break;
                    
                case 48: // Edit
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[3] &= ~0x01; // 1
                    break;
                    
                case 50: // Graph
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[4] &= ~0x02; // 9
                    break;
                    
                case 53: // Break
                    keyboardMap[0] &= ~0x01; // Shift
                    keyboardMap[7] &= ~0x01; // Space
                    break;
                    
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
    
    if (!theEvent.isARepeat && !(theEvent.modifierFlags & NSEventModifierFlagCommand) && !self.useSmartLink)
    {
        // Because keyboard updates are called on the main thread, changes to the keyboard map
        // must be done on the emulation queue to prevent a race condition
        dispatch_sync(self.emulationQueue, ^{
            switch (theEvent.keyCode)
            {
                case 30: // Inv Video
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[3] |= 0x08; // 4
                    break;
                    
                case 33: // True Video
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[3] |= 0x04; // 3
                    break;
                    
                case 39: // "
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[5] |= 0x01; // P
                    break;
                    
                case 41: // "
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[5] |= 0x02; // O
                    break;
                    
                case 43: // ,
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[7] |= 0x08; // M
                    break;
                    
                case 24: // +
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[6] |= 0x04; // K
                    break;
                    
                case 27: // -
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[6] |= 0x08; // J
                    break;
                    
                case 47: // .
                    keyboardMap[7] |= 0x02; // Sym
                    keyboardMap[7] |= 0x04; // N
                    break;
                    
                case 48: // Edit
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[3] |= 0x01; // 1
                    break;
                    
                case 50: // Graph
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[4] |= 0x02; // 9
                    break;
                    
                case 53: // Break
                    keyboardMap[0] |= 0x01; // Shift
                    keyboardMap[7] |= 0x01; // Space
                    break;
                    
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
    if (!(theEvent.modifierFlags & NSEventModifierFlagCommand) && !self.useSmartLink)
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
                    
                case 57: // Caps Lock
                    if (theEvent.modifierFlags & NSEventModifierFlagCapsLock)
                    {
                        //                        keyboardMap[0] &= ~0x01;
                        //                        keyboardMap[3] &= ~0x02;
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
                    break;
                    
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
        keyboardMap[i] = 0xbf;
    }
}


#pragma mark - Snapshot Loading


- (void)loadSnapshotWithPath:(NSString *)path
{
    // This will be called from the main thread so it needs to by sync'd with the emulation queue
    dispatch_sync(self.emulationQueue, ^
                  {
                      self.snapshotPath = path;
                      NSString *extension = [[path pathExtension] uppercaseString];
                      
                      if ([extension isEqualToString:@"SNA"])
                      {
                          event = EmulatorEventType::eSnapshot;
                      }
                      
                      if ([extension isEqualToString:@"Z80"])
                      {
                          event = EmulatorEventType::eZ80Snapshot;
                      }
                  });
}


- (void)loadSnapshot
{
    [self reset:NO];
    int status = [Snapshot loadSnapshotWithPath:self.snapshotPath IntoMachine:self];
    [self verifySnapshotLoadWithStatus:status];
}


- (void)loadZ80Snapshot
{
    [self reset:NO];
    int status = [Snapshot loadZ80SnapshotWithPath:self.snapshotPath intoMachine:self];
    [self verifySnapshotLoadWithStatus:status];
}


- (void)verifySnapshotLoadWithStatus:(int)status
{
    switch (status) {
        case 0:
            [self resetSound];
            [self resetKeyboardMap];
            break;
            
        case 1:
            break;
        default:
            break;
    }
}


#pragma mark - Properties


/**
 This is implemented within each machine class and returna a reference to the core being used for that machinne
 **/
- (void *)getCore;
{
    return nil;
}


/**
 Returns the string name for a machine. Each machine class implements this method and returns the appropriate machine name
 **/
- (NSString *)machineName
{
    return @"Unknown";
}


- (void)setUseSmartLink:(BOOL)useSmartLink
{
    _useSmartLink = useSmartLink;
    [self resetKeyboardMap];
}


@end
