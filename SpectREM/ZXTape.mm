//
//  ZXTape.m
//  SpectREM
//
//  Created by Mike Daley on 17/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ZXTape.h"
#import "Z80Core.h"

@implementation ZXTape
{
    // How many Ts have passed since the start of the pilot pulses
    int pilotPulseTStates;
    // How many pilot pulses have been generated
    int pilotPulses;
    // Sync pulse tStates
    int syncPulseTStates;
    // How many Ts have passed since the start of the data pulse
    int dataPulseTStates;
    // Should the tape bit be flipped
    BOOL flipTapeBit;
    // Current processing state e.g. generating pilot, streaming data
    int processingState;
    // Next processing state to be used
    int nextProcessingState;
    // Current byte location in the tape data being processed
    int currentBytePointer;
    // Which bit of the current byte in the data stream is being processed
    int currentDataBit;
    // How many tStates have passed since starting the pause between data blocks
    int blockPauseTStates;
    // How many tStates to pause when processing data bit pulses
    int dataBitTStates;
    // How many pulses have been generated for the current data bit;
    int dataPulseCount;
    
    // Array that contains all the data blocks within the TAP file
    NSMutableArray *tapBlocks;
    
    // The current block within the tapBlocks array being processed
    int currentBlockIndex;
    
    // Is a new block about to start
    BOOL newBlock;
    
    // What was the previous block type
    BlockDataType previousBlockType;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        pilotPulseTStates = 0;
        syncPulseTStates = 0;
        pilotPulses = 0;
        processingState = eNoTape;
        blockPauseTStates = 0;
        currentBytePointer = 0;
        flipTapeBit = NO;
        tapeInputBit = 0;
        _playing = NO;
        
        tapBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)openTapeWithURL:(NSURL *)url
{
    self.tapeFileURL = url;
    self.playing = NO;
    
    NSError *error;
    NSData *tapeData = [NSData dataWithContentsOfURL:self.tapeFileURL options:NULL error:&error];
    if (!tapeData)
    {
        NSLog(@"Error reading tape file: %@ - %@", self.tapeFileURL.path, error.description);
        self.tapeLoaded = NO;
        processingState = eNoTape;
        return;
    }

    tapBlocks = [NSMutableArray new];

    [self processTAPFileData:tapeData];
    [self printTAPContents];
    self.tapeLoaded = YES;
}

- (void)processTAPFileData:(NSData *)data
{
    const char *tapeBytes = (const char*)[data bytes];
    
    self.playing = NO;
    pilotPulseTStates = 0;
    syncPulseTStates = 0;
    pilotPulses = 0;
    processingState = eNoTape;
    blockPauseTStates = 0;
    tapeInputBit = 0;
    currentBytePointer = 0;
    currentBlockIndex = 0;
    self.bytesRemaining = 0;
    newBlock = YES;
    
    unsigned short blockLength = 0;
    unsigned char flag = 0;
    unsigned char dataType = 0;
    
    // Build an array of all the blocks in the TAP file
    while (currentBytePointer < data.length) {
        
        blockLength = ((unsigned short *)&tapeBytes[currentBytePointer])[0];
        
        // Move the pointer past the block size and into the block itself
        currentBytePointer += 2;
        
        flag = tapeBytes[currentBytePointer + cHeaderFlagOffset];
        dataType = tapeBytes[currentBytePointer + cHeaderDataTypeOffset];
        
        TAPBlock *newTAPBlock = nil;
        
        if (dataType == eProgramHeader && flag != 0xff)
        {
            newTAPBlock = [ProgramHeader new];
        }
        else if (dataType == eNumericDataHeader && flag != 0xff)
        {
            newTAPBlock = [NumericDataHeader new];
        }
        else if (dataType == eAlphaNumericDataHeader && flag != 0xff)
        {
            newTAPBlock = [AlphaNumericDataHeader new];
        }
        else if (dataType == eByteHeader && flag != 0xff)
        {
            newTAPBlock = [ByteHeader new];
        }
        else if (flag == 0xff || flag == 0xfe)
        {
            newTAPBlock = [DataBlock new];
        }

        newTAPBlock.blockLength = blockLength;
        newTAPBlock.blockData = (unsigned char *)calloc(blockLength, sizeof(unsigned char));
        memcpy(newTAPBlock.blockData, &tapeBytes[currentBytePointer], blockLength);
        self.bytesRemaining += blockLength + 1;
        [tapBlocks addObject:newTAPBlock];

        currentBytePointer += blockLength;
    }
}

- (void)updateTapeWithTStates:(int)tStates
{
    
    if (newBlock)
    {
        newBlock = NO;
        
        if (currentBlockIndex > tapBlocks.count - 1)
        {
            NSLog(@"TAPE STOPPED");
            self.playing = NO;
            tapeInputBit = 0;
            return;
        }

        TAPBlock *tapBlock = [tapBlocks objectAtIndex:currentBlockIndex];

        if ([tapBlock isKindOfClass:[ProgramHeader class]])
        {
            NSLog(@"Processing Program Header");
            pilotPulseTStates = 0;
            pilotPulses = 0;
            flipTapeBit = YES;
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }

        if ([tapBlock isKindOfClass:[NumericDataHeader class]])
        {
            NSLog(@"Processing Numberic Header");
            pilotPulseTStates = 0;
            pilotPulses = 0;
            flipTapeBit = YES;
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }

        if ([tapBlock isKindOfClass:[AlphaNumericDataHeader class]])
        {
            NSLog(@"Processing Alpha Numeric Header");
            pilotPulseTStates = 0;
            pilotPulses = 0;
            flipTapeBit = YES;
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }
        
        if ([tapBlock isKindOfClass:[ByteHeader class]])
        {
            NSLog(@"Processing Byte Header");
            pilotPulseTStates = 0;
            pilotPulses = 0;
            flipTapeBit = YES;
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }

        if ([tapBlock isKindOfClass:[DataBlock class]])
        {
            NSLog(@"Processing Data Block");
            currentBytePointer = 0;
            currentDataBit = 0;
            pilotPulseTStates = 0;
            pilotPulses = 0;
            dataPulseTStates = 0;
            flipTapeBit = YES;
            processingState = eDataPilot;
            nextProcessingState = eDataStream;
        }
    }
    
    switch (processingState) {
        case eHeaderPilot:
            [self generateHeaderPilotWithTStates:tStates];
            break;
            
        case eSync1:
            [self generateSync1WithTStates:tStates];
            break;
        
        case eSync2:
            [self generateSync2WithTStates:tStates];
            break;
            
        case eDataPilot:
            [self generateDataPilotWithTStates:tStates];
            break;
            
        case eDataStream:
            [self generateDataStreamWithTStates:tStates];
            break;

        case eHeaderDataStream:
            [self generateHeaderDataStreamWithTStates:tStates];
            break;

        case eDataBit:
            [self generateDataBitWithTStates:tStates];
            break;
            
        case eBlockPause:
            [self blockPauseWithTStates:tStates];
            break;
    }
    
}

- (void)generateHeaderPilotWithTStates:(int)tStates
{
    if (pilotPulses < cPilotHeaderPulses)
    {
        if (flipTapeBit)
        {
            tapeInputBit ^= 1;
            flipTapeBit = NO;
        }
        
        if (pilotPulseTStates >= cPilotPulseTStateLength)
        {
            pilotPulses += 1;
            pilotPulseTStates = 0;
            flipTapeBit = YES;
        }
    }
    else
    {
        syncPulseTStates = 0;
        processingState = eSync1;
    }
    
    pilotPulseTStates += tStates;
}


- (void)generateDataPilotWithTStates:(int)tStates
{
    if (pilotPulses < cPilotDataPulses)
    {
        if (flipTapeBit)
        {
            tapeInputBit ^= 1;
            flipTapeBit = NO;
        }
        
        if (pilotPulseTStates >= cPilotPulseTStateLength)
        {
            pilotPulses += 1;
            pilotPulseTStates = 0;
            flipTapeBit = YES;
        }
    }
    else
    {
        syncPulseTStates = 0;
        processingState = eSync1;
    }
    
    pilotPulseTStates += tStates;
}

- (void)generateSync1WithTStates:(int)tStates
{
    if (flipTapeBit)
    {
        tapeInputBit ^= 1;
        flipTapeBit = NO;
    }
    
    if (syncPulseTStates >= cFirstSyncPulseTStateDelay)
    {
        syncPulseTStates = 0;
        flipTapeBit = YES;
        processingState = eSync2;
    }
    else
    {
        syncPulseTStates += tStates;
    }
}

- (void)generateSync2WithTStates:(int)tStates
{
    if (flipTapeBit)
    {
        tapeInputBit ^= 1;
        flipTapeBit = NO;
    }
    
    if (syncPulseTStates >= cSecondSyncPulseTStateDelay)
    {
        syncPulseTStates = 0;
        currentBytePointer = 0;
        flipTapeBit = YES;
        processingState = nextProcessingState;
    }
    else
    {
        syncPulseTStates += tStates;
    }
}

- (void)generateDataStreamWithTStates:(int)tStates
{
    int currentBlockLength = [[tapBlocks objectAtIndex:currentBlockIndex] getDataLength];
    unsigned char byte = [[tapBlocks objectAtIndex:currentBlockIndex] blockData][currentBytePointer];
    unsigned char bit = (byte << currentDataBit) & 128;
    
    currentDataBit += 1;
    if (currentDataBit > 7)
    {
        currentDataBit = 0;
        currentBytePointer += 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bytesRemaining -= 1;
        });
        if (currentBytePointer > currentBlockLength)
        {
            processingState = eBlockPause;
            blockPauseTStates = 0;
            return;
        }
    }
    
    if (bit)
    {
        dataPulseTStates = cDataBitOnePulseTStateDelay;
    }
    else
    {
        dataPulseTStates = cDataBitZeroPulseTStateDelay;
    }
    flipTapeBit = YES;
    dataBitTStates = 0;
    dataPulseCount = 0;
    processingState = eDataBit;
}

- (void)generateHeaderDataStreamWithTStates:(int)tStates
{
    int currentBlockLength = 19;
    unsigned char byte = [[tapBlocks objectAtIndex:currentBlockIndex] blockData][currentBytePointer];
    unsigned char bit = (byte << currentDataBit) & 128;
    
    currentDataBit += 1;
    if (currentDataBit > 7)
    {
        currentDataBit = 0;
        currentBytePointer += 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bytesRemaining -= 1;
        });
        if (currentBytePointer > currentBlockLength)
        {
            processingState = eBlockPause;
            blockPauseTStates = 0;
            return;
        }
    }
    
    if (bit)
    {
        dataPulseTStates = cDataBitOnePulseTStateDelay;
    }
    else
    {
        dataPulseTStates = cDataBitZeroPulseTStateDelay;
    }
    flipTapeBit = YES;
    dataBitTStates = 0;
    dataPulseCount = 0;
    processingState = eDataBit;
}

- (void)generateDataBitWithTStates:(int)tStates
{
    if (flipTapeBit)
    {
        tapeInputBit ^= 1;
        flipTapeBit = NO;
    }
    
    if (dataBitTStates >= dataPulseTStates)
    {
        dataPulseCount += 1;
        if (dataPulseCount < 2)
        {
            flipTapeBit = YES;
            dataBitTStates = 0;
        }
        else
        {
            processingState = nextProcessingState;
        }
    }
    else
    {
        dataBitTStates += tStates;
    }
}

- (void)blockPauseWithTStates:(int)tStates
{
    blockPauseTStates += tStates;
    if (blockPauseTStates > 3500000 * 2)
    {
        currentBlockIndex += 1;
        newBlock = YES;
    }

    // Introduce a random crackle inbetween blocks to produce a similar experience as a loading from a real tape
    // on a ZX Spectrum.
    if (arc4random_uniform(200000) == 1)
    {
        tapeInputBit ^= 1;
    }
}

- (void)play
{
    self.playing = YES;
}

- (void)save
{
    NSMutableData *saveData = [NSMutableData new];
    
    for (TAPBlock *tapBlock in tapBlocks) {
        unsigned char length = tapBlock.blockLength;
        [saveData appendBytes:&length length:sizeof(unsigned short)];
        [saveData appendBytes:tapBlock.blockData length:length];
    }
    
    [saveData writeToFile:@"/Users/mikedaley/Desktop/testing.tap" atomically:YES];
}

- (void)stop
{
    self.playing = NO;
    tapeInputBit = 0;
}

- (void)rewind
{
    blockPauseTStates = 0;
    tapeInputBit = 0;
    currentBytePointer = 0;
    currentBlockIndex = 0;
    newBlock = YES;
}

- (void)eject
{
    tapBlocks = [NSMutableArray new];
    self.tapeLoaded = NO;
}

- (void)reset
{
    self.tapeLoaded = NO;
    self.playing = NO;
    [tapBlocks removeAllObjects];
}

#pragma mark - Saving

- (void)saveTAPBlockWithMachine:(ZXSpectrum *)m
{
    CZ80Core *core = (CZ80Core *)[m getCore];
    
    char parity = 0;
    short length = core->GetRegister(CZ80Core::eREG_DE) + 2;

    NSMutableData *data = [NSMutableData new];
    
    [data appendBytes:&length length:2];

    parity = core->GetRegister(CZ80Core::eREG_A);
    [data appendBytes:&parity length:1];
    
    for (int i = 0; i < core->GetRegister(CZ80Core::eREG_DE); i++)
    {
        char byte = m->memory[core->GetRegister(CZ80Core::eREG_IX) + i];
        parity ^= byte;
        [data appendBytes:&byte length:1];
    }
    
    [data appendBytes:&parity length:1];
    
    [self processTAPFileData:data];

    // Once a block has been saved this is the RET address
    core->SetRegister(CZ80Core::eREG_PC, 0x053d);
}

#pragma mark - Debug print

- (void)printTAPContents
{
    for (TAPBlock *tapBlock in tapBlocks) {
        
        NSLog(@"+----------------------------------------");
        
        if ([tapBlock getDataType] == eProgramHeader && [tapBlock getFlag] != 255)
        {
            NSLog(@"Program       : \"%@\" LINE %i", [tapBlock getFilename], ([(ProgramHeader *)tapBlock getAutostartLine] == 32768) ? 0 : [(ProgramHeader *)tapBlock getAutostartLine]);
            NSLog(@"Data Length   : %i", [(ProgramHeader *)tapBlock getDataLength]);
            NSLog(@"Program Length: %i", [(ProgramHeader *)tapBlock getProgramLength]);
        }
        
        if ([tapBlock getDataType] == eNumericDataHeader && [tapBlock getFlag] != 255)
        {
            NSLog(@"Numeric Data  : \"%@\"", [tapBlock getFilename]);
            NSLog(@"Data Length   : %i", [(NumericDataHeader *)tapBlock getDataLength]);
            NSLog(@"Variable Name : %i", [(NumericDataHeader *)tapBlock getVariableName]);
        }
        
        if ([tapBlock getDataType] == eAlphaNumericDataHeader && [tapBlock getFlag] != 255)
        {
            NSLog(@"Alpha Numeric Data: \"%@\"", [tapBlock getFilename]);
            NSLog(@"Data Length       : %i", [(AlphaNumericDataHeader *)tapBlock getDataLength]);
            NSLog(@"Variable Name     : %i", [(AlphaNumericDataHeader *)tapBlock getVariableName]);
        }
        
        if ([tapBlock getDataType] == eByteHeader && [tapBlock getFlag] != 255)
        {
            NSLog(@"Byte Data     : \"%@\"", [tapBlock getFilename]);
            NSLog(@"Data Length   : %i", [(ByteHeader *)tapBlock getDataLength]);
            NSLog(@"Start Address : %i", [(ByteHeader *)tapBlock getStartAddress]);
        }
        
        if ([tapBlock getFlag] == 255)
        {
            NSLog(@"Data Block    :");
            NSLog(@"Data Length   : %i", [(DataBlock *)tapBlock getDataLength]);
        }
    }
}

@end

#pragma mark - TAP Block

@implementation TAPBlock

- (void)dealloc
{
    NSLog(@"Deallocating TAPBlock");
    if (self.blockData)
    {
        free(self.blockData);
    }
}

- (unsigned char)getFlag
{
    return self.blockData[cHeaderFlagOffset];
}

- (unsigned char)getDataType
{
    return self.blockData[cHeaderDataTypeOffset];
}

- (NSString *)getFilename
{
    char *filename = (char *)calloc(cHeaderFilenameLength, sizeof(char));
    memcpy(filename, &_blockData[cHeaderFilenameOffset], cHeaderFilenameLength);
    return [NSString stringWithCString:filename encoding:NSASCIIStringEncoding];
}

- (unsigned short)getDataLength
{
    return ((unsigned short *)&self.blockData[cHeaderDataLengthOffset])[0];
}

- (unsigned char)getChecksum
{
    return self.blockData[cHeaderChecksumOffset];
}

@end

#pragma mark - Program Header

@implementation ProgramHeader

- (unsigned short)getAutostartLine
{
    return ((unsigned short *)&self.blockData[cProgramHeaderAutostartLineOffset])[0];
}

- (unsigned short)getProgramLength
{
    return ((unsigned short *)&self.blockData[cProgramHeaderProgramLengthOffset])[0];
}

- (unsigned char)getChecksum
{
    return self.blockData[cProgramHeaderChecksumOffset];
}

- (NSString *)getBlockType
{
    return @"Program Header";
}

@end

#pragma mark - Numeric Data Header

@implementation NumericDataHeader

- (unsigned char)getVariableName
{
    return self.blockData[cNumericDataHeaderVariableNameOffset];
}

- (NSString *)getBlockType
{
    return @"Numeric Data Header";
}

@end

#pragma mark - Alpha Numeric Data Header

@implementation AlphaNumericDataHeader

- (unsigned char)getVariableName
{
    return self.blockData[cAlphaNumericDataHeaderVariableNameOffset];
}

- (NSString *)getBlockType
{
    return @"Alphanumeric Data Header";
}

@end

#pragma mark - Byte Header

@implementation ByteHeader

- (unsigned short)getStartAddress
{
    return ((unsigned short *)&self.blockData[cByteHeaderStartAddressOffset])[0];
}

- (NSString *)getBlockType
{
    return @"Byte Header";
}

@end

#pragma mark - Data Block

@implementation DataBlock

- (NSString *)getFilename
{
    return @"";
}

- (unsigned char *)getDataBlock
{
    unsigned char *dataBlock = (unsigned char *)calloc([self getDataLength], sizeof(unsigned char));
    memcpy(dataBlock, &self.blockData[cDataBlockDataLengthOffset], sizeof(unsigned char) * [self getDataLength]);
    return dataBlock;
}

- (unsigned short)getDataLength
{
    return self.blockLength;
}

- (unsigned char)getChecksum
{
    return self.blockData[self.blockLength + 1];
}

- (NSString *)getBlockType
{
    return @"Data Block";
}

@end


