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
#import "ConfigViewController.h"

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
    delete core;
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController machineInfo:(MachineInfo)info
{
    if (self = [super initWithEmulationViewController:emulationViewController machineInfo:info])
    {
        // We need 128k of memory total for the 128k Speccy and also two 16k ROM chips
        memory = (unsigned char*)calloc(c128k, sizeof(unsigned char));
        rom = (unsigned char*)calloc(c32k, sizeof(unsigned char));
        
        // Multiface ROM/RAM setup
        multifaceMemory = (unsigned char*)calloc(cMULTIFACE_MEM_SIZE, sizeof(unsigned char));
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MF128" ofType:@"rom"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        const char *fileBytes = (const char*)[data bytes];
        memcpy(multifaceMemory, fileBytes, data.length);

        self.emulationViewController = emulationViewController;
        
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
		
		[self reset:YES];
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
    last7ffd = 0;
}

- (void)reset:(BOOL)hard
{
    if (hard)
    {
        for (int i = 0; i < 128 * 1024; i++)
        {
            memory[i] = arc4random_uniform(255);
        }
        
        for (int i = 8192; i < 16384; i++)
        {
            multifaceMemory[i] = 0;
        }

    }
    [super reset:hard];
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
        if (machine->multifacePagedIn)
        {
            return machine->multifaceMemory[ address ];
        }
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
        if (machine->multifacePagedIn && address >= 8192)
        {
            machine->multifaceMemory[ address ] = data;
        }
        return;
    }
    else if (page == 1)
    {
        machine->memory[(5 * 16384) + address] = data;
    }
    else if (page == 2)
    {
        machine->memory[(2 * 16384) + address] = data;
    }
    else if (page == 3)
    {
        machine->memory[(machine->currentRAMPage * 16384) + address] = data;
    }
    
    // Only update screen if display memory has been written too
    if (address >= 16384 && address < 16384 + 6144 + 768){
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, machine);
    }
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, void *m)
{
    ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    
    int page = address / 16384;
    if (page == 1 ||
        (page == 3 &&
         (machine->currentRAMPage == 1 || machine->currentRAMPage == 3 || machine->currentRAMPage == 5 || machine->currentRAMPage == 7)))
    {
        machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->machineInfo.tsPerFrame] );
    }
}

#pragma mark - Debug Memory Access

static unsigned char coreDebugRead(unsigned int address, void *m, void *d)
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

static void coreDebugWrite(unsigned int address, unsigned char byte, void *m, void *d)
{
    ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    int page = address / 16384;
    address &= 16383;
    
    if (page == 0)
    {
        machine->rom[(machine->currentROMPage * 16384) + address] = byte;
    }
    else if (page == 1)
    {
        machine->memory[(5 * 16384) + address] = byte;
    }
    else if (page == 2)
    {
        machine->memory[(2 * 16384) + address] = byte;
    }
    else if (page == 3)
    {
        machine->memory[(machine->currentRAMPage * 16384) + address] = byte;
    }
}

#pragma mark - Callback functions

static bool opcodeCallback(unsigned char opcode, unsigned short address, void *m)
{
	ZXSpectrum128 *machine = (__bridge ZXSpectrum128 *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
	
    // Trap keyboard key press and inject any keystrokes
    if (address - 1 == 0x3683)
    {
        if (machine.keystrokesBuffer.count > 0)
        {
            unsigned char newKeyPressed = core->Z80CoreDebugMemRead(cFLAGS, NULL) & 32;
            if (!newKeyPressed && core->GetTStates() % 5)
            {
                core->Z80CoreDebugMemWrite(cFLAGS, newKeyPressed | 32, NULL);
                core->Z80CoreDebugMemWrite(cLAST_K, [(NSNumber *)[machine.keystrokesBuffer objectAtIndex:0] unsignedCharValue], NULL);
                [machine.keystrokesBuffer removeObjectAtIndex:0];
            }
        }
    }
 
    // Tap ROM Saving
    if (opcode == 0x08 && address == 0x04d0)
	{
		machine->saveTrapTriggered = true;
		return true;
	}
	else if (machine->saveTrapTriggered)
	{
		machine->saveTrapTriggered = false;
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
    }
	
	return false;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSURL *url = [self.preferences URLForKey:cRom1280Path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    const char *fileBytes = (const char*)[data bytes];
    
    memcpy(rom, fileBytes, data.length);

    url = [self.preferences URLForKey:cRom1281Path];
    data = [NSData dataWithContentsOfURL:url];
    
    fileBytes = (const char*)[data bytes];

    memcpy(rom + 16384, fileBytes, data.length);
    
}

#pragma mark - Getters

- (void *)getCore
{
    return (void*)core;
}

- (NSString *)machineName
{
    return @"ZX Spectrum 128k";
}

@end
