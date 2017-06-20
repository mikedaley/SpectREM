//
//  DebugViewController.m
//  SpectREM
//
//  Created by Mike Daley on 06/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "DisassemblyViewController.h"
#import "ZXSpectrum.h"
#import "Z80Core.h"

@interface DisassemblyViewController ()
{
    int _disassembleAddress;
    BOOL _viewVisilbe;
}

@property (strong) NSMutableArray *disassemblyArray;
@property (assign) NSTimer *viewUpdateTimer;

@end

@implementation DisassemblyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.decimalFormat = NO;
    _disassembleAddress = 0;
}

- (void)viewWillAppear
{
    _viewVisilbe = YES;
    [self disassemmbleFromAddress:_disassembleAddress length:65536 - _disassembleAddress];
    [self.disassemblyTableview reloadData];
    
    self.viewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (_viewVisilbe)
        {
//            [self disassemmbleFromAddress:_disassembleAddress length:65536 - _disassembleAddress];
//            [self.disassemblyTableview reloadData];
        }
    }];
}

- (void)viewWillDisappear
{
    _viewVisilbe = NO;
}

#pragma mark - Disassemble

- (void)disassemmbleFromAddress:(int)address length:(int)length
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    
    // Disassemble ROM into an array of strings
    self.disassemblyArray = [NSMutableArray new];
    
    int pc = address;
    while (pc < address + length)
    {
        char opcode[128];
        int length = core->Debug_Disassemble(opcode, 128, pc, !self.decimalFormat, NULL);
        
        if ( length == 0 )
        {
            // Invalid opcode, so because we don't know what it is just show it as a DB statement
            DisassembledInstruction *instruction = [DisassembledInstruction new];
            instruction.address = pc;
            NSMutableString *bytes = [NSMutableString new];
            [bytes appendFormat:@"%02X ", core->Z80CoreDebugMemRead(pc, NULL)];
            instruction.bytes = bytes;
            instruction.instruction = [NSString stringWithFormat:@"DEFB $%@", bytes];
            [self.disassemblyArray addObject:instruction];
            pc++;
        }
        else
        {
            DisassembledInstruction *instruction = [DisassembledInstruction new];
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
            
            // Add a blank row if the last instruction was RET, JP, JR to space things out
            if ([instruction.instruction containsString:@"RET"] ||
                [instruction.instruction containsString:@"JP"] ||
                [instruction.instruction containsString:@"JR"])
            {
                instruction = [DisassembledInstruction new];
                instruction.address = -1;
                instruction.bytes = @"";
                instruction.instruction = @"";
                [self.disassemblyArray addObject:instruction];
            }
        }
    }
}

#pragma mark - Textfield Methods

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    NSTextField *tf = [obj object];
    NSScanner *scanner = [NSScanner scannerWithString:[tf stringValue]];
    int address = 0;
    if (self.decimalFormat)
    {
        int decNumber = 0;
        [scanner scanInt:&decNumber];
        address = decNumber;
    }
    else
    {
        unsigned int hexNumber = 0;
        [scanner scanHexInt:&hexNumber];
        address = hexNumber;
    }
    
    if ([tf.identifier isEqualToString:@"DisassembleAddressField"])
    {
        _disassembleAddress = address;
        [self disassemmbleFromAddress:address length:(65535 - address)];
        [self.disassemblyTableview reloadData];
    }
}

#pragma mark - Table View Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ([tableView.identifier isEqualToString:@"DisassembleTableView"])
    {
        return self.disassemblyArray.count;
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
            CZ80Core *core = (CZ80Core *)[self.machine getCore];
            
            if ([tableColumn.identifier isEqualToString:@"AddressColID"])
            {
                // If the address is -1 then this is a blank row
                if ([(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] address] != -1)
                {
                    int address = [(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] address];

                    if (core->GetRegister(CZ80Core::eREG_PC) == address)
                    {
                        [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
                        [tableView scrollRowToVisible:row];
                    }
                    
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
                view.textField.stringValue = [(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] bytes];
            }
            else if ([tableColumn.identifier isEqualToString:@"DisassemblyColID"])
            {
                view.textField.stringValue = [(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] instruction];
            }
        }
        
        return view;
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
//    [self.disassemblyTableview reloadData];
}

#pragma mark - Update methods

- (void)updateMemoryContents
{
    NSRect visibleRect = self.memoryContentTableview.visibleRect;
    NSRange visibleRows = [self.memoryContentTableview rowsInRect:visibleRect];
    NSIndexSet *visibleCols = [self.memoryContentTableview columnIndexesInRect:visibleRect];
    [self.memoryContentTableview reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRows] columnIndexes:visibleCols];
}

- (void)updateDisassembly
{
    [self disassemmbleFromAddress:_disassembleAddress length:65535 - _disassembleAddress];
    NSRect visibleRect = self.disassemblyTableview.visibleRect;
    NSRange visibleRows = [self.disassemblyTableview rowsInRect:visibleRect];
    NSIndexSet *visibleCols = [self.disassemblyTableview columnIndexesInRect:visibleRect];
    [self.disassemblyTableview reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRows] columnIndexes:visibleCols];
}

- (void)setDecimalFormat:(BOOL)decimalFormat
{
    _decimalFormat = decimalFormat;
//    if (self.decimalFormat)
//    {
//        self.addressTextField.formatter = _decimalFormatter;
//    }
//    else
//    {
//        self.addressTextField.formatter = _hexFormatter;
//    }
    if (self.machine)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self disassemmbleFromAddress:_disassembleAddress length:65536 - _disassembleAddress];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.disassemblyTableview reloadData];
            });
        });
    }
}

@end

#pragma mark - Disassembled Instruction Implementation

@implementation DisassembledInstruction



@end
