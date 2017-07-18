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
@property (strong) NSMutableArray *stackArray;
@property (assign) unsigned short byteWidth;

@end

@implementation DebugViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ([super initWithCoder:coder])
    {
        self.byteWidth = 36;
        return self;
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.decimalFormat = NO;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:NULL queue:NULL usingBlock:^(NSNotification * _Nonnull note) {
        [self updateMemoryTableByteWidth];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"UPDATE_DISASSEMBLE_TABLE" object:NULL queue:NULL usingBlock:^(NSNotification * _Nonnull note) {
        [self updateViewDetails];
    }];

}

- (void)viewWillDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_DISASSEMBLE_TABLE" object:NULL];
    [self.machine setPaused:NO];
}

- (void)viewWillAppear
{
    [self.machine setPaused:YES];
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    self.disassembleAddress = core->GetRegister(CZ80Core::eREG_PC);
    [self disassemmbleFromAddress:self.disassembleAddress length:65536 - self.disassembleAddress];
    [self.disassemblyTableview reloadData];
    [self.memoryTableView reloadData];
    [self updateCPUDetails];
    [self updateStackTable];
}

#pragma mark - Debug Controls

- (void)step
{
    [self.machine stepInstruction];
    self.displayImage = [[NSImage alloc] initWithData:self.imageData];
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
    
    if ([tableView.identifier isEqualToString:@"StackTable"])
    {
        return self.stackArray.count;
    }
    
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];

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
    
    if ([tableView.identifier isEqualToString:@"StackTable"])
    {
        NSTableCellView *view;
        view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        if (view)
        {
            view.textField.stringValue = [NSString stringWithFormat:@"%04X", [[self.stackArray objectAtIndex:row] unsignedShortValue]];
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
    [self updateCPUDetails];
    [self updateDisassemblyTable];
    [self updateMemoryTable];
    [self updateStackTable];
}

- (void)updateCPUDetails
{
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
}

- (void)updateDisassemblyTable
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];

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
    
//    NSRect visibleRect = self.disassemblyTableview.visibleRect;
//    NSIndexSet *visibleCols = [self.disassemblyTableview columnIndexesInRect:visibleRect];
//    [self.disassemblyTableview reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRowIndexes] columnIndexes:visibleCols];
    [self.disassemblyTableview reloadData];
    [self.disassemblyTableview deselectAll:NULL];
    [self.disassemblyTableview scrollRowToVisible:row];
}

- (void)updateMemoryTable
{
//    NSRect visibleRect = self.memoryTableView.visibleRect;
//    NSRange visibleRows = [self.memoryTableView rowsInRect:visibleRect];
//    NSIndexSet *visibleCols = [self.memoryTableView columnIndexesInRect:visibleRect];
//    [self.memoryTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRows] columnIndexes:visibleCols];
    [self.memoryTableView reloadData];
}

- (void)updateStackTable
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    
    self.stackArray = [NSMutableArray new];
    
    unsigned short sp = core->GetRegister(CZ80Core::eREG_SP);
    
    for (unsigned short i = sp; i <= 0xffff; i += 2)
    {
        if (i == 0)
        {
            break;
        }
        unsigned short address = core->Z80CoreDebugMemRead(i + 1, NULL) << 8;
        address |= core->Z80CoreDebugMemRead(i, NULL);
        [self.stackArray addObject:@(address)];
    }
    
    [self.stackTable reloadData];
}

- (void)updateMemoryTableByteWidth
{
    for (NSTableColumn *col in self.memoryTableView.tableColumns)
    {
        if ([col.identifier isEqualToString:@"MemoryBytesColID"])
        {
            self.byteWidth = col.width / 18;
            NSLog(@"%i", self.byteWidth);
        }
    }
    [self.memoryTableView reloadData];
}

@end

#pragma mark - Disassembled Instruction Implementation

@implementation DisassembledOpcode



@end
