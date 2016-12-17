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
    // 
    // Should the tape bit be flipped
    BOOL flipTapeBit;
    // Current processing state e.g. generating pilot, streaming data
    int processingState;
    // Current byte location in the tape data being processed
    int currentBytePointer;
    // How many tStates have passed since starting the pause between data blocks
    int blockPauseTStates;

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
    }
    return self;
}

- (BOOL)loadTapeWithURL:(NSURL *)url
{
    NSData *tapeData = [NSData dataWithContentsOfURL:url];
    const char *tapeBytes = (const char*)[tapeData bytes];
    
    // Identify the first header int he TAP file
    
    struct ByteHeader bh;
    
    memcpy(&bh, tapeBytes, sizeof(unsigned char) * cHeaderLength);
    
    NSLog(@"Block Length: %i", bh.blockLength);
    NSLog(@"Flag: %i", bh.flag);
    NSLog(@"Data Type: %i", bh.dataType);
    NSLog(@"Filename: %s", bh.filename);
    NSLog(@"Data Length: %i", bh.dataLength);
    NSLog(@"Start Address: %i", bh.startAddress);
    NSLog(@"Checksum: %i", bh.checksum);
    
    return YES;
}

- (void)updateTapeWithTStates:(int)tStates
{
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
            self.playing = NO;
            tapeInputBit = 0;
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
        NSLog(@"Finished Generating Sync 1");
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
        NSLog(@"Finished Generating Sync 2");
        syncPulseTStates = 0;
        processingState = eDataStream;
    }
    else
    {
        syncPulseTStates += tStates;
    }
}

- (void)generateDataStreamWithTStates:(int)tStates
{
    
}

- (void)play
{
    flipTapeBit = YES;
    pilotPulses = 0;
    pilotPulseTStates = 0;
    self.playing = YES;
    
    // By default when playing a tap the first pilot is a header pilot...hopefully!
    processingState = eHeaderPilot;
}

- (void)stop
{
    
}

@end
