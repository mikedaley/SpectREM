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

- (void)dealloc
{
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.tape.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
        view.progressIndicator.usesThreadedAnimation = YES;
        if (row == self.tape.currentBlockIndex)
        {
            [view.progressIndicator setHidden:NO];
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
            [view.progressIndicator setHidden:YES];
        }
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    self.tape.currentBlockIndex = self.tableView.selectedRow;
    [self.tape stop];
    [self.tape rewind];
    [self reloadTable];
}

- (void)blocksChanged
{
    [self reloadTable];
}

- (void)tapeBytesProcessed:(NSInteger)bytes
{
    TAPBlock *block = [self.tape.tapBlocks objectAtIndex:self.tape.currentBlockIndex];
    TapeCellView *view = [self.tableView viewAtColumn:0 row:self.tape.currentBlockIndex makeIfNecessary:NO];
    double length = block.blockLength;
    double val = (100 / length) * bytes;
    view.progressIndicator.doubleValue = val;
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
    [self.tape stop];
    [self.tape rewind];
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
    [self.tape stop];
    [self.tape rewind];
    [self reloadTable];
}

- (IBAction)rewind:(id)sender
{
    [self.tape stop];
    [self.tape rewind];
    [self reloadTable];
}

- (IBAction)eject:(id)sender {
    [self.tape eject];
    [self reloadTable];
}

- (IBAction)save:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel new];
    savePanel.allowedFileTypes = @[@"TAP"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK)
            {
                [self.tape saveToURL:savePanel.URL];
            }
        }];
    });

}

@end
