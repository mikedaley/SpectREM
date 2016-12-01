//
//  ZXSpectrum48.m
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXSpectrum48.h"
#import "Z80Core.h"

#pragma mark - Extension Interface

@interface ZXSpectrum48 ()
{
@public
    CZ80Core *core;
}

@end

#pragma mark - Implementation

@implementation ZXSpectrum48

- (void)dealloc
{
    NSLog(@"Deallocating ZXSpectrum48");
    delete core;
    free (memory);
    free (rom);
    free(emuDisplayBuffer);
    free(self.audioBuffer);
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController machineInfo:(MachineInfo)info
{
    if (self = [super initWithEmulationViewController:emulationViewController machineInfo:info])
    {
        // We need 64k of memory total for the 48k Speccy
        memory = (unsigned char*)calloc(64 * 1024, sizeof(unsigned char));

        core = new CZ80Core;
        core->Initialise(coreMemoryRead,
                         coreMemoryWrite,
                         coreIORead,
                         coreIOWrite,
                         coreMemoryContention,
                         coreIOContention,
                         (__bridge void *)self);
        
        displayPage = 1;
        disablePaging = YES;
        

        [self loadDefaultROM];
        
    }
    return self;
}

- (void)start
{
    [super start];
    displayPage = 1;
}

- (void)reset
{
    [super reset];
    currentRAMPage = 0;
    currentROMPage = 0;
    displayPage = 1;
    disablePaging = YES;
}

#pragma mark - Memory Access

static unsigned char coreMemoryRead(unsigned short address, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    return machine->memory[address];
}

static void coreMemoryWrite(unsigned short address, unsigned char data, void *m)
{
    if (address < 16384)
    {
        return;
    }
    
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;

    updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, m);
    machine->memory[address] = data;
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    
    if (address >= 16384 && address <= 32767)
    {
        machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->machineInfo.tsPerFrame] );
    }
}

static void coreIOContention(unsigned short address, unsigned int tstates, void *m)
{
    // NOT USED
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"48" ofType:@"rom"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    const char *fileBytes = (const char*)[data bytes];
    
    for (int addr = 0; addr < data.length; addr++)
    {
        memory[addr] = fileBytes[addr];
    }
}

#pragma mark - Core getters

- (void *)getCore
{
    return (void*)core;
}

- (NSString *)machineName
{
    return @"ZX Spectrum 48k";
}

@end
