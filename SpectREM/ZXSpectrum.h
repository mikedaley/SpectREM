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

static int const cDisplayBorder = 1;
static int const cDisplayPaper = 2;
static int const cDisplayRetrace = 3;

static int const cBitmapAddress = 16384;
static int const cBitmapSize = 6144;

static int const cEmuDisplayBitsPerPx = 32;
static int const cEmuDisplayBitsPerComponent = 8;
static int const cEmuDisplayBytesPerPx = 4;

static int const cAudioBeeperVolumeMultiplier = 512;

static int const cBorderDrawingOffset = 10;
static int const cPaperDrawingOffset = 16;

static unsigned char const cContentionValues[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };
static unsigned char const cFloatingBusTable[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };

#pragma mark - Structures

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
    double audioBeeperLeft;
    double audioBeeperRight;
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
@property (assign) short *audioBuffer;

// Reference to the audio core instance
@property (strong) AudioCore *audioCore;

// Queue on which the emulation is run
@property (strong) dispatch_queue_t emulationQueue;

@property (assign) float displayBorderWidth;
@property (assign) float soundVolume;
@property (assign) double soundLowPassFilter;
@property (assign) double soundHighPassFilter;
@property (assign) BOOL AYChannelA;
@property (assign) BOOL AYChannelB;
@property (assign) BOOL AYChannelC;
@property (assign) float AYChannelABalance;
@property (assign) float AYChannelBBalance;
@property (assign) float AYChannelCBalance;

@property (strong) NSString *corePC;

@property (strong) NSString *snapshotPath;

@property (weak) EmulationViewController *emulationViewController;
@property (strong) SKTexture *texture;
@property (strong) SKTexture *memoryTexture;

@property (strong) id imageRef;
@property (assign) CGColorSpaceRef colorSpace;

@property (assign) bool stepping;

#pragma mark - Methods

/**
Initialises the machine which then references the EmulationViewController provided to display the emulation output
 */
- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController;

/**
Starts the machines audio core callback which is used to generate a frame request 50x per second
 */
- (void)start;

/**
Stops the machines audio core callback which stops the machine from running
 */
- (void)stop;

/**
Resets the machine by resetting the keyboard map, resetting the sound variables and resetting the frame variables
 */
- (void)reset;

/**
Resets the frame variables to the start of a frame
 */
- (void)resetFrame;

/**
Clears the audio buffer and resets the audio counter variables
 */
- (void)resetSound;

/**
Do frame is called by the audio callback 50x per second. This method checks for any outstanding events such as resetting the machine or loading a snapshot file. Once these events have been performed it then calls the GenerateFrame method to generate a new frame.
 */
- (void)doFrame;

/**
Causes the machine to generate an entire frame. A frame is defined as being n tStates in length e.g. for a 48k machine this value is 69888.
 */
- (void)generateFrame;

/**
Resets the keyboard map buffer so that any current keypresses are removed
 */
- (void)resetKeyboardMap;

/**
Builds a tState table that identifies what screen activity should be happening based on the tstate vlaue e.g retrace, border or pixel drawing
 */
- (void)buildDisplayTsTable;

/**
Builds a table that contains the memory address for the start of each pixel line on screen
 */
- (void)buildScreenLineAddressTable;

/**
Builds a memory contention table that identifies the number of tStates that should be added to a memory read/write instruction when the memory address is within memory addresses used by the ULA e.g. the screen.
 */
- (void)buildContentionTable;

/**
Loads an SNA based snapshot file with the path provided
 */
- (void)loadSnapshotWithPath:(NSString *)path;- (void)loadSnapshot;

/**
 Loads a Z80 based snapshot file with the path provided
 */
- (void)loadZ80Snapshot;

/**
Sets up observers between the machine and the audio core
 */
- (void)setupObservers;

/**
Returns a reference to the Z80 core being used inside the machine
 */
- (void *)getCore;

/**
Updates the screen buffer based on the number of tStates that have passed in the current frame
 */
void updateScreenWithTStates(int numberTs, void *m);

/**
Updates the audio buffer for both the beeper and AY chip based on the number of tStates that have passed in the current frame
 */
void updateAudioWithTStates(int tsCPU, void *m, bool ay);

@end
