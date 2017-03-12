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
        
        // Multiface ROM/RAM setup
        multifaceMemory = (unsigned char*)calloc(16 * 1024, sizeof(unsigned char));
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MF1" ofType:@"rom"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        const char *fileBytes = (const char*)[data bytes];
        memcpy(multifaceMemory, fileBytes, data.length);

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

		// Register the callback for the debug information
		core->RegisterDebugCallback(debugDisplayCallback);
		
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
    if (hard)
    {
        for (int i = 0; i < 64 * 1024; i++)
        {
            memory[i] = arc4random_uniform(255);
        }
        
        for (int i = 8192; i < 16384; i++)
        {
            multifaceMemory[i] = 0;
        }
    }
    [super reset:hard];
    currentRAMPage = 0;
    currentROMPage = 0;
    displayPage = 1;
    disablePaging = YES;
}

#pragma mark - Memory Access

static unsigned char coreMemoryRead(unsigned short address, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    
    if (address < 16384 && machine->multifacePagedIn)
    {
        return machine->multifaceMemory[ address ];
    }
    
    return machine->memory[address];
}

static void coreMemoryWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;

    if (address < 16384)
    {
        if (machine->multifacePagedIn && address > 8192)
        {
            machine->multifaceMemory[ address ] = data;
        }
        
        return;
    }

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

#pragma mark - Debug Memory Access

static unsigned char coreDebugRead(unsigned int address, void *m, void *d)
{
	ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
	return machine->memory[address];
}

static void coreDebugWrite(unsigned int address, unsigned char byte, void *m, void *d)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    machine->memory[address] = byte;
}

#pragma mark - Callback functions

static bool opcodeCallback(unsigned char opcode, unsigned short address, void *m)
{
	ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
	
	// Trap ROM tape saving
    if (opcode == 0x08 && address == 0x04d0)
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
    if (opcode == 0xc0 && (address == 0x056b || address == 0x0111))
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

#pragma mark - Debug Display Callback

const char *Get48KRomAddressLabel(unsigned short address);

char *debugDisplayCallback(char *buffer, unsigned int variableType, unsigned short address, unsigned int value, void *param, void *data)
{
	// First we only want to alter addresses
	if ( variableType == CZ80Core::eVARIABLETYPE_Word || variableType == CZ80Core::eVARIABLETYPE_RelativeOffset )
	{
		// Words are fine, relative offsets we need to update
		unsigned short label_address = value;
		
		if ( variableType == CZ80Core::eVARIABLETYPE_RelativeOffset )
		{
			label_address = address + value + 1;
		}
		
		const char *label = Get48KRomAddressLabel(label_address);
		
		if ( label != NULL )
		{
			snprintf(buffer, 64, "%s", label);
		}
	}
	
	return buffer;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"48" ofType:@"rom"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    const char *fileBytes = (const char*)[data bytes];
    memcpy(memory, fileBytes, data.length);
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
