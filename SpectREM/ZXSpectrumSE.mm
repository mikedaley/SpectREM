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
    CGColorSpaceRelease(self.colorSpace);
    delete core;
    free (memory);
    free (rom);
    free(emuDisplayBuffer);
    free(self.audioBuffer);
}

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController
{
    if (self = [super initWithEmulationViewController:emulationViewController])
    {
        // We need 64k of memory total for the 48k Speccy
        memory = (unsigned char*)calloc(64 * 1024, sizeof(unsigned char));
        
        self.emulationViewController = emulationViewController;
        
        core = new CZ80Core;
        core->Initialise(coreMemoryRead,
                         coreMemoryWrite,
                         coreIORead,
                         coreIOWrite,
                         coreMemoryContention,
                         coreIOContention,
                         (__bridge void *)self);
        
        event = eNone;
        
        borderColour = 7;
        frameCounter = 0;
        
        tsPerFrame = 69888;
        tsToOrigin = 14335;
        tsPerLine = 224;
        tsTopBorder = 56 * tsPerLine;
        tsVerticalBlank = 8 * tsPerLine;
        tsVerticalDisplay = 192 * tsPerLine;
        tsHorizontalDisplay = 128;
        tsPerChar = 4;
        
        pxTopBorder = 56;
        pxVerticalBlank = 8;
        pxHorizontalDisplay = 256;
        pxVerticalDisplay = 192;
        pxHorizontalTotal = 448;
        pxVerticalTotal = 312;
        
        emuLeftBorderPx = 32;
        emuRightBorderPx = 64;
        
        emuBottomBorderPx = 56;
        emuTopBorderPx = 56;
        
        emuDisplayPxWidth = 256 + emuLeftBorderPx + emuRightBorderPx;
        emuDisplayPxHeight = 192 + emuTopBorderPx + emuBottomBorderPx;
        emuShouldInterpolate = NO;
        
        emuHScale = 1.0 / emuDisplayPxWidth;
        emuVScale = 1.0 / emuDisplayPxHeight;
        
        emuDisplayTs = 0;
        self.colorSpace = CGColorSpaceCreateDeviceRGB();

        displayPage = 1;
        disablePaging = YES;
        
        [self resetFrame];
        
        // Setup the display buffer and length used to store the output from the emulator
        emuDisplayBufferLength = (emuDisplayPxWidth * emuDisplayPxHeight) * cEmuDisplayBytesPerPx;
        emuDisplayBuffer = (unsigned char *)calloc(emuDisplayBufferLength, sizeof(unsigned char));

        self.emulationQueue = dispatch_queue_create("emulationQueue", nil);
        
        float fps = 50;
        
        audioSampleRate = 192000;
        audioBufferSize = (audioSampleRate / fps) * 6;
        self.audioBuffer = (int16_t *)malloc(audioBufferSize);
        audioTsStep = tsPerFrame / (audioSampleRate / fps);
        
        [self resetSound];
        [self buildContentionTable];
        [self buildScreenLineAddressTable];
        [self buildDisplayTsTable];
        [self resetKeyboardMap];
        [self loadDefaultROM];
        
        self.audioCore = [[AudioCore alloc] initWithSampleRate:audioSampleRate
                                               framesPerSecond:fps
                                                emulationQueue:self.emulationQueue
                                                       machine:self];
        [self.audioCore reset];

        [self setupObservers];
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
    core->Reset();
}

#pragma mark - CPU

- (void)generateFrame
{
    int count = tsPerFrame;
    
    while (count > 0)
    {
        int tsCPU = core->Execute(1, 32);
        
        count -= tsCPU;
        
        updateAudioWithTStates(tsCPU, (__bridge void*)self);
        
        if (core->GetTStates() >= tsPerFrame )
        {
            // The frame is finished so break out of the while loop. Not doing this caused drawing ts and core
            // ts to slowly go out of sync
            count = 0;
            
            updateScreenWithTStates(tsPerFrame - emuDisplayTs, (__bridge void *)self);
            
            core->ResetTStates( tsPerFrame );
            core->SignalInterrupt();
            
            float borderWidth = self.displayBorderWidth - 0.5;
            CGRect textureRect = CGRectMake((emuLeftBorderPx - borderWidth) * emuHScale,
                                            (emuBottomBorderPx - borderWidth) * emuVScale,
                                            1.0 - ((emuLeftBorderPx - borderWidth) * emuHScale + ((emuRightBorderPx - borderWidth) * emuHScale)),
                                            1.0 - (((emuTopBorderPx - borderWidth) * emuVScale) * 2));
            
            // Update the display texture using the data from the emulator display buffer
            CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, emuDisplayBuffer, emuDisplayBufferLength);
            self.texture = [SKTexture textureWithData:(__bridge NSData *)dataRef
                                                 size:CGSizeMake(emuDisplayPxWidth, emuDisplayPxHeight)
                                              flipped:YES];
            CFRelease(dataRef);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.emulationViewController updateEmulationDisplayWithTexture:[SKTexture textureWithRect:textureRect
                                                                                                      inTexture:self.texture]];
            });
            
            frameCounter++;
        }
    }
}

#pragma mark - Memory & IO methods

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
    updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + cPaperDrawingOffset, m);
    machine->memory[address] = data;
}

static unsigned char coreIORead(unsigned short address, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    // Calculate the necessary contention based on the Port number being accessed and if the port belongs to the ULA.
    // All non-even port numbers below to the ULA. N:x means no contention to be added and just advance the tStates.
    // C:x means that contention should be calculated based on the current tState value and then x tStates are to be
    // added to the current tState count
    //
    // in 40 - 7F?| Low bit | Contention pattern
    //------------+---------+-------------------
    //		No    |  Reset  | N:1, C:3
    //		No    |   Set   | N:4
    //		Yes   |  Reset  | C:1, C:3
    //		Yes   |   Set   | C:1, C:1, C:1, C:1
    //
    if (address >= 16384 && address <= 32767)
    {
        if ((address & 1) == 0)
        {
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(3);
        }
        else
        {
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
        }
    } else {
        if ((address & 1) == 0)
        {
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(3);
        }
        else
        {
            machine->core->AddTStates(4);
        }
    }
    
    // If the address does not belong to the ULA then return the floating bus value
    if (address & 0x01)
    {
        // TODO: Add Kemptston joystick support. Until then return 0. Byte returned by a Kempston joystick is in the
        // format: 000FDULR. F = Fire, D = Down, U = Up, L = Left, R = Right
        if ((address & 0xff) == 0x1f)
        {
            return 0x0;
        }
        else if ((address & 0xc002) == 0xc000)
        {
            return [machine.audioCore readAYData];
        }

        return floatingBus(m);
    }
    
    // Default return value
    __block int result = 0xff;
    
    // Check to see if any keys have been pressed
    for (int i = 0; i < 8; i++)
    {
        if (!(address & (0x100 << i)))
        {
            result &= machine->keyboardMap[i];
        }
    }
    
    return result;
}

static void coreIOWrite(unsigned short address, unsigned char data, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    // Calculate the necessary contention based on the Port number being accessed and if the port belongs to the ULA.
    // All non-even port numbers below to the ULA. N:x means no contention to be added and just advance the tStates.
    // C:x means that contention should be calculated based on the current tState value and then x tStates are to be
    // added to the current tState count
    //
    // in 40 - 7F?| Low bit | Contention pattern
    //------------+---------+-------------------
    //		No    |  Reset  | N:1, C:3
    //		No    |   Set   | N:4
    //		Yes   |  Reset  | C:1, C:3
    //		Yes   |   Set   | C:1, C:1, C:1, C:1
    //
    if (address >= 16384 && address <= 32767)
    {
        if ((address & 1) == 0)
        {
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(3);
        }
        else
        {
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(1);
        }
    }
    else
    {
        if ((address & 1) == 0)
        {
            machine->core->AddTStates(1);
            machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
            machine->core->AddTStates(3);
        }
        else
        {
            machine->core->AddTStates(4);
        }
    }
    
    // Port: 0xFE
    //   7   6   5   4   3   2   1   0
    // +---+---+---+---+---+-----------+
    // |   |   |   | E | M |  BORDER   |
    // +---+---+---+---+---+-----------+
    if (!(address & 0x01))
    {
        updateScreenWithTStates((machine->core->GetTStates() - machine->emuDisplayTs) + cBorderDrawingOffset, m);
        
        machine->audioEar = (data & 0x10) >> 4;
        machine->audioMic = (data & 0x08) >> 3;
        machine->borderColour = data & 0x07;
    }
}

static void coreMemoryContention(unsigned short address, unsigned int tstates, void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    if (address >= 16384 && address <= 32767)
    {
        machine->core->AddContentionTStates( machine->memoryContentionTable[machine->core->GetTStates() % machine->tsPerFrame] );
    }
}

static void coreIOContention(unsigned short address, unsigned int tstates, void *m)
{
    // NOT USED
}

#pragma mark - Floating Bus

// When the Z80 reads from an unattached port, such as 0xFF, it actually reads the data currently on the
// Spectrums ULA data bus. This may happen to be a byte being transferred from screen memory. If the ULA
// is building the border then the bus is idle and the return value is 0xFF, otherwise its possible to
// predict if the ULA is reading a pixel or attribute byte based on the current t-state.
// This routine works out what would be on the ULA bus for a given t-state and returns the result
static unsigned char floatingBus(void *m)
{
    ZXSpectrumSE *machine = (__bridge ZXSpectrumSE *)m;
    
    int cpuTs = machine->core->GetTStates() - 1;
    int currentDisplayLine = (cpuTs / machine->tsPerLine);
    int currentTs = (cpuTs % machine->tsPerLine);
    
    // If the line and tState are within the bitmap of the screen then grab the
    // pixel or attribute value
    if (currentDisplayLine >= (machine->pxTopBorder + machine->pxVerticalBlank)
        && currentDisplayLine < (machine->pxTopBorder + machine->pxVerticalBlank + machine->pxVerticalDisplay)
        && currentTs <= machine->tsHorizontalDisplay)
    {
        unsigned char ulaValueType = cFloatingBusTable[ currentTs & 0x07 ];
        
        int y = currentDisplayLine - (machine->pxTopBorder + machine->pxVerticalBlank);
        int x = currentTs >> 2;
        
        if (ulaValueType == ePixel)
        {
            return machine->memory[cBitmapAddress + machine->emuTsLine[y] + x];
        }
        
        if (ulaValueType == eAttribute)
        {
            return machine->memory[cBitmapAddress + cBitmapSize + ((y >> 3) << 5) + x];
        }
    }
    
    return 0xff;
}

#pragma mark - Load ROM

- (void)loadDefaultROM
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Open_SEBASIC_3.12" ofType:@"rom"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    const char *fileBytes = (const char*)[data bytes];
    
    for (int addr = 0; addr < data.length; addr++)
    {
        memory[addr] = fileBytes[addr];
    }
}

#pragma mark - SnapShot

- (void)loadSnapshot
{
    NSData *data = [NSData dataWithContentsOfFile:self.snapshotPath];
    
    const char *fileBytes = (const char*)[data bytes];
    
    // Decode the header
    core->SetRegister(CZ80Core::eREG_I, fileBytes[0]);
    core->SetRegister(CZ80Core::eREG_R, fileBytes[20]);
    core->SetRegister(CZ80Core::eREG_ALT_HL, ((unsigned short *)&fileBytes[1])[0]);
    core->SetRegister(CZ80Core::eREG_ALT_DE, ((unsigned short *)&fileBytes[1])[1]);
    core->SetRegister(CZ80Core::eREG_ALT_BC, ((unsigned short *)&fileBytes[1])[2]);
    core->SetRegister(CZ80Core::eREG_ALT_AF, ((unsigned short *)&fileBytes[1])[3]);
    core->SetRegister(CZ80Core::eREG_HL, ((unsigned short *)&fileBytes[1])[4]);
    core->SetRegister(CZ80Core::eREG_DE, ((unsigned short *)&fileBytes[1])[5]);
    core->SetRegister(CZ80Core::eREG_BC, ((unsigned short *)&fileBytes[1])[6]);
    core->SetRegister(CZ80Core::eREG_IY, ((unsigned short *)&fileBytes[1])[7]);
    core->SetRegister(CZ80Core::eREG_IX, ((unsigned short *)&fileBytes[1])[8]);
    
    core->SetRegister(CZ80Core::eREG_AF, ((unsigned short *)&fileBytes[21])[0]);
    core->SetRegister(CZ80Core::eREG_SP, ((unsigned short *)&fileBytes[21])[1]);
    
    // Border colour
    borderColour = fileBytes[26] & 0x07;
    
    // Set the IM
    core->SetIMMode(fileBytes[25]);
    
    // Do both on bit 2 as a RETN copies IFF2 to IFF1
    core->SetIFF1((fileBytes[19] >> 2) & 1);
    core->SetIFF2((fileBytes[19] >> 2) & 1);
    
    if (data.length == (48 * 1024) + 27)
    {
        int snaAddr = 27;
        for (int i= 16384; i < (48 * 1024) + 16384; i++)
        {
            memory[i] = fileBytes[snaAddr++];
        }
        
        // Set the PC
        unsigned char pc_lsb = memory[core->GetRegister(CZ80Core::eREG_SP)];
        unsigned char pc_msb = memory[core->GetRegister(CZ80Core::eREG_SP) + 1];
        core->SetRegister(CZ80Core::eREG_PC, (pc_msb << 8) | pc_lsb);
        core->SetRegister(CZ80Core::eREG_SP, core->GetRegister(CZ80Core::eREG_SP) + 2);
    }
    
    
    [self resetSound];
    [self resetKeyboardMap];
    [self resetFrame];
}

- (void)loadZ80Snapshot
{
    NSData *data = [NSData dataWithContentsOfFile:self.snapshotPath];
    const char *fileBytes = (const char*)[data bytes];
    
    BOOL version1 = YES;
    
    // Decode the header
    core->SetRegister(CZ80Core::eREG_A, (unsigned char)fileBytes[0]);
    core->SetRegister(CZ80Core::eREG_F, (unsigned char)fileBytes[1]);
    core->SetRegister(CZ80Core::eREG_BC, ((unsigned short *)&fileBytes[2])[0]);
    core->SetRegister(CZ80Core::eREG_HL, ((unsigned short *)&fileBytes[2])[1]);
    
    unsigned short pc = ((unsigned short *)&fileBytes[6])[0];
    
    // Zero means it is a Version 2/3 snapshot
    if (pc == 0)
    {
        version1 = NO;
        pc = ((unsigned short *)&fileBytes[32])[0];
    }
    core->SetRegister(CZ80Core::eREG_PC, pc);
    
    NSLog(@"PC: %#2x", pc);
    
    core->SetRegister(CZ80Core::eREG_SP, ((unsigned short *)&fileBytes[8])[0]);
    core->SetRegister(CZ80Core::eREG_I, (unsigned char)fileBytes[10]);
    core->SetRegister(CZ80Core::eREG_R, (fileBytes[11] & 127) | ((fileBytes[12] & 1) << 7));
    
    // Info byte 12
    unsigned char byte12 = fileBytes[12];
    borderColour = (fileBytes[12] & 14) >> 1;
    BOOL compressed = fileBytes[12] & 32;
    
    NSLog(@"RB7: %i Border: %i SamRom: %i Compressed: %i", byte12 & 1, (byte12 & 14) >> 1, byte12 & 16, byte12 & 32);
    
    core->SetRegister(CZ80Core::eREG_DE, ((unsigned short *)&fileBytes[13])[0]);
    core->SetRegister(CZ80Core::eREG_ALT_BC, ((unsigned short *)&fileBytes[13])[1]);
    core->SetRegister(CZ80Core::eREG_ALT_DE, ((unsigned short *)&fileBytes[13])[2]);
    core->SetRegister(CZ80Core::eREG_ALT_HL, ((unsigned short *)&fileBytes[13])[3]);
    core->SetRegister(CZ80Core::eREG_ALT_A, (unsigned char)fileBytes[21]);
    core->SetRegister(CZ80Core::eREG_ALT_F, (unsigned char)fileBytes[22]);
    core->SetRegister(CZ80Core::eREG_IY, ((unsigned short *)&fileBytes[23])[0]);
    core->SetRegister(CZ80Core::eREG_IX, ((unsigned short *)&fileBytes[23])[1]);
    core->SetIFF1((unsigned char)fileBytes[27] & 1);
    core->SetIFF2((unsigned char)fileBytes[28] & 1);
    core->SetIMMode((unsigned char)fileBytes[29] & 3);
    
    NSLog(@"IFF1: %i IM Mode: %i", (unsigned char)fileBytes[27] & 1, (unsigned char)fileBytes[29] & 3);
    
    // Deal with the extra data available in version 2 & 3 formats
    if (version1)
    {
        NSLog(@"Z80 Snapshot Version 1");
        [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:30 compressed:compressed unpackedLength:49152];
    }
    else
    {
        NSLog(@"Z80 Snapshot Version 2");
        
        int16_t additionHeaderBlockLength = 0;
        additionHeaderBlockLength = ((unsigned short *)&fileBytes[30])[0];
        int offset = 32 + additionHeaderBlockLength;
        
        while (offset < data.length)
        {
            int compressedLength = ((unsigned short *)&fileBytes[offset])[0];
            BOOL isCompressed = YES;
            if (compressedLength == 65535)
            {
                compressedLength = 16384;
                isCompressed = NO;
            }
            
            int pageId = fileBytes[offset + 2];
            
            switch (pageId) {
                case 4:
                    [self extractMemoryBlock:fileBytes memAddr:32768 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                case 5:
                    [self extractMemoryBlock:fileBytes memAddr:49152 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                case 8:
                    [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384];
                    break;
                default:
                    break;
            }
            
            offset += compressedLength + 3;
        }
    }
    
    [self resetSound];
    [self resetKeyboardMap];
    [self resetFrame];
    
}

- (void)extractMemoryBlock:(const char*)fileBytes memAddr:(int)memAddr fileOffset:(int)fileOffset compressed:(BOOL)isCompressed unpackedLength:(int)unpackedLength
{
    int filePtr = fileOffset;
    int memoryPtr = memAddr;
    
    if (!isCompressed)
    {
        while (memoryPtr < unpackedLength + memAddr)
        {
            memory[memoryPtr++] = fileBytes[filePtr++];
        }
    }
    else
    {
        while (memoryPtr < unpackedLength + memAddr)
        {
            unsigned char byte1 = fileBytes[filePtr];
            unsigned char byte2 = fileBytes[filePtr + 1];
            
            if ((unpackedLength + memAddr) - memoryPtr >= 2 &&
                byte1 == 0xed &&
                byte2 == 0xed)
            {
                unsigned char count = fileBytes[filePtr + 2];
                unsigned char value = fileBytes[filePtr + 3];
                for (int i = 0; i < count; i++)
                {
                    memory[memoryPtr++] = value;
                }
                filePtr += 4;
            }
            else
            {
                memory[memoryPtr++] = fileBytes[filePtr++];
            }
        }
    }
}

@end
