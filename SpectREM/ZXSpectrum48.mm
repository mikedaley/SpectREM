//
//  ZXSpectrum48.m
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXSpectrum48.h"
#import "Z80Core.h"
#import "AudioCore.h"
#import "KeyboardMatrix.h"
#import "EmulationViewController.h"

#import <CoreImage/CoreImage.h>

#pragma mark - Private Interface

@interface ZXSpectrum48 ()

// Emulation queue and timer
@property (strong) EmulationViewController *emulationViewController;
@property (assign) CGColorSpaceRef colourSpace;
@property (strong) id imageRef;
@property (strong) SKTexture *texture;
@property (strong) NSString *snapshotPath;

@end

#pragma mark - Defines

#define kTstatesPerFrame 69888

#define kDisplayBorder 1
#define kDisplayPaper 2
#define kDisplayRetrace 3

#define kBitmapAddress 16384
#define kBitmapSize 6144
#define kAttributeAddress kBitmapAddress + kBitmapSize

#pragma mark - Structures 

// Structure of pixel data used in the emulation display buffer
struct PixelData {
    uint8 r;
    uint8 g;
    uint8 b;
    uint8 a;
};

#pragma mark - Variables

// Z80 CPU core
CZ80Core *core;

// Main Memory array
// TODO: Break memory up into 16k banks. This will be needed for 128k machines
unsigned char memory[64 * 1024];

// Memory and IO contention tables
unsigned char   contentionValues[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };
unsigned char   memoryContentionTable[kTstatesPerFrame];
unsigned char   ioContentionTable[kTstatesPerFrame];

// Floating bus
unsigned char   floatingBusTable[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };
typedef enum : unsigned char {
    Pixel = 1,
    Attribute = 2
} FloatingBusValueType;

// Machine specific tState values
int             tsPerFrame;
int             tsPerLine;
int             tsTopBorder;
int             tsVerticalBlank;
int             tsVerticalDisplay;
int             tsHorizontalDisplay;
int             tsPerChar;
int             tsToOrigin;

// Machine specific pixel values
int             pxTopBorder;
int             pxVerticalBlank;
int             pxHorizontalDisplay;
int             pxVerticalDisplay;
int             pxHorizontalTotal;
int             pxVerticalTotal;

//*** Display values

// Holds the current border colour as set by the ULA
int             borderColour;

// Used to track the flash phase
int             frameCounter;

// Details for the image that is created for the screen representation
int             emuDisplayBitsPerPx;
int             emuDisplayBitsPerComponent;
int             emuDisplayBytesPerPx;
bool            emuShouldInterpolate;

// Image buffer array buffer, its length and current index into the buffer used when drawing
unsigned char   *emuDisplayBuffer;
unsigned int    emuDisplayBufferLength;
unsigned int    emuDisplayBufferIndex;

// Width and height of the image used to display the emulated screen
int             emuDisplayPxWidth;
int             emuDisplayPxHeight;

// Width of the left and right border in chars. A char is 8 pixels wide
int             emuLeftBorderPx;
int             emuRightBorderPx;

// Height of the top and bottom borders in pixel lines
int             emuTopBorderPx;
int             emuBottomBorderPx;

float           emuHScale;
float           emuVScale;

// Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
// in the current frame so that the right number of 8x1 screen chunks are drawn
int            emuDisplayTs;

// Holds the current pixel and attribute line addresses when rendering the screen
unsigned int    pixelAddress;
unsigned int    attrAddress;

uint16          emuTsLine[192];
uint8           emuDisplayTsTable[313][225];
unsigned int    emuCurrentFrameTs;

//*** Audio
double          audioBeeperValue;
int             audioEar;
int             audioMic;
int             audioSampleRate;
//double          soundLevel[4]={0.39/3.79, 0.77/3.79, 3.66/3.79, 3.79/3.79};
int             audioBufferIndex;
int             audioTStates;
int             audioTsCounter;
double          audioTsStepCounter;
double          audioTsStep;
int             audioBufferSize;

bool            showDebug;

// Events
typedef enum : NSUInteger {
    None,
    Reset,
    Snapshot,
    Z80Snapshot
} EventType;

EventType event;

// Pallette
PixelData pallette[] = {
  
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

// Keyboard matrix data
static unsigned char keyboardMap[8];

#pragma mark - Implementation

@implementation ZXSpectrum48

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController
{
    self = [super init];
    if (self)
    {
        _emulationViewController = emulationViewController;
        
        core = new CZ80Core;
        core->Initialise(coreMemoryRead, coreMemoryWrite, coreIORead, coreIOWrite, coreMemoryContention, coreIOContention, 0);
        
        event = None;

        borderColour = 7;
        frameCounter = 0;
        
        _colourSpace = CGColorSpaceCreateDeviceRGB();

        pxTopBorder = 56;
        pxVerticalBlank = 8;
        pxHorizontalDisplay = 256;
        pxVerticalDisplay = 192;
        pxHorizontalTotal = 448;
        pxVerticalTotal = 312;
        
        tsPerFrame = kTstatesPerFrame;
        tsPerLine = 224;
        tsTopBorder = pxTopBorder * tsPerLine;
        tsVerticalBlank = pxVerticalBlank * tsPerLine;
        tsVerticalDisplay = pxVerticalDisplay * tsPerLine;
        tsHorizontalDisplay = 128;
        tsPerChar = 4;
        tsToOrigin = 14335;
        
        emuShouldInterpolate = NO;
        emuDisplayBitsPerPx = 32;
        emuDisplayBitsPerComponent = 8;
        emuDisplayBytesPerPx = 4;
        
        emuLeftBorderPx = 32;
        emuRightBorderPx = 64;
        
        emuBottomBorderPx = 56;
        emuTopBorderPx = 56;
        
        emuDisplayPxWidth = 256 + emuLeftBorderPx + emuRightBorderPx;
        emuDisplayPxHeight = 192 + emuTopBorderPx + emuBottomBorderPx;

        emuHScale = 1.0 / emuDisplayPxWidth;
        emuVScale = 1.0 / emuDisplayPxHeight;
        
        emuDisplayTs = 0;
        
        [self resetFrame];
        
        // Setup the display buffer and length used to store the output from the emulator
        emuDisplayBufferLength = (emuDisplayPxWidth * emuDisplayPxHeight) * emuDisplayBytesPerPx;
        emuDisplayBuffer = (unsigned char *)malloc(emuDisplayBufferLength);

        _emulationQueue = dispatch_queue_create("emulationQueue", nil);

        float fps = 50;
        
        audioSampleRate = 192000;
        audioBufferSize = (audioSampleRate / fps) * 6;
        _audioBuffer = (int16_t *)malloc(audioBufferSize);
        audioTsStep = tsPerFrame / (audioSampleRate / fps);
        
        [self resetSound];
        [self buildContentionTable];
        [self buildScreenLineAddressTable];
        [self buildDisplayTsTable];
        [self resetKeyboardMap];
        [self loadDefaultROM];
        
        _audioCore = [[AudioCore alloc] initWithSampleRate:audioSampleRate
                                           framesPerSecond:fps
                                            emulationQueue:_emulationQueue
                                                   machine:self];
        
        [self setupObservers];
    }
    return self;
}

#pragma mark - Binding

- (void)setupObservers
{
    [self addObserver:_audioCore forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:_audioCore forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:_audioCore forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
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

#pragma mark - Reset

- (void)reset
{
    frameCounter = 0;
    [self resetKeyboardMap];
    [self resetSound];
    [self resetFrame];
    core->Reset();
}

- (void)resetSound
{
    memset(_audioBuffer, 0, audioBufferSize);
    audioBufferIndex = 0;
    audioTsCounter = 0;
    audioTsStepCounter = 0;
    audioBeeperValue = 0;
}

- (void)resetFrame
{
    // Reset display
    emuDisplayBufferIndex = 0;
    emuDisplayTs = 16;
    
    // Reset audio
    audioBufferIndex = 0;
    audioTsCounter = 0;
    audioTsStepCounter = 0;
}

#pragma mark - CPU

- (void)generateFrame
{
    int count = tsPerFrame;
    while (count > 0)
    {
        count -= [self step];
    }
}

- (int)step
{
    int tsCPU = core->Execute(1, 32);
    
    [self updateAudioWithTStates:tsCPU];

    if (core->GetTStates() >= tsPerFrame )
    {
        updateScreenWithTStates(tsPerFrame - emuDisplayTs);
        
        core->ResetTStates( tsPerFrame );
        core->SignalInterrupt();
        
        // Adjust how much of the full texture is to be displayed based on the defined border width
        CGRect textureRect = CGRectMake((32 - self.displayBorderWidth) * emuHScale,
                                        (56 - self.displayBorderWidth) * emuVScale,
                                        1.0 - ((32 - self.displayBorderWidth) * emuHScale + ((64 - self.displayBorderWidth) * emuHScale)),
                                        1.0 - (((56 - self.displayBorderWidth) * emuVScale) * 2));

        // Update the display texture using the data from the emulator display buffer
        CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, emuDisplayBuffer, emuDisplayBufferLength);
        
        self.texture = [SKTexture textureWithData:(__bridge NSData *)dataRef
                                             size:CGSizeMake(emuDisplayPxWidth, emuDisplayPxHeight)
                                          flipped:YES];
        
        CFRelease(dataRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.emulationViewController updateEmulationDisplayTextureWithImage:[SKTexture textureWithRect:textureRect
                                                                                                  inTexture:self.texture]];
        });

        frameCounter++;
    }
    
    return tsCPU;
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

#pragma mark - Audio

- (void)updateAudioWithTStates:(int)numberTs
{
    // Loop over each tState so that the necessary audio samples can be generated
    for(int i = 0; i < numberTs; i++)
    {
        // Grab the current state of the audio ear output
        double beeperLevel = audioEar;
        
        // If we have done more cycles now than the audio step counter, generate a new sample
        if (audioTsCounter++ >= audioTsStepCounter)
        {
            // Quantize the value loaded into the audio buffer e.g. if cycles = 19 and step size is 18.2
            // 0.2 of the beeper value goes into this sample and 0.8 goes into the next sample
            double delta1 = fabs(audioTsStepCounter - (audioTsCounter - 1));
            double delta2 = (1 - delta1);
            
            // Quantize for the current sample
            audioBeeperValue += (beeperLevel * delta1);
            
            // Load the buffer with the sample for both left and right channels
            _audioBuffer[ audioBufferIndex++ ] = (int16_t)(audioBeeperValue * 512);
            _audioBuffer[ audioBufferIndex++ ] = (int16_t)(audioBeeperValue * 512);
            
            // Quantize for the next sample
            audioBeeperValue = (beeperLevel * delta2);
            
            // Increment the step counter so that the next sample will be taken after another 18.2 T-States
            audioTsStepCounter += audioTsStep;
        }
        else
        {
            audioBeeperValue += beeperLevel;
        }
    }
}

#pragma mark - Display

static void updateScreenWithTStates(int numberTs)
{
    while (numberTs > 0)
    {
        int line = emuDisplayTs / tsPerLine;
        int ts = emuDisplayTs % tsPerLine;
        
        switch (emuDisplayTsTable[line][ts]) {
            case kDisplayRetrace:
                break;
                
            case kDisplayBorder:
                for (int i = 0; i < 8; i++)
                {
                    emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[borderColour].r;
                    emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[borderColour].g;
                    emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[borderColour].b;
                    emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[borderColour].a;
                    
                    if (line < 64 && showDebug)
                    {
                        NSLog(@"%i", borderColour);
                    }
                }
                break;
                
            case kDisplayPaper:
            {
                int y = line - 64;
                int x = (ts >> 2) - 4;
                
                uint pixelAddress = kBitmapAddress + emuTsLine[y] + x;
                uint attributeAddress = kAttributeAddress + ((y >> 3) << 5) + x;
                
                int pixelByte = memory[pixelAddress];
                int attributeByte = memory[attributeAddress];
                
                // Extract the ink and paper colours from the attribute byte read in
                int ink = (attributeByte & 0x07) + ((attributeByte & 0x40) >> 3);
                int paper = ((attributeByte >> 3) & 0x07) + ((attributeByte & 0x40) >> 3);
                
                // Switch ink and paper if the flash phase has changed
                if ((frameCounter & 16) && (attributeByte & 0x80))
                {
                    int tempPaper = paper;
                    paper = ink;
                    ink = tempPaper;
                }
                
                for (int b = 0x80; b; b >>= 1)
                {
                    if (pixelByte & b) {
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[ink].r;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[ink].g;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[ink].b;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[ink].a;
                    }
                    else
                    {
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[paper].r;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[paper].g;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[paper].b;
                        emuDisplayBuffer[emuDisplayBufferIndex++] = pallette[paper].a;
                    }
                }
                break;
            }
            
            default:
                break;
        }

        emuDisplayTs += tsPerChar;

        numberTs -= tsPerChar;
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
    for(int line = 0; line < 312; line++)
    {
        for(int ts = 0 ; ts < tsPerLine; ts++)
        {
            if (line >= 0  && line < 8)
            {
                emuDisplayTsTable[line][ts] = kDisplayRetrace;
            }
            
            if (line >= 8  && line < 64)
            {
                if (ts >= 176 && ts < 224)
                {
                    emuDisplayTsTable[line][ts] = kDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
            }
            
            if (line >= (pxVerticalBlank + pxTopBorder + pxVerticalDisplay) && line < 312)
            {
                if (ts >= 176 && ts < 224)
                {
                    emuDisplayTsTable[line][ts] = kDisplayRetrace;
                }
                else
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
            }
            
            if (line >= 64 && line < (8 + 56 + 192))
            {
                if ((ts >= 0 && ts < 16) || (ts >= 144 && ts < 176))
                {
                    emuDisplayTsTable[line][ts] = kDisplayBorder;
                }
                else if (ts >= 176 && ts < 224)
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

#pragma mark - Memory & IO methods

static unsigned char coreMemoryRead(unsigned short address, int tstates)
{
    return memory[address];
}

static void coreMemoryWrite(unsigned short address, unsigned char data, int tstates)
{

    if (address < 16384)
    {
        return;
    }
    updateScreenWithTStates(core->GetTStates() + 16 - emuDisplayTs);
    memory[address] = data;
}

static unsigned char coreIORead(unsigned short address, int tstates)
{
    // Calculate the necessary contention based on the Port number being accessed and if the port belongs to the ULA.
    // All non-even port numbers below to the ULA. N:x means no contention to be added and just advance the tStates.
    // C:x means that contention should be calculated based on the current tState value and then x tStates are to be
    // added to the current tState count
    //
    // in 40 - 7F?| Low bit | Contention pattern
    //------------+---------+-------------------
    //		No    |  Reset  | N:1, C:3
    //		No    |   Set   | N:4
    //		Yes   |  Reset  | C:1, C:3
    //		Yes   |   Set   | C:1, C:1, C:1, C:1
    //
    if (address >= 16384 && address <= 32767)
    {
        if ((address & 1) == 0)
        {
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
        }
    } else {
        if ((address & 1) == 0)
        {
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddTStates(4);
        }
    }
    
    // If the address does not belong to the ULA then return the floating bus value
    if (address & 0x01)
    {
        // TODO: Add Kemptston joystick support. Until then return 0
        if ((address & 0xff) == 0x1f)
        {
            return 0x0;
        }
        
        return floatingBus();
    }
    
    // Default return value
    __block int result = 0xff;
    
    // Check to see if any keys have been pressed
    for (int i = 0; i < 8; i++)
    {
        if (!(address & (0x100 << i)))
        {
            result &= keyboardMap[i];
        }
    }
    
    return result;
}

static void coreIOWrite(unsigned short address, unsigned char data, int tstates)
{
    // Calculate the necessary contention based on the Port number being accessed and if the port belongs to the ULA.
    // All non-even port numbers below to the ULA. N:x means no contention to be added and just advance the tStates.
    // C:x means that contention should be calculated based on the current tState value and then x tStates are to be
    // added to the current tState count
    //
    // in 40 - 7F?| Low bit | Contention pattern
    //------------+---------+-------------------
    //		No    |  Reset  | N:1, C:3
    //		No    |   Set   | N:4
    //		Yes   |  Reset  | C:1, C:3
    //		Yes   |   Set   | C:1, C:1, C:1, C:1
    //
    if (address >= 16384 && address <= 32767)
    {
        if ((address & 1) == 0)
        {
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(3);
        }
        else
        {
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
            core->AddTStates(1);
        }
    }
    else
    {
        if ((address & 1) == 0)
        {
            core->AddTStates(1);
            core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
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
        updateScreenWithTStates(core->GetTStates() - emuDisplayTs + 14);

        audioEar = (data & 0x10) >> 4;
        audioMic = (data & 0x08) >> 3;
        borderColour = data & 0x07;
    }
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, int param)
{
    if (address >= 16384 && address <= 32767)
    {
        core->AddContentionTStates( memoryContentionTable[core->GetTStates() % tsPerFrame] );
    }
}

static void coreIOContention(unsigned short address, unsigned int tstates, int param)
{
    // NOT USED
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
                memoryContentionTable[i] = contentionValues[ ts & 0x07 ];
                ioContentionTable[i] = contentionValues[ ts & 0x07 ];
            }
        }
    }
}

#pragma mark - Floating Bus

// When the Z80 reads from an unattached port, such as 0xFF, it actually reads the data currently on the
// Spectrums ULA data bus. This may happen to be a byte being transferred from screen memory. If the ULA
// is building the border then the bus is idle and the return value is 0xFF, otherwise its possible to
// predict if the ULA is reading a pixel or attribute byte based on the current t-state.
// This routine works out what would be on the ULA bus for a given t-state and returns the result
static unsigned char floatingBus()
{
    int cpuTs = core->GetTStates() - 1;
    int currentDisplayLine = (cpuTs / tsPerLine);
    int currentTs = (cpuTs % tsPerLine);

    // If the line and tState are within the bitmap of the screen then grab the
    // pixel or attribute value
    if (currentDisplayLine >= (pxTopBorder + pxVerticalBlank)
        && currentDisplayLine < (pxTopBorder + pxVerticalBlank + pxVerticalDisplay)
        && currentTs <= tsHorizontalDisplay)
    {
        unsigned char ulaValueType = floatingBusTable[ currentTs & 0x07 ];
        
        int y = currentDisplayLine - (pxTopBorder + pxVerticalBlank);
        int x = currentTs >> 2;
        
        if (ulaValueType == Pixel)
        {
            return memory[kBitmapAddress + emuTsLine[y] + x];
        }
        
        if (ulaValueType == Attribute)
        {
            return memory[kAttributeAddress + ((y >> 3) << 5) + x];
        }
    }
    
    return 0xff;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ZXSpectrum48k" ofType:@"rom"];
    NSData *rom = [NSData dataWithContentsOfFile:path];
    
    const char *fileBytes = (const char*)[rom bytes];
    
    for (int addr = 0; addr < rom.length; addr++)
    {
        memory[addr] = fileBytes[addr];
    }
}

#pragma mark - SnapShot

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

- (void)loadSnapshot
{
    NSData *data = [NSData dataWithContentsOfFile:self.snapshotPath];
    
    const char *fileBytes = (const char*)[data bytes];
    
    if (data.length == 49179)
    {
        int snaAddr = 27;
        for (int i= 16384; i < (48 * 1024) + 16384; i++)
        {
            memory[i] = fileBytes[snaAddr++];
        }
        
        // Decode the header
        core->SetRegister(CZ80Core::eREG_I, fileBytes[0]);
        core->SetRegister(CZ80Core::eREG_R, fileBytes[20]);
        core->SetRegister(CZ80Core::eREG_ALT_HL, ((unsigned short *)&fileBytes[1])[0]);
        core->SetRegister(CZ80Core::eREG_ALT_DE, ((unsigned short *)&fileBytes[1])[1]);
        core->SetRegister(CZ80Core::eREG_ALT_BC, ((unsigned short *)&fileBytes[1])[2]);
        core->SetRegister(CZ80Core::eREG_ALT_AF, ((unsigned short *)&fileBytes[1])[3]);
        core->SetRegister(CZ80Core::eREG_HL, ((unsigned short *)&fileBytes[1])[4]);
        core->SetRegister(CZ80Core::eREG_DE, ((unsigned short *)&fileBytes[1])[5]);
        core->SetRegister(CZ80Core::eREG_BC, ((unsigned short *)&fileBytes[1])[6]);
        core->SetRegister(CZ80Core::eREG_IY, ((unsigned short *)&fileBytes[1])[7]);
        core->SetRegister(CZ80Core::eREG_IX, ((unsigned short *)&fileBytes[1])[8]);
        
        core->SetRegister(CZ80Core::eREG_AF, ((unsigned short *)&fileBytes[21])[0]);
        core->SetRegister(CZ80Core::eREG_SP, ((unsigned short *)&fileBytes[21])[1]);
        
        // Border colour
        borderColour = fileBytes[26] & 0x07;
        
        // Set the IM
        core->SetIMMode(fileBytes[25]);
        
        // Do both on bit 2 as a RETN copies IFF2 to IFF1
        core->SetIFF1((fileBytes[19] >> 2) & 1);
        core->SetIFF2((fileBytes[19] >> 2) & 1);
        
        // Set the PC
        unsigned char pc_lsb = memory[core->GetRegister(CZ80Core::eREG_SP)];
        unsigned char pc_msb = memory[core->GetRegister(CZ80Core::eREG_SP) + 1];
        core->SetRegister(CZ80Core::eREG_PC, (pc_msb << 8) | pc_lsb);
        core->SetRegister(CZ80Core::eREG_SP, core->GetRegister(CZ80Core::eREG_SP) + 2);
        
        [self resetSound];
        [self resetKeyboardMap];
        [self resetFrame];
    }
}


- (void)loadZ80Snapshot
{

    NSData *data = [NSData dataWithContentsOfFile:self.snapshotPath];
    const char *fileBytes = (const char*)[data bytes];
    
    BOOL version1 = YES;
    
    // Decode the header
    core->SetRegister(CZ80Core::eREG_A, (unsigned char)fileBytes[0]);
    core->SetRegister(CZ80Core::eREG_F, (unsigned char)fileBytes[1]);
    core->SetRegister(CZ80Core::eREG_BC, ((unsigned short *)&fileBytes[2])[0]);
    core->SetRegister(CZ80Core::eREG_HL, ((unsigned short *)&fileBytes[2])[1]);
    
    unsigned short pc = ((unsigned short *)&fileBytes[6])[0];
    
    // Zero means it is a Version 2/3 snapshot
    if (pc == 0)
    {
        version1 = NO;
        pc = ((unsigned short *)&fileBytes[32])[0];
    }
    core->SetRegister(CZ80Core::eREG_PC, pc);
    
    NSLog(@"PC: %#2x", pc);
    
    core->SetRegister(CZ80Core::eREG_SP, ((unsigned short *)&fileBytes[8])[0]);
    core->SetRegister(CZ80Core::eREG_I, (unsigned char)fileBytes[10]);
    core->SetRegister(CZ80Core::eREG_R, (fileBytes[11] & 127) | ((fileBytes[12] & 1) << 7));
    
    // Info byte 12
    unsigned char byte12 = fileBytes[12];
    borderColour = (fileBytes[12] & 14) >> 1;
    BOOL compressed = fileBytes[12] & 32;

    NSLog(@"RB7: %i Border: %i SamRom: %i Compressed: %i", byte12 & 1, (byte12 & 14) >> 1, byte12 & 16, byte12 & 32);
    
    core->SetRegister(CZ80Core::eREG_DE, ((unsigned short *)&fileBytes[13])[0]);
    core->SetRegister(CZ80Core::eREG_ALT_BC, ((unsigned short *)&fileBytes[13])[1]);
    core->SetRegister(CZ80Core::eREG_ALT_DE, ((unsigned short *)&fileBytes[13])[2]);
    core->SetRegister(CZ80Core::eREG_ALT_HL, ((unsigned short *)&fileBytes[13])[3]);
    core->SetRegister(CZ80Core::eREG_ALT_A, (unsigned char)fileBytes[21]);
    core->SetRegister(CZ80Core::eREG_ALT_F, (unsigned char)fileBytes[22]);
    core->SetRegister(CZ80Core::eREG_IY, ((unsigned short *)&fileBytes[23])[0]);
    core->SetRegister(CZ80Core::eREG_IX, ((unsigned short *)&fileBytes[23])[1]);
    core->SetIFF1((unsigned char)fileBytes[27] & 1);
    core->SetIFF2((unsigned char)fileBytes[28] & 1);
    core->SetIMMode((unsigned char)fileBytes[29] & 3);

    NSLog(@"IFF1: %i IM Mode: %i", (unsigned char)fileBytes[27] & 1, (unsigned char)fileBytes[29] & 3);
    
    // Deal with the extra data available in version 2 & 3 formats
    if (version1)
    {
        NSLog(@"Z80 Snapshot Version 1");
        [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:30 compressed:compressed unpackedLength:49152];
    }
    else
    {
        NSLog(@"Z80 Snapshot Version 2");
       
        int16_t additionHeaderBlockLength = 0;
        additionHeaderBlockLength = ((unsigned short *)&fileBytes[30])[0];
        int offset = 32 + additionHeaderBlockLength;
        
        while (offset < data.length)
        {
            int compressedLength = ((unsigned short *)&fileBytes[offset])[0];
            BOOL isCompressed = YES;
            if (compressedLength == 65535)
            {
                compressedLength = 16384;
                isCompressed = NO;
            }
            
            int pageId = fileBytes[offset + 2];
         
            switch (pageId) {
                case 4:
                    [self extractMemoryBlock:fileBytes memAddr:32768 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                case 5:
                    [self extractMemoryBlock:fileBytes memAddr:49152 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                case 8:
                    [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                default:
                    break;
            }
            
            offset += compressedLength + 3;
        }
    }
    
    [self resetSound];
    [self resetKeyboardMap];
    [self resetFrame];

}

- (void)extractMemoryBlock:(const char*)fileBytes memAddr:(int)memAddr fileOffset:(int)fileOffset compressed:(BOOL)isCompressed unpackedLength:(int)unpackedLength
{
    int filePtr = fileOffset;
    int memoryPtr = memAddr;
    
    if (!isCompressed)
    {
        while (memoryPtr < unpackedLength + memAddr)
        {
            memory[memoryPtr++] = fileBytes[filePtr++];
        }
    }
    else
    {
        while (memoryPtr < unpackedLength + memAddr)
        {
            unsigned char byte1 = fileBytes[filePtr];
            unsigned char byte2 = fileBytes[filePtr + 1];
            
            if ((unpackedLength + memAddr) - memoryPtr >= 2 &&
                byte1 == 0xed &&
                byte2 == 0xed)
            {
                unsigned char count = fileBytes[filePtr + 2];
                unsigned char value = fileBytes[filePtr + 3];
                for (int i = 0; i < count; i++)
                {
                    memory[memoryPtr++] = value;
                }
                filePtr += 4;
            }
            else
            {
                memory[memoryPtr++] = fileBytes[filePtr++];
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

- (void)setDebug:(BOOL)debug
{
    _debug = debug;
    showDebug = debug;
}
@end
