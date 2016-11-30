//
//  ZXSpectrum128.m
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXSpectrum128.h"
#import "Z80Core.h"

#pragma mark - Private Interface

@interface ZXSpectrum128 ()
{
    CZ80Core *core;
}

@end

#pragma mark - Implementation

@implementation ZXSpectrum128

- (void)dealloc
{
    NSLog(@"Deallocating ZXSpectrum128");
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
        // We need 64k of memory total for the 128k Speccy
        memory = (unsigned char*)calloc(128 * 1024, sizeof(unsigned char));
        rom = (unsigned char*)calloc(32 * 1024, sizeof(unsigned char));
        
        self.emulationViewController = emulationViewController;
        
        core = new CZ80Core;
        core->Initialise(coreMemoryRead,
                         coreMemoryWrite,
                         coreIORead,
                         coreIOWrite,
                         coreMemoryContention,
                         coreIOContention,
                         (__bridge void *)self);
                        
        currentROMPage = 0;
        currentRAMPage = 0;
        displayPage = 5;
        disablePaging = NO;
        
        [self loadDefaultROM];
        
    }
    return self;
}

- (void)start
{
    [super start];
    currentROMPage = 0;
    currentRAMPage = 0;
    displayPage = 5;
    disablePaging = NO;    
}

- (void)reset
{
    [super reset];
    currentROMPage = 0;
    currentRAMPage = 0;
    displayPage = 5;
    disablePaging = NO;
}

#pragma mark - Memory Access

static unsigned char coreMemoryRead(unsigned short address, void *m)
{
    ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    
    int page = address / 16384;
    address &= 16383;
    
    if (page == 0)
    {
        return (machine->rom[(machine->currentROMPage * 16384) + address]);
    }
    else if (page == 1)
    {
        return (machine->memory[(5 * 16384) + address]);
    }
    else if (page == 2)
    {
        return (machine->memory[(2 * 16384) + address]);
    }
    else if (page == 3)
    {
        return (machine->memory[(machine->currentRAMPage * 16384) + address]);
    }
    
    return 0;
}

static void coreMemoryWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    
    int page = address / 16384;
    address &= 16383;
    
    if (page == 0)
    {
        return;
    }
    else if (page == 1)
    {
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, m);
        machine->memory[(5 * 16384) + address] = data;
    }
    else if (page == 2)
    {
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, m);
        machine->memory[(2 * 16384) + address] = data;
    }
    else if (page == 3)
    {
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, m);
        machine->memory[(machine->currentRAMPage * 16384) + address] = data;
    }
    
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, void *m)
{
    ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    
    int page = address / 16384;
    if (page == 1 || page == 3 || page == 5 || page == 7)
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"128-0" ofType:@"rom"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    const char *fileBytes = (const char*)[data bytes];
    
    for (int addr = 0; addr < data.length; addr++)
    {
        rom[addr] = fileBytes[addr];
    }

    path = [[NSBundle mainBundle] pathForResource:@"128-1" ofType:@"rom"];
    data = [NSData dataWithContentsOfFile:path];
    
    fileBytes = (const char*)[data bytes];
    
    for (int addr = 0; addr < data.length; addr++)
    {
        rom[addr + 16384] = fileBytes[addr];
    }
}

#pragma mark - Getters

- (void *)getCore
{
    return (void*)core;
}

@end
