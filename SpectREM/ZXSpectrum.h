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
static int const kAttributeAddress = kBitmapAddress + kBitmapSize;

static int const tsPerLine = 224;
static int const tsTopBorder = 56 * 224;
static int const tsVerticalBlank = 8 * 224;
static int const tsVerticalDisplay = 192 * 224;
static int const tsHorizontalDisplay = 128;
static int const tsPerChar = 4;

static int const emuDisplayBitsPerPx = 32;
static int const emuDisplayBitsPerComponent = 8;
static int const emuDisplayBytesPerPx = 4;

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
    
    // Keyboard matrix data
    unsigned char keyboardMap[8];
    
    // Machine specific tState values
    int tsPerFrame;
    int tsToOrigin;
    
    // Machine specific pixel values
    int pxTopBorder;
    int pxVerticalBlank;
    int pxHorizontalDisplay;
    int pxVerticalDisplay;
    int pxHorizontalTotal;
    int pxVerticalTotal;
    
    uint16 emuTsLine[192];
    uint8 emuDisplayTsTable[313][225];

    // Image buffer array buffer, its length and current index into the buffer used when drawing
    unsigned char *emuDisplayBuffer;
    unsigned int emuDisplayBufferLength;
    unsigned int emuDisplayBufferIndex;
    
    // Details for the image that is created for the screen representation

    bool emuShouldInterpolate;
    
    // Width and height of the image used to display the emulated screen
    int  emuDisplayPxWidth;
    int  emuDisplayPxHeight;
    
    // Width of the left and right border in chars. A char is 8 pixels wide
    int  emuLeftBorderPx;
    int  emuRightBorderPx;
    
    // Height of the top and bottom borders in pixel lines
    int  emuTopBorderPx;
    int  emuBottomBorderPx;
    
    float emuHScale;
    float emuVScale;
    
    // Holds the current pixel and attribute line addresses when rendering the screen
//    unsigned int    pixelAddress;
//    unsigned int    attrAddress;
    
    unsigned int    emuCurrentFrameTs;
    
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

#pragma mark - Methods

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController;
- (void)start;
- (void)reset;
- (void)loadSnapshotWithPath:(NSString *)path;
- (void)doFrame;
- (void)resetKeyboardMap;
- (void)buildDisplayTsTable;
- (void)buildScreenLineAddressTable;

void updateScreenWithTStates(int numberTs, void *m);

@end
