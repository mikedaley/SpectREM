//
//  ZXSpectrum.h
//  SpectREM
//
//  Created by Mike Daley on 26/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "KeyboardEventProtocol.h"
#import "EmulationViewController.h"
#import "AudioCore.h"

#pragma mark - Constants

#define AY 1

static int const kDisplayBorder = 1;
static int const kDisplayPaper = 2;
static int const kDisplayRetrace = 3;

static int const kBitmapAddress = 16384;
static int const kBitmapSize = 6144;

static int const emuDisplayBitsPerPx = 32;
static int const emuDisplayBitsPerComponent = 8;
static int const emuDisplayBytesPerPx = 4;

static int const audioBeeperVolumeMultiplier = 384;
static int const audioAYVolumeMultiplier = 256;

// Memory and IO contention tables
static unsigned char const contentionValues[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };

// Floating bus
static unsigned char const floatingBusTable[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };

// Structure of pixel data used in the emulation display buffer
struct PixelData {
    uint8 r;
    uint8 g;
    uint8 b;
    uint8 a;
};

// Pallette
static struct PixelData pallette[] = {
    
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

#pragma mark - Type Definitions

typedef NS_ENUM(NSUInteger, EventType)
{
    eNone,
    eReset,
    eSnapshot,
    eZ80Snapshot
};

typedef NS_ENUM(NSUInteger, FloatingBusValueType)
{
    ePixel = 1,
    eAttribute = 2
};

#pragma mark - Interface

@interface ZXSpectrum : NSObject <KeyboardEventProtocol>
{
@public
    // Main RAM and ROM for the 48k and 128k
    unsigned char *memory;
    unsigned char *rom;
    
    // 128k paging
    int currentROMPage;
    int currentRAMPage;
    BOOL disablePaging;
    int displayPage;
    
    // Keyboard matrix data
    unsigned char keyboardMap[8];
    
    // Machine specific tState and pixel values
    int tsPerFrame;
    int tsToOrigin;
    int tsPerLine;
    int tsTopBorder;
    int tsVerticalBlank;
    int tsVerticalDisplay;
    int tsHorizontalDisplay;
    int tsPerChar;
    
    int pxTopBorder;
    int pxVerticalBlank;
    int pxHorizontalDisplay;
    int pxVerticalDisplay;
    int pxHorizontalTotal;
    int pxVerticalTotal;
    
    // Emulation display sizes
    int emuLeftBorderPx;
    int emuRightBorderPx;
    int emuBottomBorderPx;
    int emuTopBorderPx;
    int emuDisplayPxWidth;
    int emuDisplayPxHeight;

    uint16 emuTsLine[192];
    uint8 emuDisplayTsTable[313][225];

    // Image buffer array buffer, its length and current index into the buffer used when drawing
    unsigned char *emuDisplayBuffer;
    unsigned int emuDisplayBufferLength;
    unsigned int emuDisplayBufferIndex;
    
    bool emuShouldInterpolate;
    
    float emuHScale;
    float emuVScale;
    
    // Holds the current border colour as set by the ULA
    int borderColour;
    
    // Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
    // in the current frame so that the right number of 8x1 screen chunks are drawn
    int emuDisplayTs;

    // Used to track the flash phase
    int frameCounter;
    
    // Audio
    double audioBeeperValue;
    int audioEar;
    int audioMic;
    int audioSampleRate;
    int audioBufferIndex;
    int audioTStates;
    int audioTsCounter;
    double audioTsStepCounter;
    double audioTsStep;
    int audioBufferSize;
    int audioAYTStates;
    int audioAYTStatesStep;
    
    EventType event;
    
    unsigned char memoryContentionTable[80000];
    unsigned char ioContentionTable[80000];
}

#pragma mark - Properties


// Buffer used to hold the sound samples generated for each emulation frame
@property (assign) int16_t *audioBuffer;

// Reference to the audio core instance
@property (strong) AudioCore *audioCore;

// Queue on which the emulation is run
@property (strong) dispatch_queue_t emulationQueue;

@property (assign) float displayBorderWidth;
@property (assign) float soundVolume;
@property (assign) double soundLowPassFilter;
@property (assign) double soundHighPassFilter;
@property (assign) BOOL AYChannel1;
@property (assign) BOOL AYChannel2;
@property (assign) BOOL AYChannel3;

@property (strong) NSString *corePC;

@property (strong) NSString *snapshotPath;

@property (weak) EmulationViewController *emulationViewController;
@property (strong) SKTexture *texture;

@property (strong) id imageRef;
@property (assign) CGColorSpaceRef colorSpace;

#pragma mark - Methods

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController;
- (void)start;
- (void)stop;
- (void)reset;
- (void)resetFrame;
- (void)resetSound;
- (void)loadSnapshotWithPath:(NSString *)path;
- (void)generateFrame;
- (void)doFrame;
- (void)resetKeyboardMap;
- (void)buildDisplayTsTable;
- (void)buildScreenLineAddressTable;
- (void)loadSnapshot;
- (void)loadZ80Snapshot;
- (void)setupObservers;
- (void)buildContentionTable;

void updateScreenWithTStates(int numberTs, void *m);
void updateAudioWithTStates(int tsCPU, void *m);

@end
