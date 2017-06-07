//
//  Snapshot.m
//  SpectREM
//
//  Created by Mike Daley on 30/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "Snapshot.h"
#import "Z80Core.h"

@implementation Snapshot

#pragma mark - Snapshot info

+ (int)machineNeededForZ80SnapshotWithPath:(NSString *)snapshotPath
{
    NSData *data = [NSData dataWithContentsOfFile:snapshotPath];
    const char *fileBytes = (const char*)[data bytes];
 
    // Decode the header
    unsigned short headerLength = ((unsigned short *)&fileBytes[30])[0];
    int version;
    unsigned char hardwareType;
    unsigned short pc;
    
    switch (headerLength) {
        case 23:
            version = 2;
            pc = ((unsigned short *)&fileBytes[32])[0];
            break;
        case 54:
        case 55:
            version = 3;
            pc = ((unsigned short *)&fileBytes[32])[0];
            break;
        default:
            version = 1;
            pc = ((unsigned short *)&fileBytes[6])[0];
            break;
    }
    
    if (pc == 0)
    {
        version = 2;
        pc = ((unsigned short *)&fileBytes[32])[0];
    }
    
    if (version == 1)
    {
        return 0;
    }
    
    if (version == 2)
    {
        hardwareType = ((unsigned char *)&fileBytes[34])[0];
        if (hardwareType == 0 || hardwareType == 1)
        {
            return 0;
        }
        
        if (hardwareType == 3 || hardwareType == 4)
        {
            return 1;
        }
    }
    
    if (version == 3)
    {
        hardwareType = ((unsigned char *)&fileBytes[34])[0];
        if (hardwareType == 0 || hardwareType == 1 || hardwareType == 3)
        {
            return 0;
        }
        
        if (hardwareType == 4 || hardwareType == 5 || hardwareType == 6)
        {
            return 1;
        }
    }
    
    return -1;
}

#pragma mark - SNA Snapshot

+ (unsigned char *)createSnapshotFromMachine:(ZXSpectrum *)machine
{
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    // We don't want the machine running while the snapshot is being created
    [machine setPaused:YES];
    
    unsigned char *data;
    data = (unsigned char*)calloc(49152 + 27, sizeof(unsigned char));
    
    data[0] = core->GetRegister(CZ80Core::eREG_I);
    data[1] = core->GetRegister(CZ80Core::eREG_ALT_HL) & 0xff;
    data[2] = core->GetRegister(CZ80Core::eREG_ALT_HL) >> 8;
    
    data[3] = core->GetRegister(CZ80Core::eREG_ALT_DE) & 0xff;
    data[4] = core->GetRegister(CZ80Core::eREG_ALT_DE) >> 8;

    data[5] = core->GetRegister(CZ80Core::eREG_ALT_BC) & 0xff;
    data[6] = core->GetRegister(CZ80Core::eREG_ALT_BC) >> 8;
    
    data[7] = core->GetRegister(CZ80Core::eREG_ALT_AF) & 0xff;
    data[8] = core->GetRegister(CZ80Core::eREG_ALT_AF) >> 8;
    
    data[9] = core->GetRegister(CZ80Core::eREG_HL) & 0xff;
    data[10] = core->GetRegister(CZ80Core::eREG_HL) >> 8;
    
    data[11] = core->GetRegister(CZ80Core::eREG_DE) & 0xff;
    data[12] = core->GetRegister(CZ80Core::eREG_DE) >> 8;
    
    data[13] = core->GetRegister(CZ80Core::eREG_BC) & 0xff;
    data[14] = core->GetRegister(CZ80Core::eREG_BC) >> 8;
    
    data[15] = core->GetRegister(CZ80Core::eREG_IY) & 0xff;
    data[16] = core->GetRegister(CZ80Core::eREG_IY) >> 8;
    
    data[17] = core->GetRegister(CZ80Core::eREG_IX) & 0xff;
    data[18] = core->GetRegister(CZ80Core::eREG_IX) >> 8;
    
    data[19] = (core->GetIFF1() & 1) << 2;
    data[20] = core->GetRegister(CZ80Core::eREG_R);
    
    data[21] = core->GetRegister(CZ80Core::eREG_AF) & 0xff;
    data[22] = core->GetRegister(CZ80Core::eREG_AF) >> 8;
    
    unsigned short pc = core->GetRegister(CZ80Core::eREG_PC);
    unsigned short sp = core->GetRegister(CZ80Core::eREG_SP) - 2;
    
    data[23] = sp & 0xff;
    data[24] = sp >> 8;
    
    data[25] = core->GetIMMode();
    data[26] = machine->borderColor;
    
    int dataIndex = 27;
    for (unsigned int addr = 16384; addr < 16384 + (48 * 1024); addr++)
    {
        data[dataIndex++] = core->Z80CoreDebugMemRead(addr, NULL);
    }
    
    // Update the SP location in the snapshot buffer with the new SP, as PC has been added to the stack
    // as part of creating the snapshot
    data[sp - 16384 + 27] = pc & 0xff;
    data[sp - 16384 + 27 + 1] = pc >> 8;
    
//    NSData *output = [NSData dataWithBytes:data length:49152 + 27];
//    [output writeToFile:@"/Users/mikeda/Desktop/test.sna" atomically:NO];
    
    [machine setPaused:NO];
    
//    NSLog(@"%@", [NSData dataWithBytes:data length:49152 + 27]);
    
    return data;
}


+ (int)loadSnapshotWithPath:(NSString *)snapshotPath IntoMachine:(ZXSpectrum *)machine
{
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    NSData *data = [NSData dataWithContentsOfFile:snapshotPath];
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
    machine->borderColor = fileBytes[26] & 0x07;
    
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
            machine->memory[i] = fileBytes[snaAddr++];
        }
        
        // Set the PC
        unsigned char pc_lsb = machine->memory[core->GetRegister(CZ80Core::eREG_SP)];
        unsigned char pc_msb = machine->memory[core->GetRegister(CZ80Core::eREG_SP) + 1];
        core->SetRegister(CZ80Core::eREG_PC, (pc_msb << 8) | pc_lsb);
        core->SetRegister(CZ80Core::eREG_SP, core->GetRegister(CZ80Core::eREG_SP) + 2);
        
    }
    else if (data.length == ((128 * 1024) + 27 + 4) || data.length == ((144 * 1024) + 27 + 4))
    {
        int snaAddr = (3 * 16384) + 27;
        
        machine->disablePaging = ((fileBytes[snaAddr + 2] & 0x20) == 0x20) ? YES : NO;
        machine->currentROMPage = ((fileBytes[snaAddr + 2] & 0x10) == 0x10) ? 1 : 0;
        machine->displayPage = ((fileBytes[snaAddr + 2] & 0x08) == 0x08) ? 7 : 5;
        machine->currentRAMPage = (fileBytes[snaAddr + 2] & 0x07);
        
        core->SetRegister(CZ80Core::eREG_PC, (fileBytes[snaAddr + 1] << 8) | fileBytes[snaAddr]);
        
        snaAddr = 27;
        
        int memoryAddr = 5 * 16384;
        for (int i = 0; i < 16384; i++)
        {
            machine->memory[memoryAddr++] = fileBytes[snaAddr++];
        }
        
        memoryAddr = 2 * 16384;
        for (int i = 0; i < 16384; i++)
        {
            machine->memory[memoryAddr++] = fileBytes[snaAddr++];
        }
        
        memoryAddr = machine->currentRAMPage * 16384;
        for (int i = 0; i < 16384; i++)
        {
            machine->memory[memoryAddr++] = fileBytes[snaAddr++];
        }
        
        snaAddr += 4;
        
        for (int p = 0; p < 8; p++)
        {
            if (p != 5 && p != 2 && p != machine->currentRAMPage)
            {
                memoryAddr = p * 16384;
                for (int i = 0; i < 16384; i++)
                {
                    machine->memory[memoryAddr++] = fileBytes[snaAddr++];
                }
            }
        }
    }
    
    return 0;
}

#pragma mark - Z80 Snaphot

+ (int)loadZ80SnapshotWithPath:(NSString *)snapshotpath intoMachine:(ZXSpectrum *)machine
{
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
    NSData *data = [NSData dataWithContentsOfFile:snapshotpath];
    const char *fileBytes = (const char*)[data bytes];
    
    // Decode the header
    unsigned short headerLength = ((unsigned short *)&fileBytes[30])[0];
    int version;
    unsigned char hardwareType;
    unsigned short pc;
    
    switch (headerLength) {
        case 23:
            version = 2;
            pc = ((unsigned short *)&fileBytes[32])[0];
            break;
        case 54:
        case 55:
            version = 3;
            pc = ((unsigned short *)&fileBytes[32])[0];
            break;
        default:
            version = 1;
            pc = ((unsigned short *)&fileBytes[6])[0];
            break;
    }
    
    if (pc == 0)
    {
        version = 2;
        pc = ((unsigned short *)&fileBytes[32])[0];
    }
    
    NSLog(@"-------------------------------------------------------");
    NSLog(@"Z80 Snapshot Version %i", version);

    core->SetRegister(CZ80Core::eREG_A, (unsigned char)fileBytes[0]);
    core->SetRegister(CZ80Core::eREG_F, (unsigned char)fileBytes[1]);
    core->SetRegister(CZ80Core::eREG_BC, ((unsigned short *)&fileBytes[2])[0]);
    core->SetRegister(CZ80Core::eREG_HL, ((unsigned short *)&fileBytes[2])[1]);
    core->SetRegister(CZ80Core::eREG_PC, pc);
    core->SetRegister(CZ80Core::eREG_SP, ((unsigned short *)&fileBytes[8])[0]);
    core->SetRegister(CZ80Core::eREG_I, (unsigned char)fileBytes[10]);
    core->SetRegister(CZ80Core::eREG_R, (fileBytes[11] & 127) | ((fileBytes[12] & 1) << 7));
    
    // Decode byte 12
    //    Bit 0  : Bit 7 of the R-register
    //    Bit 1-3: Border colour
    //    Bit 4  : 1=Basic SamRom switched in
    //    Bit 5  : 1=Block of data is compressed
    //    Bit 6-7: No meaning
    unsigned char byte12 = fileBytes[12];
    
    // For campatibility reasons if byte 12 = 255 then is should be assumed to = 1
    byte12 = (byte12 == 255) ? byte12 : 1;
    
    machine->borderColor = (fileBytes[12] & 14) >> 1;
    BOOL compressed = fileBytes[12] & 32;
    
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
    
    NSLog(@"RB7: %i Border: %i SamRom: %i Compressed: %i", byte12 & 1, (byte12 & 14) >> 1, byte12 & 16, byte12 & 32);
    NSLog(@"IFF1: %i IM Mode: %i", (unsigned char)fileBytes[27] & 1, (unsigned char)fileBytes[29] & 3);
    
    // Based on the version number of the snapshot, decode the memory contents
    switch (version) {
        case 1:
            NSLog(@"Hardware Type: 48k");
            [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:30 compressed:compressed unpackedLength:49152 intoMachine:machine];
            break;
            
        case 2:
        case 3:
            hardwareType = ((unsigned char *)&fileBytes[34])[0];
            NSLog(@"Hardware Type: %@", [self hardwareStringForVersion:version hardwareType:hardwareType]);
            
            int16_t additionHeaderBlockLength = 0;
            additionHeaderBlockLength = ((unsigned short *)&fileBytes[30])[0];
            int offset = 32 + additionHeaderBlockLength;
            
            if ( (version == 2 && (hardwareType == 3 || hardwareType == 4)) || (version == 3 && (hardwareType == 4 || hardwareType == 5 || hardwareType == 6)) )
            {
                // Decode byte 35 so that port 0x7ffd can be set on the 128k
                unsigned char data = ((unsigned char *)&fileBytes[35])[0];
                machine->disablePaging = ((data & 0x20) == 0x20) ? YES : NO;
                machine->currentROMPage = ((data & 0x10) == 0x10) ? 1 : 0;
                machine->displayPage = ((data & 0x08) == 0x08) ? 7 : 5;
                machine->currentRAMPage = (data & 0x07);
            }
            else
            {
                machine->disablePaging = YES;
                machine->currentROMPage = 0;
                machine->currentRAMPage = 0;
                machine->displayPage = 1;
            }
            
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
                
                if (version == 1 || ((version == 2 || version == 3) && (hardwareType == 0 || hardwareType == 1)))
                {
                    // 48k
                    switch (pageId) {
                        case 4:
                            [self extractMemoryBlock:fileBytes memAddr:32768 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 5:
                            [self extractMemoryBlock:fileBytes memAddr:49152 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 8:
                            [self extractMemoryBlock:fileBytes memAddr:16384 fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    // 128k
                    switch (pageId) {
                        case 3:
                            [self extractMemoryBlock:fileBytes memAddr:(0 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 4:
                            [self extractMemoryBlock:fileBytes memAddr:(1 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 5:
                            [self extractMemoryBlock:fileBytes memAddr:(2 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 6:
                            [self extractMemoryBlock:fileBytes memAddr:(3 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 7:
                            [self extractMemoryBlock:fileBytes memAddr:(4 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 8:
                            [self extractMemoryBlock:fileBytes memAddr:(5 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 9:
                            [self extractMemoryBlock:fileBytes memAddr:(6 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        case 10:
                            [self extractMemoryBlock:fileBytes memAddr:(7 * 16384) fileOffset:offset + 3 compressed:isCompressed unpackedLength:16384 intoMachine:machine];
                            break;
                        default:
                            break;
                    }
                }
                
                offset += compressedLength + 3;
            }
            break;
    }
    
    return 0;
}

#pragma mark - Extract Memory From Snapshot

+ (void)extractMemoryBlock:(const char*)fileBytes memAddr:(int)memAddr fileOffset:(int)fileOffset compressed:(BOOL)isCompressed unpackedLength:(int)unpackedLength intoMachine:(ZXSpectrum *)machine
{
    int filePtr = fileOffset;
    int memoryPtr = memAddr;
    
    if (!isCompressed)
    {
        while (memoryPtr < unpackedLength + memAddr)
        {
            machine->memory[memoryPtr++] = fileBytes[filePtr++];
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
                    machine->memory[memoryPtr++] = value;
                }
                filePtr += 4;
            }
            else
            {
                machine->memory[memoryPtr++] = fileBytes[filePtr++];
            }
        }
    }
}

#pragma mark - Snapshot Hardware Description

+ (NSString *)hardwareStringForVersion:(int)version hardwareType:(int)hardwareType
{
    NSString *hardware = @"Unknown";
    if (version == 2)
    {
        switch (hardwareType) {
            case 0:
                hardware = @"48k";
                break;
            case 1:
                hardware = @"48k + Interface 1";
                break;
            case 2:
                hardware = @"SamRam";
                break;
            case 3:
                hardware = @"128k";
                break;
            case 4:
                hardware = @"128k + Interface 1";
                break;
            case 5:
            case 6:
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (hardwareType) {
            case 0:
                hardware = @"48k";
                break;
            case 1:
                hardware = @"48k + Interface 1";
                break;
            case 2:
                hardware = @"SamRam";
                break;
            case 3:
                hardware = @"48k + M.G.T";
                break;
            case 4:
                hardware = @"128k";
                break;
            case 5:
                hardware = @"128k + Interface 1";
                break;
            case 6:
                hardware = @"128k + M.G.T";
                break;
                
            default:
                break;
        }
    }
    return hardware;
}

@end
