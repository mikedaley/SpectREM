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
#import "MachineDetails.h"
#import "ZXTape.h"
#import "PixelData.h"

#pragma mark - Constants

// Commonly used memory addresses
static int const cBitmapAddress = 16384;
static int const cBitmapSize = 6144;

// Used to increase the volume of the beeper output. Too high and the output is clipped
static int const cAudioBeeperVolumeMultiplier = 48;

// Sampled rate used to drive the update frequency in the audio engine which is then used to generate new frames e.g. 50.08 fps
static int const cAudioSampleRate = 192000;

// Static values used when building the contention and floating bus tables
static unsigned char const cContentionValues[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };
static unsigned char const cFloatingBusTable[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };

// Number of frames to skip when running in accelerated mode
static int const cAcceleratedSkipFrames = 10;

#pragma mark - Type Definitions

// Defines an enum for each type of display action used when drawing the screen
typedef NS_ENUM(NSUInteger, DisplayAction)
{
    eDisplayBorder = 1,
    eDisplayPaper,
    eDisplayRetrace
};

// Defines an enum for each event type that can be encountered
typedef NS_ENUM(NSUInteger, EventType)
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

static NS_ENUM(NSUInteger, MachineType)
{
    eZXSpectrum48 = 0,
    eZXSpectrum128,
    eZXSpectrumSE
};

#pragma mark - Interface

@class SerialCore;

@interface ZXSpectrum : NSObject <KeyboardEventProtocol>
{
@public
    // Main RAM and ROM for the 48k and 128k
    unsigned char *memory;
    unsigned char *rom;
    
    // Multiface ROM
    unsigned char *multifaceMemory;
    
    // 128k paging
    int currentROMPage;
    int currentRAMPage;
    BOOL disablePaging;
    int displayPage;
    
    // Holds timing, display and audio data specific to each machine
    MachineInfo machineInfo;
    
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

    // Image buffer array buffer, its length and current index into the buffer used when drawing
    unsigned char *emuDisplayBuffer;
    unsigned int emuDisplayBufferLength;
    unsigned int emuDisplayBufferIndex;
    
    // Holds the texture horiz and vert scale used when only selecting a subset of the texture to be displayed.
    // The full Spectrum screen size is generated so to display equal border sizes a sub rect of the full texture
    // is used for the display. Also reducing the size of the border is perfored in the same way e.g. making a smaller
    // rect from which to take the texture data
    float emuHScale;
    float emuVScale;
    
    // Holds the current border colour as set by the ULA
    int borderColor;
    
    // Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
    // in the current frame so that the right number of 8x1 screen chunks are drawn
    int emuDisplayTs;

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
    
    // SpecDrum
    int specDrumOutput;
    
    // Thread event e.g. should a snap shot be loaded
    EventType event;
    
    unsigned char memoryContentionTable[80000];
    unsigned char ioContentionTable[80000];
    
    // Tape loading
    int tapeLoadingState;
    int tapeLoadingSubState;
    int pilotPulseTs;
    int pilotPulses;
    BOOL flipTapeBit;
    int tapeInputBit;
	
	// Has a ROM save/load trap been reiggered
	bool saveTrapTriggered;
    bool loadTrapTriggered;
    
    // Holds the kempston joystick last byte value read either through the emulator or SmartLINK
    char smartlinkKempston;
    
    // Byte request used to get data from SmartLink
    NSData *smartLinkRequest;
    
    // Multiface
    bool multifacePagedIn;
    bool multifaceLockedOut;
}

#pragma mark - Properties

// Buffer used to hold the sound samples generated for each emulation frame
@property (assign) short *audioBuffer;

// Reference to the audio core instance
@property (strong) AudioCore *audioCore;

// Reference to the ZXTape instance used for controlling tape loading
@property (strong) ZXTape *zxTape;

// Queue on which the emulation is run
@property (strong) dispatch_queue_t emulationQueue;

@property (assign) float soundVolume;
@property (assign) double soundLowPassFilter;
@property (assign) double soundHighPassFilter;
@property (assign) BOOL AYChannelA;
@property (assign) BOOL AYChannelB;
@property (assign) BOOL AYChannelC;
@property (assign) float AYChannelABalance;
@property (assign) float AYChannelBBalance;
@property (assign) float AYChannelCBalance;
@property (assign) bool useAYOn48k;
@property (assign) bool specDrum;
@property (assign) bool multiface1;
@property (assign) bool multiface128;
@property (assign) bool multiface128Lockout;

@property (strong) NSString *snapshotPath;

@property (weak) EmulationViewController *emulationViewController;
@property (strong) SKTexture *texture;
@property (strong) SKTexture *memoryTexture;

@property (strong) id imageRef;
@property (assign) CGColorSpaceRef colorSpace;

@property (assign) bool stepping;

@property (assign) BOOL accelerated;

// Serial core used to communicate with SmartLINK
@property (strong) SerialCore *serialCore;
@property (nonatomic, assign) BOOL useSmartLink;

// Debug properties

static unsigned char coreDebugRead(unsigned int address, void *m, void *d);

#pragma mark - Methods

/**
Initialises the machine which then references the EmulationViewController provided to display the emulation output
 */
- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController machineInfo:(MachineInfo)info;

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
- (void)reset:(BOOL)hard;

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
 Loads the ROM at the provided path into a 48k Machine. These are ROM files that were available for the IF2. Only 16
 were ever made.
 */
- (void)loadROMWithPath:(NSString *)path;

- (void)loadDefaultROM;

/**
Sets up observers between the machine and the audio core
 */
- (void)setupObservers;

- (void)NMI;

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
void updateAudioWithTStates(int tsCPU, void *m);

/**
Handles any port writes made by the CPU
 */
void coreIOWrite(unsigned short address, unsigned char data, void *m);

/**
 Handles any port reads made by the CPU
 */
unsigned char coreIORead(unsigned short address, void *m);

/**
 Returns the name of the machine
 */
- (NSString *)machineName;



@end
