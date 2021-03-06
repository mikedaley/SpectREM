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
#import "ConfigViewController.h"

#pragma mark - Extension Interface

@interface ZXSpectrum48 ()
{
    
@public
    CZ80Core *core;
    EmulationViewController *_emuViewController;
}

@end

#pragma mark - Implementation

@implementation ZXSpectrum48

- (void)dealloc
{
    delete core;
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController machineInfo:(MachineInfo)info
{
    if (self = [super initWithEmulationViewController:emulationViewController machineInfo:info])
    {
        NSLog(@"MACHINE_INIT");
        _emuViewController = emulationViewController;
        
        // We need 64k of memory total for the 48k Speccy
        memory = (unsigned char*)calloc(c64k, sizeof(unsigned char));
        
        // Multiface ROM/RAM setup
        multifaceMemory = (unsigned char*)calloc(cMULTIFACE_MEM_SIZE, sizeof(unsigned char));
        
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
        
        // SmartCard ROM/RAM setup
        smartCardPortFAF3 = 0;
        smartCardPortFAFB = 0;
        smartCardSRAM = (unsigned char*)calloc(cSMART_CARD_RAME_SIZE, sizeof(unsigned char));
        
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
    // Clear SmartCard SRAM and ports, happens on both soft and hard reset
    smartCardPortFAF3 = 0;
    memset(smartCardSRAM, 0, cSMART_CARD_RAME_SIZE);
    smartCardPortFAFB = 0;
    
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
    
    if (machine->smartCardActive && (machine->smartCardPortFAF3&0x80) && address >= 8192 && address < 16384)
    {
        return machine->smartCardSRAM[ (address << (machine->smartCardPortFAF3&7)) - 8192];
    }
    if((address&0xff)==0x72)
    {
        if (machine->smartCardActive && (machine->smartCardPortFAFB&0x40))
        {
            unsigned char retOpCode = machine->memory[address];
            [machine loadDefaultROM];
            machine->smartCardPortFAFB&=~0x40;
            return retOpCode;
        }
    }
    return machine->memory[address];
}

static void coreMemoryWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    
    if (address < 16384)
    {
        if (machine->multifacePagedIn && address >= 8192)
        {
            machine->multifaceMemory[ address ] = data;
        }
        
        if (machine->smartCardActive && (machine->smartCardPortFAF3&0x80) && address >= 8192 && address < 16384)
        {
            machine->smartCardSRAM[ (address << (machine->smartCardPortFAF3&7)) - 8192] = data;
        }
        
        return;
    }
    
    // Only update screen if display memory has been written too
    if (address >= 16384 && address < cBITMAP_ADDRESS + cBITMAP_SIZE + cATTR_SIZE){
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + machine->machineInfo.paperDrawingOffset, machine);
    }
    
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

#pragma mark - Opcode callback function

static bool opcodeCallback(unsigned char opcode, unsigned short address, void *m)
{
    ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    // Trap keyboard wait and inject any keystrokes
    if (address + 1 == 0x10b0)
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
    
    // Trap ROM tape saving
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
        
        
        //TODO: Find a way to stop labels being used when a number is used as an operand which matches a label address!
        
        //		const char *label = Get48KRomAddressLabel(label_address);
        //
        //		if ( label != NULL )
        //		{
        //			snprintf(buffer, 64, "%s", label);
        //		}
        //        else
        //        {
        //            ZXSpectrum48 *machine = (__bridge ZXSpectrum48 *)param;
        //            NSString *key = [NSString stringWithFormat:@"%04X", label_address];
        //            NSString *asmLabel = [machine.emulationViewController.debugLabels objectForKey:key];
        //            if (asmLabel.length > 0)
        //            {
        //                snprintf(buffer, 64, "%s", [asmLabel cStringUsingEncoding:NSUTF8StringEncoding]);
        //            }
        //        }
    }
    
    return buffer;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSURL *url = [self.preferences URLForKey:cRom48Path];
    NSData *data = [NSData dataWithContentsOfURL:url];
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
