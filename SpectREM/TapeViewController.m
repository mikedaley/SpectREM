//
//  TapeViewController.m
//  SpectREM
//
//  Created by Mike Daley on 01/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "TapeViewController.h"
#import "TapeCellView.h"
#import "ZXTape.h"

@interface TapeViewController ()

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation TapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blocksChanged:) name:cTapeBlocksChanged object:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tape.tapBlocks.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TapeCellView *view = [tableView makeViewWithIdentifier:@"BlockTypeCellID" owner:nil];
    if (view)
    {
        view.textField.stringValue = [(TAPBlock *)[self.tape.tapBlocks objectAtIndex:row] blockType];
        if (row == self.tape.currentBlockIndex)
        {
            [view.progressIndicator.animator setHidden:NO];
            if (self.tape.playing)
            {
                view.imageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
            }
            else
            {
                view.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
            }
        }
        else
        {
            view.imageView.image = nil;
            [view.progressIndicator.animator setHidden:YES];
        }
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    self.tape.currentBlockIndex = self.tableView.selectedRow;
    [self reloadTable];
}

- (void)blocksChanged:(NSNotification *)notification
{
    [self reloadTable];
}

- (void)reloadTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Button Actions

- (IBAction)previous:(id)sender {
    self.tape.currentBlockIndex = (self.tape.currentBlockIndex - 1 >= 0) ? self.tape.currentBlockIndex - 1 : 0 ;
    [self.tableView reloadData];
}

- (IBAction)play:(id)sender {
    [self.tape play];
}

- (IBAction)stop:(id)sender {
    [self.tape stop];
}

- (IBAction)next:(id)sender {
    self.tape.currentBlockIndex = (self.tape.currentBlockIndex + 1 < self.tape.tapBlocks.count) ? self.tape.currentBlockIndex + 1 : self.tape.tapBlocks.count - 1;
    [self reloadTable];
}

- (IBAction)eject:(id)sender {
    [self.tape eject];
    [self reloadTable];
}

@end
