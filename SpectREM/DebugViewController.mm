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
            [self.disassemblyArray addObject:[NSString stringWithFormat:@"DB"]];
            pc++;
        }
        else
        {
            [self.disassemblyArray addObject:[NSString stringWithCString:opcode encoding:NSUTF8StringEncoding]];
            pc += length;
        }
    }
    [self.disassemblyTableview reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.disassemblyArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    switch (tableColumn) {
        case 0:
        {
            DebugCellView *view = [tableView makeViewWithIdentifier:@"DisassemblyCellID" owner:nil];
            if (view)
            {
                view.textField.stringValue = [self.disassemblyArray objectAtIndex:row];
            }
            return view;
        }
            break;
        
        case 1:
            
    }
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

@end
