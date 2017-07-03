//
//  ZXTape.m
//  SpectREM
//
//  Created by Mike Daley on 17/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ZXTape.h"
#import "Z80Core.h"

NSString *const cTAPE_BLOCKS_CHANGED = @"cTAPE_BLOCKS_CHANGED";
NSString *const cTAPE_BYTE_PROCESSED = @"cTAPE_BYTE_PROCESSED";
NSString *const cTAP_EXTENSION = @"TAP";

@implementation ZXTape
{
    int pilotPulseTStates;          // How many Ts have passed since the start of the pilot pulses
    int pilotPulses;                // How many pilot pulses have been generated
    int syncPulseTStates;           // Sync pulse tStates
    int dataPulseTStates;           // How many Ts have passed since the start of the data pulse
    BOOL flipTapeBit;               // Should the tape bit be flipped
    int processingState;            // Current processing state e.g. generating pilot, streaming data
    int nextProcessingState;        // Next processing state to be used
    int currentDataBit;             // Which bit of the current byte in the data stream is being processed
    int blockPauseTStates;          // How many tStates have passed since starting the pause between data blocks
    int dataBitTStates;             // How many tStates to pause when processing data bit pulses
    int dataPulseCount;             // How many pulses have been generated for the current data bit;
    BOOL newBlock;                  // Is a new block about to start
    NSTimer *progressTimer;         // Timer used to update the progress indicators during a tape load
    TAPBlock *currentBlock;         // Current tape block
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
        self.currentBytePointer = 0;
        flipTapeBit = NO;
        tapeInputBit = 0;
        _playing = NO;
        
        self.tapBlocks = [NSMutableArray new];
        
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (self.playing)
            {
                if (self.delegate)
                {
                    [self.delegate tapeBytesProcessed:self.currentBytePointer];
                }
            }
        }];
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

    self.tapBlocks = [NSMutableArray new];

    [self processTAPFileData:tapeData];
    
#ifdef DEBUG
    [self printTAPContents];
#endif
    
    self.tapeLoaded = YES;
}

- (void)blocksChanged
{
    if (self.delegate)
    {
        [self.delegate blocksChanged];
    }
}

- (void)processTAPFileData:(NSData *)data
{
    const char *tapeBytes = (const char*)[data bytes];
    
    self.playing = NO;
    self.currentBytePointer = 0;
    self.currentBlockIndex = 0;
    newBlock = YES;
    
    unsigned short blockLength = 0;
    unsigned char flag = 0;
    unsigned char dataType = 0;
    
    // Build an array of all the blocks in the TAP file
    while (self.currentBytePointer < data.length) {
        
        blockLength = ((unsigned short *)&tapeBytes[self.currentBytePointer])[0];
        
        // Move the pointer to the start of the actual tap block
        self.currentBytePointer += 2;
        
        flag = tapeBytes[self.currentBytePointer + cHEADER_FLAG_OFFSET];
        dataType = tapeBytes[self.currentBytePointer + cHEADER_DATA_TYPE_OFFSET];
        
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
        else
        {
            newTAPBlock = [DataBlock new];
        }
        
        if (!newTAPBlock)
        {
            NSLog(@"Invalid flag found: %i", flag);
            return;
        }

        newTAPBlock.blockLength = blockLength;
        newTAPBlock.blockData = (unsigned char *)calloc(blockLength, sizeof(unsigned char));
        memcpy(newTAPBlock.blockData, &tapeBytes[self.currentBytePointer], blockLength);
        [self.tapBlocks addObject:newTAPBlock];

        self.currentBytePointer += blockLength;
        
    }
    if (self.delegate)
    {
        [self.delegate blocksChanged];
    }
}

- (void)updateTapeWithTStates:(int)tStates
{
    
    if (self.currentBlockIndex > self.tapBlocks.count - 1)
    {
        NSLog(@"TAPE STOPPED");
        self.playing = NO;
        tapeInputBit = 0;
        self.currentBlockIndex = self.tapBlocks.count - 1;
        [self blocksChanged];
        return;
    }

    if (newBlock)
    {
        newBlock = NO;
        
        currentBlock = [self.tapBlocks objectAtIndex:self.currentBlockIndex];
        
        if ([currentBlock isKindOfClass:[ProgramHeader class]])
        {
            NSLog(@"Processing Program Header");
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }
        else if ([currentBlock isKindOfClass:[NumericDataHeader class]])
        {
            NSLog(@"Processing Numberic Header");
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }
        else if ([currentBlock isKindOfClass:[AlphaNumericDataHeader class]])
        {
            NSLog(@"Processing Alpha Numeric Header");
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }
        else if ([currentBlock isKindOfClass:[ByteHeader class]])
        {
            NSLog(@"Processing Byte Header");
            processingState = eHeaderPilot;
            nextProcessingState = eHeaderDataStream;
        }
        else if ([currentBlock isKindOfClass:[DataBlock class]])
        {
            NSLog(@"Processing Data Block");
            processingState = eDataPilot;
            nextProcessingState = eDataStream;
        }
        
        self.currentBytePointer = 0;
        currentDataBit = 0;
        pilotPulseTStates = 0;
        pilotPulses = 0;
        dataPulseTStates = 0;
        flipTapeBit = YES;
        [self blocksChanged];
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
    if (pilotPulses < cPILOT_HEADER_PULSES)
    {
        if (flipTapeBit)
        {
            tapeInputBit ^= 1;
            flipTapeBit = NO;
        }
        
        if (pilotPulseTStates >= cPILOT_PULSE_TSTATE_LENGTH)
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
    if (pilotPulses < cPILOT_DATA_PULSES)
    {
        if (flipTapeBit)
        {
            tapeInputBit ^= 1;
            flipTapeBit = NO;
        }
        
        if (pilotPulseTStates >= cPILOT_PULSE_TSTATE_LENGTH)
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
    
    if (syncPulseTStates >= cFIRST_SYNC_PULSE_TSTATE_DELAY)
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
    
    if (syncPulseTStates >= cSECOND_SYNC_PULSE_TSTATE_DELAY)
    {
        syncPulseTStates = 0;
        self.currentBytePointer = 0;
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
    int currentBlockLength = [[self.tapBlocks objectAtIndex:self.currentBlockIndex] getDataLength];
    unsigned char byte = [[self.tapBlocks objectAtIndex:self.currentBlockIndex] blockData][self.currentBytePointer];
    unsigned char bit = (byte << currentDataBit) & 128;
    
    currentDataBit += 1;
    if (currentDataBit > 7)
    {
        currentDataBit = 0;
        self.currentBytePointer += 1;
        if (self.currentBytePointer > currentBlockLength)
        {
            processingState = eBlockPause;
            blockPauseTStates = 0;
            return;
        }
    }
    
    if (bit)
    {
        dataPulseTStates = cDATA_BIT_ONE_PULSE_TSTATE_DELAY;
    }
    else
    {
        dataPulseTStates = cDATA_BIT_ZERO_PULSE_TSTATE_DELAY;
    }
    flipTapeBit = YES;
    dataBitTStates = 0;
    dataPulseCount = 0;
    processingState = eDataBit;
}

- (void)generateHeaderDataStreamWithTStates:(int)tStates
{
    int currentBlockLength = cHEADER_BLOCK_LENGTH;
    unsigned char byte = [[self.tapBlocks objectAtIndex:self.currentBlockIndex] blockData][self.currentBytePointer];
    unsigned char bit = (byte << currentDataBit) & 128;
    
    currentDataBit += 1;
    if (currentDataBit > 7)
    {
        currentDataBit = 0;
        self.currentBytePointer += 1;
        currentBlock.currentByte += 1;
        if (self.currentBytePointer > currentBlockLength)
        {
            processingState = eBlockPause;
            blockPauseTStates = 0;
            return;
        }
    }
    
    if (bit)
    {
        dataPulseTStates = cDATA_BIT_ONE_PULSE_TSTATE_DELAY;
    }
    else
    {
        dataPulseTStates = cDATA_BIT_ZERO_PULSE_TSTATE_DELAY;
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
        self.currentBlockIndex += 1;
        newBlock = YES;
    }

    // Introduce a random crackle in between blocks to produce a similar experience as loading from a real tape
    // on a ZX Spectrum.
    if (arc4random_uniform(200000) == 1)
    {
        tapeInputBit ^= 1;
    }
}

- (void)play
{
    self.playing = YES;
    [self blocksChanged];
}

- (void)saveToURL:(NSURL *)url
{
    NSMutableData *saveData = [NSMutableData new];
    
    for (TAPBlock *tapBlock in self.tapBlocks) {
        unsigned short length = tapBlock.blockLength;
        [saveData appendBytes:&length length:sizeof(unsigned short)];
        [saveData appendBytes:tapBlock.blockData length:length];
    }
    
    [saveData writeToURL:url atomically:NO];
}

- (void)stop
{
    self.playing = NO;
    tapeInputBit = 0;
    [self blocksChanged];
}

- (void)rewind
{
    pilotPulseTStates = 0;
    syncPulseTStates = 0;
    pilotPulses = 0;
    processingState = eNoTape;
    blockPauseTStates = 0;
    tapeInputBit = 0;
    self.currentBytePointer = 0;
    newBlock = YES;
    [self blocksChanged];
    if (self.delegate)
    {
        [self.delegate tapeBytesProcessed:self.currentBytePointer];
    }
}

- (void)eject
{
    [self stop];
    [self.tapBlocks removeAllObjects];
    pilotPulseTStates = 0;
    syncPulseTStates = 0;
    pilotPulses = 0;
    processingState = eNoTape;
    blockPauseTStates = 0;
    tapeInputBit = 0;
    newBlock = YES;
    self.currentBytePointer = 0;
    self.currentBlockIndex = 0;
    self.tapeLoaded = NO;
    [self blocksChanged];
}

- (void)reset
{
    self.tapeLoaded = NO;
    self.playing = NO;
    [self.tapBlocks removeAllObjects];
    [self blocksChanged];
}

#pragma mark - Saving

- (void)saveTAPBlockWithMachine:(ZXSpectrum *)machine
{
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    char parity = 0;
    short length = core->GetRegister(CZ80Core::eREG_DE) + 2;

    NSMutableData *data = [NSMutableData new];
    
    [data appendBytes:&length length:2];

    parity = core->GetRegister(CZ80Core::eREG_A);
    [data appendBytes:&parity length:1];
    
    for (int i = 0; i < core->GetRegister(CZ80Core::eREG_DE); i++)
    {
        // Read memory using the debug read from the core which takes into account any paging
        // on the 128k Spectrum
        char byte = core->Z80CoreDebugMemRead(core->GetRegister(CZ80Core::eREG_IX) + i, NULL);
        parity ^= byte;
        [data appendBytes:&byte length:1];
    }
    
    [data appendBytes:&parity length:1];
    
    [self processTAPFileData:data];

    // Once a block has been saved this is the RET address
    core->SetRegister(CZ80Core::eREG_PC, 0x053e);
}

#pragma mark - Turbo Loading

- (void)loadTAPBlockWithMachine:(ZXSpectrum *)machine
{
    CZ80Core *core = (CZ80Core *)[machine getCore];

    if (self.currentBlockIndex >= self.tapBlocks.count)
    {
        machine->loadTrapTriggered = false;
        core->SetRegister(CZ80Core::eREG_F, core->GetRegister(CZ80Core::eREG_F) & ~CZ80Core::FLAG_C);
        core->SetRegister(CZ80Core::eREG_PC, 0x05e2);
        return;
    }
    
    int expectedBlockType = core->GetRegister(CZ80Core::eREG_ALT_A);
    int startAddress = core->GetRegister(CZ80Core::eREG_IX);
    
    // Some TAP files have blocks which are shorter that what is expected in DE (Chuckie Egg 2)
    // so just take the smallest value
    int blockLength = core->GetRegister(CZ80Core::eREG_DE);
    int tapBlockLength = [self.tapBlocks[self.currentBlockIndex] getDataLength];
    blockLength = (blockLength < tapBlockLength) ? blockLength : tapBlockLength;
    int success = 1;
    
    if ([self.tapBlocks[self.currentBlockIndex] getFlag] == expectedBlockType)
    {
        if (core->GetRegister(CZ80Core::eREG_ALT_F) & CZ80Core::FLAG_C)
        {
            self.currentBytePointer = cHEADER_DATA_TYPE_OFFSET;
            int checksum = expectedBlockType;
            
            for (int i = 0; i < blockLength; i++)
            {
                unsigned char tapByte = [self.tapBlocks[self.currentBlockIndex] blockData][self.currentBytePointer];
                core->Z80CoreDebugMemWrite(startAddress + i, tapByte, NULL);
                checksum ^= tapByte;
                self.currentBytePointer++;
            }
            
            int expectedChecksum = [self.tapBlocks[self.currentBlockIndex] getChecksum];
            if (expectedChecksum != checksum)
            {
                success = 0;
            }
        }
        else
        {
            success = 1;
        }
    }
    
    if (success)
    {
        core->SetRegister(CZ80Core::eREG_F, (core->GetRegister(CZ80Core::eREG_F) | CZ80Core::FLAG_C));
    }
    else
    {
        core->SetRegister(CZ80Core::eREG_F, (core->GetRegister(CZ80Core::eREG_F) & ~CZ80Core::FLAG_C));
    }
    
    self.currentBlockIndex++;
    [self blocksChanged];
    core->SetRegister(CZ80Core::eREG_PC, 0x05e2);
}

#pragma mark - Debug print

- (void)printTAPContents
{
    
#ifndef DEBUG
    return;
#endif
    
    for (TAPBlock *tapBlock in self.tapBlocks) {
        
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
    return self.blockData[cHEADER_FLAG_OFFSET];
}

- (unsigned char)getDataType
{
    return self.blockData[cHEADER_DATA_TYPE_OFFSET];
}

- (NSString *)getFilename
{
    char *filename = (char *)calloc(cHEADER_FILENAME_LENGTH, sizeof(char));
    memcpy(filename, &_blockData[cHEADER_FILENAME_OFFSET], cHEADER_FILENAME_LENGTH);
    NSString *filenameString = [NSString stringWithCString:filename encoding:NSASCIIStringEncoding];
    free(filename);
    return filenameString;
}

- (unsigned short)getDataLength
{
    return self.blockLength;
}

- (unsigned char)getChecksum
{
    return self.blockData[cHEADER_CHECKSUM_OFFSET];
}

@end

#pragma mark - Program Header

@implementation ProgramHeader

- (NSString *)blockType
{
    int lineNumber = [self getAutostartLine];
    if (lineNumber == 32768)
    {
        lineNumber = 0;
    }
    return [NSString stringWithFormat:@"Program Header: '%@' Line %i", [self getFilename], lineNumber];
}

- (unsigned short)getAutostartLine
{
    return ((unsigned short *)&self.blockData[cPROGRAM_HEADER_AUTOSTART_LINE_OFFSET])[0];
}

- (unsigned short)getProgramLength
{
    return ((unsigned short *)&self.blockData[cPROGRAM_HEADER_PROGRAM_LENGTH_OFFSET])[0];
}

- (unsigned char)getChecksum
{
    return self.blockData[cPROGRAM_HEADER_CHECKSUM_OFFSET];
}

- (unsigned short)getDataLength
{
    return cHEADER_BLOCK_LENGTH;
}

@end

#pragma mark - Numeric Data Header

@implementation NumericDataHeader

- (NSString *)blockType
{
    return @"Numeric Data Header";
}

- (unsigned char)getVariableName
{
    return self.blockData[cNUMERIC_DATA_HEADER_VARIBABLE_NAME_OFFSET];
}

- (unsigned short)getDataLength
{
    return cHEADER_BLOCK_LENGTH - 2;
}

@end

#pragma mark - Alpha Numeric Data Header

@implementation AlphaNumericDataHeader

- (NSString *)blockType
{
    return @"Alpha Numeric Data Header";
}

- (unsigned char)getVariableName
{
    return self.blockData[cALPHA_NUMERIC_DATA_HEADER_VARIABLE_NAME_OFFSET];
}

- (unsigned short)getDataLength
{
    return cHEADER_BLOCK_LENGTH - 2;
}

@end

#pragma mark - Byte Header

@implementation ByteHeader

- (NSString *)blockType
{
    return [NSString stringWithFormat:@"   Byte Header: '%@' %i, %i", [self getFilename], [self getStartAddress], [self getDataLength]];
}

- (unsigned short)getStartAddress
{
    return ((unsigned short *)&self.blockData[cBYTE_HEADER_START_ADDRESS_OFFSET])[0];
}

- (unsigned char)getChecksum
{
    return self.blockData[self.blockLength - 1];
}

- (unsigned short)getDataLength
{
    return cHEADER_BLOCK_LENGTH - 2;
}

@end

#pragma mark - Data Block

@implementation DataBlock

- (NSString *)blockType
{
    return [NSString stringWithFormat:@"          Data:              %i", [self getDataLength] - 2];
}

- (NSString *)getFilename
{
    return @"";
}

- (unsigned char *)getDataBlock
{
    unsigned char *dataBlock = (unsigned char *)calloc([self getDataLength], sizeof(unsigned char));
    memcpy(dataBlock, &self.blockData[cDATA_BLOCK_DATA_LENGTH_OFFSET], sizeof(unsigned char) * [self getDataLength]);
    return dataBlock;
}

- (unsigned char)getDataType
{
    return self.blockData[cHEADER_FLAG_OFFSET];
}

- (unsigned char)getChecksum
{
    return self.blockData[self.blockLength - 1];
}

@end


