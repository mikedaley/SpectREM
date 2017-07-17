//
//  DebugViewController.m
//  SpectREM
//
//  Created by Mike Daley on 17/07/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "DebugViewController.h"
#import "ZXSpectrum.h"
#import "Z80Core.h"

@interface DebugViewController ()

@property (assign) unsigned short disassembleAddress;
@property (strong) NSMutableArray *disassemblyArray;
@property (assign) unsigned short byteWidth;

@end

@implementation DebugViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ([super initWithCoder:coder])
    {
        self.byteWidth = 32;
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.decimalFormat = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UPDATE_DISASSEMBLE_TABLE" object:NULL queue:NULL usingBlock:^(NSNotification * _Nonnull note) {
        [self updateViewDetails];
    }];

}

- (void)viewWillAppear
{
    [self.machine setPaused:YES];
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    self.disassembleAddress = core->GetRegister(CZ80Core::eREG_PC);
    [self disassemmbleFromAddress:self.disassembleAddress length:65536 - self.disassembleAddress];
    [self updateViewDetails];
}

#pragma mark - Table View Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ([tableView.identifier isEqualToString:@"DisassembleTableView"])
    {
        return self.disassemblyArray.count;
    }
    
    if ([tableView.identifier isEqualToString:@"MemoryTableView"])
    {
        return (65535 / self.byteWidth) + 1;
    }
    
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
   
    if ([tableView.identifier isEqualToString:@"DisassembleTableView"])
    {
        NSTableCellView *view;
        view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        if (view)
        {
            if ([tableColumn.identifier isEqualToString:@"AddressColID"])
            {
                // If the address is -1 then this is a blank row
                if ([(DisassembledOpcode *)[self.disassemblyArray objectAtIndex:row] address] != -1)
                {
                    int address = [(DisassembledOpcode *)[self.disassemblyArray objectAtIndex:row] address];
                    
                    if (self.decimalFormat)
                    {
                        view.textField.stringValue = [NSString stringWithFormat:@"%05i", address];
                    }
                    else
                    {
                        view.textField.stringValue = [NSString stringWithFormat:@"$%04X", address];
                    }
                }
                else
                {
                    view.textField.stringValue = @"";
                }
            }
            else if ([tableColumn.identifier isEqualToString:@"BytesColID"])
            {
                view.textField.stringValue = [(DisassembledOpcode *)[self.disassemblyArray objectAtIndex:row] bytes];
            }
            else if ([tableColumn.identifier isEqualToString:@"DisassemblyColID"])
            {
                view.textField.stringValue = [(DisassembledOpcode *)[self.disassemblyArray objectAtIndex:row] instruction];
            }
        }
        
        return view;
    }
    
    if ([tableView.identifier isEqualToString:@"MemoryTableView"])
    {
        NSTableCellView *view;
        view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        if (view)
        {
            if ([tableColumn.identifier isEqualToString:@"MemoryAddressColID"])
            {
                unsigned short address = row * self.byteWidth;
                
                if (self.decimalFormat)
                {
                    view.textField.stringValue = [NSString stringWithFormat:@"%05i", address];
                }
                else
                {
                    view.textField.stringValue = [NSString stringWithFormat:@"$%04X", address];
                }
            }
            else if ([tableColumn.identifier isEqualToString:@"MemoryBytesColID"])
            {
                CZ80Core *core = (CZ80Core *)[self.machine getCore];
                
                NSMutableString *content = [NSMutableString new];
                for (unsigned int i = 0; i < self.byteWidth; i++)
                {
                    unsigned int address = ((unsigned short)row * self.byteWidth) + i;
                    [content appendString:[NSString stringWithFormat:@"%02X ",
                                           (unsigned int)core->Z80CoreDebugMemRead(address, NULL)]];
                }
                view.textField.stringValue = content;
            }
            else if ([tableColumn.identifier isEqualToString:@"MemoryASCIIColID"])
            {
                NSMutableString *content = [NSMutableString new];
                for (int i = 0; i < self.byteWidth; i++)
                {
                    unsigned char c = self.machine->memory[(row * self.byteWidth) + i];
                    if ((c >= 0 && c < 32) || c > 126)
                    {
                        [content appendString:@"."];
                    }
                    else
                    {
                        NSString *character = [NSString stringWithFormat:@"%c", c];
                        [content appendString:character];
                    }
                }
                view.textField.stringValue = content;
            }
        }
        
        return view;
        
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    
    if ([tableView.identifier isEqualToString:@"DisassembleTableView"])
    {
        if (core->GetRegister(CZ80Core::eREG_PC) == [(DisassembledOpcode *)[self.disassemblyArray objectAtIndex:row] address])
        {
            rowView.backgroundColor = [NSColor greenColor];
        }
        else
        {
            rowView.backgroundColor = [NSColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
}

#pragma mark - Disassemble

- (void)disassemmbleFromAddress:(int)address length:(int)length
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    
    self.disassemblyArray = [NSMutableArray new];
    
    int pc = address;
    while (pc < address + length)
    {
        char opcode[128];
        int length = core->Debug_Disassemble(opcode, 128, pc, !self.decimalFormat, NULL);
        
        if ( length == 0 )
        {
            // Invalid opcode, so because we don't know what it is just show it as a DB statement
            DisassembledOpcode *instruction = [DisassembledOpcode new];
            instruction.address = pc;
            NSMutableString *bytes = [NSMutableString new];
            [bytes appendFormat:@"%02X ", core->Z80CoreDebugMemRead(pc, NULL)];
            instruction.bytes = bytes;
            instruction.instruction = [NSString stringWithFormat:@"DB $%@", bytes];
            [self.disassemblyArray addObject:instruction];
            pc++;
        }
        else
        {
            DisassembledOpcode *instruction = [DisassembledOpcode new];
            instruction.address = pc;
            
            NSMutableString *bytes = [NSMutableString new];
            for (int i = 0; i <= length - 1; i++)
            {
                [bytes appendFormat:@"%02X ", core->Z80CoreDebugMemRead(pc + i, NULL)];
            }
            
            instruction.bytes = bytes;
            instruction.instruction = [NSString stringWithCString:opcode encoding:NSUTF8StringEncoding];
            [self.disassemblyArray addObject:instruction];
            pc += length;
        }
    }
}

#pragma mark - View Updates

- (void)updateViewDetails
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CZ80Core *core = (CZ80Core *)[self.machine getCore];
        
        if (!self.decimalFormat)
        {
            self.pc = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_PC)];
            self.sp = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_SP)];
            
            self.af = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_AF)];
            self.bc = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_BC)];
            self.de = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_DE)];
            self.hl = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_HL)];
            
            self.a_af = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_ALT_AF)];
            self.a_bc = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_ALT_BC)];
            self.a_de = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_ALT_DE)];
            self.a_hl = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_ALT_HL)];
            
            self.i = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_I)];
            self.r = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_R)];
            
            self.ix = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_IX)];
            self.iy = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_IY)];
        }
        else
        {
            self.pc = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_PC)];
            self.sp = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_SP)];
            
            self.af = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_AF)];
            self.bc = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_BC)];
            self.de = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_DE)];
            self.hl = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_HL)];
            
            self.a_af = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_ALT_AF)];
            self.a_bc = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_ALT_BC)];
            self.a_de = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_ALT_DE)];
            self.a_hl = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_ALT_HL)];
            
            self.i = [NSString stringWithFormat:@"$%02i", core->GetRegister(CZ80Core::eREG_I)];
            self.r = [NSString stringWithFormat:@"$%02i", core->GetRegister(CZ80Core::eREG_R)];
            
            self.ix = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_IX)];
            self.iy = [NSString stringWithFormat:@"$%04i", core->GetRegister(CZ80Core::eREG_IY)];
        }
        
        self.currentRom = [NSString stringWithFormat:@"%02i", self.machine->currentROMPage];
        self.displayPage = [NSString stringWithFormat:@"%02i", self.machine->displayPage];
        self.ramPage = [NSString stringWithFormat:@"%02i", self.machine->currentRAMPage];
        self.iff1 = [NSString stringWithFormat:@"%02i", core->GetIFF1()];
        self.im = [NSString stringWithFormat:@"%02i", core->GetIMMode()];
        
        self.tStates = [NSString stringWithFormat:@"%04i", core->GetTStates()];
        
        self.fs = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_S) ? @"1" : @"0";
        self.fz = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_Z) ? @"1" : @"0";
        self.f5 = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_5) ? @"1" : @"0";
        self.fh = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_H) ? @"1" : @"0";
        self.f3 = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_3) ? @"1" : @"0";
        self.fpv = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_P) ? @"1" : @"0";
        self.fn = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_N) ? @"1" : @"0";
        self.fc = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_C) ? @"1" : @"0";
        
        BOOL pcfound = NO;
        NSUInteger row = 0;
        
        NSRange visibleRowIndexes = [self.disassemblyTableview rowsInRect:self.disassemblyTableview.visibleRect];
        
        for (NSUInteger i = visibleRowIndexes.location; i < visibleRowIndexes.location + visibleRowIndexes.length - 1; i++)
        {
            DisassembledOpcode *instruction = [self.disassemblyArray objectAtIndex:i];
            if (instruction.address == core->GetRegister(CZ80Core::eREG_PC))
            {
                pcfound = YES;
                row = i;
                break;
            }
        }
        
        if (!pcfound)
        {
            self.disassembleAddress = core->GetRegister(CZ80Core::eREG_PC);
            [self disassemmbleFromAddress:self.disassembleAddress length:65536 - self.disassembleAddress];
        }
        
        [self.disassemblyTableview reloadData];
        [self.disassemblyTableview deselectAll:NULL];
        [self.disassemblyTableview scrollRowToVisible:row];
        
        [self.memoryTableView reloadData];
        
    });
}
@end

#pragma mark - Disassembled Instruction Implementation

@implementation DisassembledOpcode



@end
