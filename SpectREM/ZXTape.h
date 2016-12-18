//
//  ZXTape.h
//  SpectREM
//
//  Created by Mike Daley on 17/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Constants

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
    eFragmentedDataBlock
};

#pragma mark - Interface

@interface ZXTape : NSObject
{
@public
    // Current tape input value to be ORd to the IO Read response and sound generation
    int tapeInputBit;
}

#pragma mark - Properties

@property (assign) BOOL playing;
@property (assign) NSUInteger bytesRemaining;

#pragma mark - Methods

// Load the supplied TAP file into memory and setup for processing the tap data
-(BOOL)loadTapeWithURL:(NSURL *)url;

// Called by the emulators main loop if a tape is playing. It passes in the number of tStates that have been used by the last
// instruction so that the tape processing can keep track of timings necessary to generate header pulses, syns, pauses and
// strams data
- (void)updateTapeWithTStates:(int)tStates;

// Currently loaded tape controls
- (void)play;
- (void)stop;
- (void)rewind;

@end

#pragma mark - TAP Block

@interface TAPBlock : NSObject

@property (assign) unsigned char *blockData;

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

@property (assign) int dataBlockLength;

@end
