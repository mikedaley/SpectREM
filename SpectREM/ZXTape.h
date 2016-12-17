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

#pragma mark - Enums

typedef NS_ENUM(int, ProcessingState)
{
    eNoTape = 0,
    eHeaderPilot,
    eSync1,
    eSync2,
    eDataPilot,
    eBlockPause,
    eDataStream
};

#pragma mark - Interface

@interface ZXTape : NSObject
{
@public
    // Data type 0
    struct ProgHeader
    {
        unsigned short blockLength;
        unsigned char flag;
        unsigned char dataType;
        unsigned char filename[10];
        unsigned short dataLength;
        unsigned short autoStartLine;
        unsigned short programLength;
        unsigned char checksum;
    };
    
    // Data type 1
    struct NumericDataHeader
    {
        unsigned short blockLength;
        unsigned char flag;
        unsigned char dataType;
        unsigned char filename[10];
        unsigned short dataLength;
        unsigned char unused1;
        unsigned char variableName;
        unsigned short unused2;
        unsigned char checksum;
    };
    
    // Data type 2
    struct AlphaNumericDataHeader
    {
        unsigned short blockLength;
        unsigned char flag;
        unsigned char dataType;
        unsigned char filename[10];
        unsigned short dataLength;
        unsigned char unused1;
        unsigned char variableName;
        unsigned short unused2;
        unsigned char checksum;
    };
    
    // Data type 3
    struct ByteHeader
    {
        unsigned short blockLength;
        unsigned char flag;
        unsigned char dataType;
        unsigned char filename[10];
        unsigned short dataLength;
        unsigned short startAddress;
        unsigned short unused;
        unsigned char checksum;
    };
    
    // Standard or custom data block
    struct DataBlock
    {
        unsigned short blockLength;
        unsigned char flag;
        unsigned short dataLength;
        unsigned char *data;
        unsigned char checksum;
    };
    
    // Fragmented data block
    struct FragmentedDataBlock
    {
        unsigned char *data;
    };
    
    // Current tape input value to be ORd to the IO Read response and sound generation
    int tapeInputBit;
    
}

#pragma mark - Properties

@property (assign) BOOL playing;
@property (assign) int blockNumber;

#pragma mark - Methods

// Load the supplied TAP file into memory and setup for processing the tap data
-(BOOL)loadTapeWithURL:(NSURL *)url;

// Called by the emulators main loop if a tape is playing. It passes in the number of tStates that have been used by the last
// instruction so that the tape processing can keep track of timings necessary to generate header pulses, syns, pauses and
// strams data
- (void)updateTapeWithTStates:(int)tStates;

// Start the currently loaded tape playing
- (void)play;

@end
