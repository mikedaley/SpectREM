//
//  ZXSpectrum48.m
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXSpectrumSE.h"
#import "Z80Core.h"

#pragma mark - Extension Interface

@interface ZXSpectrumSE ()
{
    CZ80Core *core;
}

@end

#pragma mark - Implementation

@implementation ZXSpectrumSE

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
                         coreDebugRead,
                         coreDebugWrite,
                         (__bridge void *)self);
        
		// Register the opcode callback for the save trapping
		core->RegisterOpcodeCallback(opcodeCallback);
		
		displayPage = 1;
        disablePaging = YES;
        
        [self reset:YES];
        
    }
    return self;
}

- (void)start
{
    [super start];
    displayPage = 1;
}

- (void)reset:(BOOL)hard
{
    [super reset:hard];
    currentRAMPage = 0;
    currentROMPage = 0;
    displayPage = 1;
    disablePaging = YES;
}

#pragma mark - Memory Access

static unsigned char coreMemoryRead(unsigned short address, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    return machine->memory[address];
}

static void coreMemoryWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    if (address < 16384)
    {
        return;
    }

    // Only update screen if display memory has been written too
    if (address >= 16384 && address < 16384 + 6144 + 768){
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, m);
    }
    
    machine->memory[address] = data;
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    if (address >= 16384 && address <= 32767)
    {
        machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->machineInfo.tsPerFrame] );
    }
}

#pragma mark - Debug Memory Access

static unsigned char coreDebugRead(unsigned int address, void *m, void *d)
{
	ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
	return machine->memory[address];
}

static void coreDebugWrite(unsigned int address, unsigned char byte, void *m, void *d)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    machine->memory[address] = byte;
}

#pragma mark - Callback functions

static bool opcodeCallback(unsigned char opcode, unsigned short address, void *m)
{
	ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
	
	if (opcode == 0x08 && (address == 0x04d0 || address == 0x0076))
	{
		machine->saveTrapTriggered = true;
		
		// Skip the instruction
		return true;
	}
    else if (machine->saveTrapTriggered)
    {
        machine->saveTrapTriggered = false;
        return false;
    }
    
    // Trap ROM loading
    if (opcode == 0xc0 && (address == 0x056b || address == 0x0111) && machine.instaTAPLoading)
    {
        machine->loadTrapTriggered = true;
        return true;
    }
    else if (machine->loadTrapTriggered)
    {
        machine->loadTrapTriggered = false;
        return false;
    }
    
    return false;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Open_SEBASIC_3.12" ofType:@"rom"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    const char *fileBytes = (const char*)[data bytes];
    
    memcpy(memory, fileBytes, data.length);
}

- (void *)getCore
{
    return (void*)core;
}

- (NSString *)machineName
{
    return @"ZX Spectrum 48k SE";
}

@end
