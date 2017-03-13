//
//  ZXTape.h
//  SpectREM
//
//  Created by Mike Daley on 17/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXSpectrum.h"
#import "ZXTapeProtocol.h"

#pragma mark - Constants

extern NSString *const cTapeBlocksChanged;
extern NSString *const cTapeByteProcessed;

static int const cHeaderLength = 21;

static int cPilotHeaderPulses = 8063;
static int cPilotDataPulses = 3223;
static int cPilotPulseTStateLength = 2168;
static int cFirstSyncPulseTStateDelay = 667;
static int cSecondSyncPulseTStateDelay = 735;
static int cDataBitZeroPulseTStateDelay = 855;
static int cDataBitOnePulseTStateDelay = 1710;

static int cHeaderFlagOffset = 0;
static int cHeaderDataTypeOffset = 1;
static int cHeaderFilenameOffset = 2;
static int cHeaderDataLengthOffset = 12;
static int cHeaderChecksumOffset = 17;

static int cProgramHeaderAutostartLineOffset = 14;
static int cProgramHeaderProgramLengthOffset = 16;
static int cProgramHeaderChecksumOffset = 18;

static int cNumericDataHeaderUnused1Offset = 14;
static int cNumericDataHeaderVariableNameOffset = 15;
static int cNumericDataHeaderUnused2Offset = 16;

static int cAlphaNumericDataHeaderUnused1Offset = 14;
static int cAlphaNumericDataHeaderVariableNameOffset = 15;
static int cAlphaNumericDataHeaderUnused2Offset = 16;

static int cByteHeaderStartAddressOffset = 14;
static int cByteHeaderUnused1Offset = 16;

static int cDataBlockDataLengthOffset = 1;

static int cHeaderFilenameLength = 10;

static int cHeaderBlockLength = 19;

#pragma mark - Enums

typedef NS_ENUM(int, ProcessingState)
{
    eNoTape = 0,
    eHeaderPilot,
    eSync1,
    eSync2,
    eDataPilot,
    eBlockPause,
    eDataStream,
    eHeaderDataStream,
    eDataBit
};

typedef NS_ENUM(unsigned char, BlockDataType)
{
    eProgramHeader = 0,
    eNumericDataHeader,
    eAlphaNumericDataHeader,
    eByteHeader,
    eDataBlock,
    eFragmentedDataBlock,
    eUnknownBlock = 99
};

#pragma mark - Interface

@interface ZXTape : NSObject
{
@public
    // Current tape input value to be OR'd to the IO Read response and sound generation
    int tapeInputBit;
}

#pragma mark - Properties

@property (assign, getter=isTapeLoaded) BOOL tapeLoaded;
@property (assign) BOOL playing;
@property (assign) BOOL saving;
@property (strong) NSURL *tapeFileURL;
@property (strong) NSMutableArray *tapBlocks;
@property (assign) NSInteger currentBlockIndex;
@property (assign) NSInteger currentBytePointer;
@property (assign) id<ZXTapeProtocol> delegate;

#pragma mark - Methods

// Load the supplied TAP file into memory and setup for processing the tap data
- (void)openTapeWithURL:(NSURL *)url;


// Called by the emulators main loop if a tape is playing. It passes in the number of tStates that have been used by the last
// instruction so that the tape processing can keep track of timings necessary to generate header pulses, syncs, pauses and
// stream data
- (void)updateTapeWithTStates:(int)tStates;

// Currently loaded tape controls
- (void)play;
- (void)saveToURL:(NSURL *)url;
- (void)stop;
- (void)rewind;
- (void)eject;

// Reset the tape loader removing any current tape loaded and stopping the tape if it is playing
- (void)reset;

// Called from the main emulation loop when a save is being performed. This passes in a reference to the core
// which is then used to extract the data being written for the current block to tape.
- (void)saveTAPBlockWithMachine:(ZXSpectrum *)m;

// Called from the main emulation loop when a load is performed and insta loading has been enabled.
- (void)instaloadTAPWithMachine:(ZXSpectrum *)machine;

@end

#pragma mark - TAP Block

@interface TAPBlock : NSObject

@property (assign) unsigned short blockLength;
@property (assign) unsigned char *blockData;
@property (strong, nonatomic) NSString *blockType;
@property (assign) NSInteger currentByte;

- (unsigned char)getFlag;
- (unsigned char)getDataType;
- (NSString *)getFilename;
- (unsigned short)getDataLength;
- (unsigned char)getChecksum;

@end

#pragma mark - Programme Header

@interface ProgramHeader : TAPBlock

- (unsigned short)getAutostartLine;
- (unsigned short)getProgramLength;

@end

#pragma mark - Numeric Data Header

@interface NumericDataHeader : TAPBlock

- (unsigned char)getVariableName;

@end

#pragma mark - Numeric Data Header

@interface AlphaNumericDataHeader : TAPBlock

- (unsigned char)getVariableName;

@end

#pragma mark - Byte Header

@interface ByteHeader : TAPBlock

- (unsigned short)getStartAddress;

@end

#pragma mark - Data Block

@interface DataBlock : TAPBlock

@end
