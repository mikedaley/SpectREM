//
//  DebugViewController.m
//  SpectREM
//
//  Created by Mike Daley on 06/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "DebugViewController.h"
#import "DebugCellView.h"
#import "ZXSpectrum.h"
#import "Z80Core.h"

@interface DebugViewController ()

@property (strong) NSMutableArray *disassemblyArray;

@property (assign) NSTimer *viewUpdateTimer;

@end

@implementation DebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

- (void)viewWillAppear
{
    CZ80Core *core = (CZ80Core *)[self.machine getCore];
    
    // Disassemble ROM into an array of strings
    self.disassemblyArray = [NSMutableArray new];
    
    int pc = 0;
    while (pc < 16384)
    {
        char opcode[128];
        int length = core->Debug_Disassemble(opcode, 128, pc, NULL);
        
        if ( length == 0 )
        {
            // Invalid opcode - probably want to display as a DB statement
            DisassembledInstruction *instruction = [DisassembledInstruction new];
            instruction.address = pc;
            instruction.instruction = @"NOP";
            [self.disassemblyArray addObject:instruction];
            pc++;
        }
        else
        {
            DisassembledInstruction *instruction = [DisassembledInstruction new];
            instruction.address = pc;
            instruction.instruction = [NSString stringWithCString:opcode encoding:NSUTF8StringEncoding];
            [self.disassemblyArray addObject:instruction];
            pc += length;
        }
    }
    [self.disassemblyTableview reloadData];
    
    self.viewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateCPUDetails];
    }];
    
}

#pragma mark - Table View Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.disassemblyArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *view;
    view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (view)
    {
        if ([tableColumn.identifier isEqualToString:@"AddressColID"])
        {
            int address = [(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] address];
            view.textField.stringValue = [NSString stringWithFormat:@"$%04X", address];
        }
        else if ([tableColumn.identifier isEqualToString:@"DisassemblyColID"])
        {
            view.textField.stringValue = [(DisassembledInstruction *)[self.disassemblyArray objectAtIndex:row] instruction];
        }
    }
    
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

#pragma mark - CPU Details

- (void)updateCPUDetails
{

    CZ80Core *core = (CZ80Core *)[self.machine getCore];

    if (!self.decimalFormat)
    {
        self.pc = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_PC)];
        self.sp = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_SP)];
        self.a = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_A)];
        self.f = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_F)];
        self.b = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_B)];
        self.c = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_C)];
        self.d = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_D)];
        self.e = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_E)];
        self.h = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_H)];
        self.l = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_L)];
        self.i = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_I)];
        self.r = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_R)];
        self.im = [NSString stringWithFormat:@"$%02X", core->GetIMMode()];
        self.ix = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_IX)];
        self.iy = [NSString stringWithFormat:@"$%04X", core->GetRegister(CZ80Core::eREG_IY)];
        
        
        self.aa = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_A)];
        self.ff = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_F)];
        self.bb = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_B)];
        self.cc = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_C)];
        self.dd = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_D)];
        self.ee = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_E)];
        self.hh = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_H)];
        self.ll = [NSString stringWithFormat:@"$%02X", core->GetRegister(CZ80Core::eREG_ALT_L)];
    }
    else
    {
        self.pc = [NSString stringWithFormat:@"%04i", core->GetRegister(CZ80Core::eREG_PC)];
        self.sp = [NSString stringWithFormat:@"%04i", core->GetRegister(CZ80Core::eREG_SP)];
        self.a = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_A)];
        self.f = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_F)];
        self.b = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_B)];
        self.c = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_C)];
        self.d = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_D)];
        self.e = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_E)];
        self.h = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_H)];
        self.l = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_L)];
        self.i = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_I)];
        self.r = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_R)];
        self.im = [NSString stringWithFormat:@"%02i", core->GetIMMode()];
        self.ix = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_IX)];
        self.iy = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_IY)];
        
        
        self.aa = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_A)];
        self.ff = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_F)];
        self.bb = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_B)];
        self.cc = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_C)];
        self.dd = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_D)];
        self.ee = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_E)];
        self.hh = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_H)];
        self.ll = [NSString stringWithFormat:@"%02i", core->GetRegister(CZ80Core::eREG_ALT_L)];
        
    }
    
    self.tStates = [NSString stringWithFormat:@"%05i", core->GetTStates()];
    
    self.fs = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_S) ? @"◉" : @"";
    self.fz = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_Z) ? @"◉" : @"";
    self.f5 = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_5) ? @"◉" : @"";
    self.fh = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_H) ? @"◉" : @"";
    self.f3 = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_3) ? @"◉" : @"";
    self.fpv = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_P) ? @"◉" : @"";
    self.fn = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_N) ? @"◉" : @"";
    self.fc = (core->GetRegister(CZ80Core::eREG_F) & core->FLAG_C) ? @"◉" : @"";
}

@end

#pragma mark - Disassembled Instruction Implementation

@implementation DisassembledInstruction



@end
