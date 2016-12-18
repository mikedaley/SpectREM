//
//  ZXTape.m
//  SpectREM
//
//  Created by Mike Daley on 17/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ZXTape.h"

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
    // Temp storage for the number of bytes in a data block as specific by the preceeding header
    int dataBlockLength;
    // How many pulses have been generated for the current data bit;
    int dataPulseCount;
    // Array that contains all the data blocks within the TAP file
    NSMutableArray *tapBlocks;
    // The current block within the tapBlocks array being processed
    int currentBlockIndex;
    // Is a new block about to start
    BOOL newBlock;
    
    NSData *tapeData;
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
    }
    return self;
}

- (BOOL)loadTapeWithURL:(NSURL *)url
{
    tapeData = [NSData dataWithContentsOfURL:url];
    [self processTAPFile];
    [self printTAPContents];
    return YES;
}

- (void)processTAPFile
{
    const char *tapeBytes = (const char*)[tapeData bytes];
    
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
    tapBlocks = [NSMutableArray new];
    
    // Build an array of all the blocks in the TAP file
    while (currentBytePointer < tapeData.length) {
        
        unsigned short blockLength = ((unsigned short *)&tapeBytes[currentBytePointer])[0];
        currentBytePointer += 2;
        unsigned char flag = tapeBytes[currentBytePointer + cHeaderFlagOffset];
        unsigned char dataType = tapeBytes[currentBytePointer + cHeaderDataTypeOffset];
        
        if (dataType == eProgramHeader && flag != 255)
        {
            ProgramHeader *programHeader = [ProgramHeader new];
            programHeader.blockData = calloc(blockLength, sizeof(unsigned char));
            memcpy(programHeader.blockData, &tapeBytes[currentBytePointer], blockLength);
            currentBytePointer += blockLength;
            dataBlockLength = [programHeader getDataLength];
            self.bytesRemaining += 17;
            [tapBlocks addObject:programHeader];
        }
        
        if (dataType == eNumericDataHeader && flag != 255)
        {
            NumericDataHeader *numericDataHeader = [NumericDataHeader new];
            numericDataHeader.blockData = calloc(blockLength, sizeof(unsigned char));
            memcpy(numericDataHeader.blockData, &tapeBytes[currentBytePointer], blockLength);
            currentBytePointer += blockLength;
            dataBlockLength = [numericDataHeader getDataLength];
            self.bytesRemaining += 17;
            [tapBlocks addObject:numericDataHeader];
        }
        
        if (dataType == eAlphaNumericDataHeader && flag != 255)
        {
            AlphaNumericDataHeader *alphaNumericDataHeader = [AlphaNumericDataHeader new];
            alphaNumericDataHeader.blockData = calloc(blockLength, sizeof(unsigned char));
            memcpy(alphaNumericDataHeader.blockData, &tapeBytes[currentBytePointer], blockLength);
            currentBytePointer += blockLength;
            dataBlockLength = [alphaNumericDataHeader getDataLength];
            self.bytesRemaining += 17;
            [tapBlocks addObject:alphaNumericDataHeader];
        }
        
        if (dataType == eByteHeader && flag != 255)
        {
            ByteHeader *byteHeader = [ByteHeader new];
            byteHeader.blockData = calloc(blockLength, sizeof(unsigned char));
            memcpy(byteHeader.blockData, &tapeBytes[currentBytePointer], blockLength);
            currentBytePointer += blockLength;
            dataBlockLength = [byteHeader getDataLength];
            self.bytesRemaining += 17;
            [tapBlocks addObject:byteHeader];
        }
        
        if (flag == 255)
        {
            DataBlock *dataBlock = [DataBlock new];
            dataBlock.dataBlockLength = dataBlockLength + 2;
            dataBlock.blockData = calloc(dataBlockLength + 2, sizeof(unsigned char));
            memcpy(dataBlock.blockData, &tapeBytes[currentBytePointer], dataBlockLength + 2);
            currentBytePointer += dataBlockLength + 2;
            self.bytesRemaining += dataBlockLength + 6;
            [tapBlocks addObject:dataBlock];
        }
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
    if (blockPauseTStates > 3500000)
    {
        currentBlockIndex += 1;
        newBlock = YES;
    }
}

- (void)play
{
    self.playing = YES;
}

- (void)stop
{
    self.playing = NO;
}

- (void)rewind
{
    [self processTAPFile];
}

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
    char *filename = calloc(cHeaderFilenameLength, sizeof(char));
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

@end

#pragma mark - Numeric Data Header

@implementation NumericDataHeader

- (unsigned char)getVariableName
{
    return self.blockData[cNumericDataHeaderVariableNameOffset];
}

@end

#pragma mark - Alpha Numeric Data Header

@implementation AlphaNumericDataHeader

- (unsigned char)getVariableName
{
    return self.blockData[cAlphaNumericDataHeaderVariableNameOffset];
}

@end

#pragma mark - Byte Header

@implementation ByteHeader

- (unsigned short)getStartAddress
{
    return ((unsigned short *)&self.blockData[cByteHeaderStartAddressOffset])[0];
}

@end

#pragma mark - Data Block

@implementation DataBlock

- (unsigned char *)getDataBlock
{
    unsigned char *dataBlock = calloc([self getDataLength], sizeof(unsigned char));
    memcpy(dataBlock, &self.blockData[cDataBlockDataLengthOffset], sizeof(unsigned char) * [self getDataLength]);
    return dataBlock;
}

- (unsigned short)getDataLength
{
    return self.dataBlockLength;
}

- (unsigned char)getChecksum
{
    return self.blockData[self.dataBlockLength + 1];
}

@end


