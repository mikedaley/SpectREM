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
static int const cBITMAP_ADDRESS = 16384;
static int const cBITMAP_SIZE = 6144;
static int const cATTR_SIZE = 768;

// Used to increase the volume of the beeper output. Too high and the output is clipped
static int const cAUDIO_BEEPER_VOL_MULTIPLIER = 48;

// Sampled rate used to drive the update frequency in the audio engine which is then used to generate new frames e.g. 50.08 fps
static int const cAUDIO_SAMPLE_RATE = 192000;

// Static values used when building the contention and floating bus tables
static unsigned char const cCONTENTION_VALUES[8] = { 6, 5, 4, 3, 2, 1, 0, 0 };
static unsigned char const cFLOATING_BUS_TABLE[8] = { 0, 0, 1, 2, 1, 2, 0, 0 };

// Number of frames to skip when running in accelerated mode
static int const cACCELERATED_SKIP_FRAMES = 10;

// Memory sizes/Pages
static size_t const c16k = 16 * 1024;
static size_t const c32k = 32 * 1024;
static size_t const c48k = 48 * 1024;
static size_t const c64k = 64 * 1024;
static size_t const c128k = 128 * 1024;
static size_t const c48kPages = c48k / 16384;
static size_t const c128kPages = c128k / 16384;

// SmartCard constants
static size_t const cSMART_CARD_RAME_SIZE = 8 * 8192;

// Multiface memory size
static size_t const cMULTIFACE_MEM_SIZE = 16 * 1024;

// BASIC System Variable Constants
static unsigned short const cFLAGS = 23611;
static unsigned short const cLAST_K = 23560;
static unsigned short const cFRAMES = 23672;

// Next Sprites
static int const cMAX_SPRITES = 64;
static int const cPALETTE_SIZE = 256;
static int const cMAX_SPRITES_PER_SCANLINE = 12;
static int const cSPRITE_WIDTH = 16;
static int const cSPRITE_HEIGHT = 16;
static int const cSPRITE_TRANSPARENT_COLOR = 0xe3;
static int const cSPRITE_ATTRIBUTES = 4;
static int const cSPRITE_VERT_LINES = 256;

typedef enum : NSUInteger {
    eXPosition = 0,
    eYPosition,
    ePaletteMirrorRotate,
    eVisible
} SpriteInfo;

#pragma mark - Interface

@class SmartLink;

@interface ZXSpectrum : NSObject <KeyboardEventProtocol>
{

@public
    // Main RAM and ROM for the 48k and 128k
    unsigned char *memory;
    unsigned char *rom;

    // Holds timing, display and audio data specific to each machine
    MachineInfo machineInfo;

    // Multiface ROM
    unsigned char *multifaceMemory;
    bool multifacePagedIn;
    bool multifaceLockedOut;
    
    // SmartCard ROM and sundries
    unsigned char smartCardPortFAF3;
    unsigned char smartCardPortFAFB;
    unsigned char *smartCardSRAM;		// 8 * 8k banks, mapped @ $2000-$3FFF
    bool smartCardActive;
    
    // 128k paging
    int currentROMPage;
    int currentRAMPage;
    BOOL disablePaging;
    int displayPage;
    unsigned char last7ffd;
    
    // Holds the current border colour as set by the ULA
    int borderColor;
    
    // Has a ROM save/load trap been reiggered
    bool saveTrapTriggered;
    bool loadTrapTriggered;

    // Image buffer array buffer, its length and current index into the buffer used when drawing
    unsigned char *emuDisplayBuffer;
    unsigned int emuDisplayBufferLength;
    unsigned int emuDisplayBufferIndex;

    // Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
    // in the current frame so that the right number of 8x1 screen chunks are drawn
    int emuDisplayTs;
    
    // Memory and IO contention tables
    unsigned char memoryContentionTable[80000];
    unsigned char ioContentionTable[80000];
    
    // Next Sprites
    int sprites[cMAX_SPRITES][cSPRITE_WIDTH * cSPRITE_HEIGHT];
    unsigned char spritePalette[cPALETTE_SIZE * 3];
    unsigned char spriteInfo[cMAX_SPRITES][cSPRITE_ATTRIBUTES];
    int spriteLineList[cSPRITE_VERT_LINES][cMAX_SPRITES_PER_SCANLINE];
    unsigned char currentSprite;
    unsigned char currentSpriteInfo;
    unsigned char currentPalette;
    unsigned char spriteDataOffset;
    unsigned char spriteInfoOffset;
    
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

@property (assign) bool instaTAPLoading;

@property (assign) bool smartCardEnabled;

@property (strong) NSString *snapshotPath;

@property (weak) EmulationViewController *emulationViewController;
@property (strong) SKTexture *texture;
@property (strong) SKTexture *memoryTexture;

@property (strong) NSUserDefaults *preferences;

@property (strong) id imageRef;
@property (assign) CGColorSpaceRef colorSpace;

@property (assign) BOOL accelerated;

@property (strong) NSMutableArray *keystrokesBuffer;

// Serial core used to communicate with SmartLINK
@property (strong) SmartLink *smartLink;
@property (nonatomic, assign) BOOL useSmartLink;

// Debug properties
@property (assign) BOOL paused;
@property (assign) BOOL step;


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

- (void)enableSmartCard;
- (void)disableSmartCard;

#pragma mark - Debugging

- (void)stepInstruction;

@end
