//
//  MemoryViewController.m
//  SpectREM
//
//  Created by Mike Daley on 25/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "MemoryViewController.h"
#import "ZXSpectrum.h"

@interface MemoryViewController ()
{

}

@property (strong) NSTimer *viewUpdateTimer;

@end

@implementation MemoryViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.byteWidth = 16;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
    [self.memoryTableView reloadData];
    self.viewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updateMemoryContents];
    }];
}

- (void)viewWillDisappear
{
    [self.viewUpdateTimer invalidate];
    self.viewUpdateTimer = nil;
}

#pragma mark - Table View Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ([tableView.identifier isEqualToString:@"MemoryTableView"])
    {
        return (65535 / self.byteWidth) + 1;
    }
    
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    if ([tableView.identifier isEqualToString:@"MemoryTableView"])
    {
        NSTableCellView *view;
        view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        if (view)
        {
            if ([tableColumn.identifier isEqualToString:@"MemoryAddressColID"])
            {
                int address = (int)row * self.byteWidth;
                
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
                for (int i = 0; i < self.byteWidth; i++)
                {
                    [content appendString:[NSString stringWithFormat:@"%02X  ", self.machine->memory[(row * self.byteWidth) + i]]];
                }
                view.textField.stringValue = content;
            }
            else if ([tableColumn.identifier isEqualToString:@"MemoryASCIIColID"])
            {
                NSMutableString *content = [NSMutableString new];
                for (int i = 0; i < self.byteWidth; i++)
                {
                    char c = self.machine->memory[(row * self.byteWidth) + i];
                    [content appendString:[NSString stringWithFormat:@"%c", c]];
                }
                view.textField.stringValue = content;
            }
        }
        
        return view;
        
    }
    
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
//    if (row == 0 || row == 4000 / self.byteWidth)
//    {
//        return YES;
//    }
    
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}

#pragma mark - Updates

- (void)updateMemoryContents
{
    NSRect visibleRect = self.memoryTableView.visibleRect;
    NSRange visibleRows = [self.memoryTableView rowsInRect:visibleRect];
    NSIndexSet *visibleCols = [self.memoryTableView columnIndexesInRect:visibleRect];
    [self.memoryTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:visibleRows] columnIndexes:visibleCols];
}

#pragma mark - Getters/Setters

- (void)setByteWidth:(int)byteWidth
{
    _byteWidth = byteWidth;
    [self.memoryTableView reloadData];
}

@end
