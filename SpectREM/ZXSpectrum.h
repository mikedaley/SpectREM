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
#import "AudioCore.h"
#import "EmulationViewController.h"

#pragma mark - Constants

static int const kDisplayBorder = 1;
static int const kDisplayPaper = 2;
static int const kDisplayRetrace = 3;

static int const kBitmapAddress = 16384;
static int const kBitmapSize = 6144;

static int const tsPerLine = 224;
static int const tsTopBorder = 56 * 224;
static int const tsVerticalBlank = 8 * 224;
static int const tsVerticalDisplay = 192 * 224;
static int const tsHorizontalDisplay = 128;
static int const tsPerChar = 4;

static int const emuDisplayBitsPerPx = 32;
static int const emuDisplayBitsPerComponent = 8;
static int const emuDisplayBytesPerPx = 4;

static int const pxTopBorder = 56;
static int const pxVerticalBlank = 8;
static int const pxHorizontalDisplay = 256;
static int const pxVerticalDisplay = 192;
static int const pxHorizontalTotal = 448;
static int const pxVerticalTotal = 312;

static int const emuLeftBorderPx = 32;
static int const emuRightBorderPx = 64;

static int const emuBottomBorderPx = 56;
static int const emuTopBorderPx = 56;

static int const emuDisplayPxWidth = 256 + emuLeftBorderPx + emuRightBorderPx;
static int const emuDisplayPxHeight = 192 + emuTopBorderPx + emuBottomBorderPx;


// Memory and IO contention tables
static unsigned char const contentionValues[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };

// Floating bus
static unsigned char const floatingBusTable[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };

#pragma mark - Type Definitions

typedef NS_ENUM(NSUInteger, EventType)
{
    None,
    Reset,
    Snapshot,
    Z80Snapshot
};

typedef NS_ENUM(NSUInteger, FloatingBusValueType)
{
    Pixel = 1,
    Attribute = 2
};

#pragma mark - Interface

@interface ZXSpectrum : NSObject <KeyboardEventProtocol>
{    
    // Main Memory array
    // TODO: Break memory up into 16k banks. This will be needed for 128k machines
    unsigned char *memory;
    unsigned char *rom;
    
    int currentROMPage;
    int currentRAMPage;
    BOOL disablePaging;
    int displayPage;
    
    // Keyboard matrix data
    unsigned char keyboardMap[8];
    
    // Machine specific tState values
    int tsPerFrame;
    int tsToOrigin;
    
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
    int             borderColour;
    
    // Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
    // in the current frame so that the right number of 8x1 screen chunks are drawn
    int             emuDisplayTs;

    // Used to track the flash phase
    int             frameCounter;
    
    //*** Audio
    double          audioBeeperValue;
    int             audioEar;
    int             audioMic;
    int             audioSampleRate;
    int             audioBufferIndex;
    int             audioTStates;
    int             audioTsCounter;
    double          audioTsStepCounter;
    double          audioTsStep;
    int             audioBufferSize;
    
    EventType       event;
    
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
@property (strong) NSString *snapshotPath;

@property (weak) EmulationViewController *emulationViewController;
@property (assign) CGColorSpaceRef colourSpace;
@property (strong) id imageRef;
@property (strong) SKTexture *texture;

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

void updateScreenWithTStates(int numberTs, void *m);

@end
