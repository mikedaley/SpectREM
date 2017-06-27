//
//  RomSelectionViewController.m
//  SpectREM
//
//  Created by Michael Daley on 18/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "RomSelectionViewController.h"
#import "ConfigViewController.h"
#import "RomSelectionView.h"

typedef NS_ENUM(NSUInteger, SZXMachineType)
{
    e48kRom = 0,
    e128kRom_0,
    e128kRom_1
};

static NSUInteger const cROM_SIZE_16K = 16384;

#pragma mark - Interface

@interface RomSelectionViewController ()

@property (strong) NSUserDefaults *preferences;
@property (weak) IBOutlet NSImageView *rom48;
@property (weak) IBOutlet NSImageView *rom1280;
@property (weak) IBOutlet NSImageView *rom1281;

@end

#pragma mark - Implementation 

@implementation RomSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferences = [NSUserDefaults standardUserDefaults];
    [(RomSelectionView *)self.rom48 setDelegate:self];
    [(RomSelectionView *)self.rom1280 setDelegate:self];
    [(RomSelectionView *)self.rom1281 setDelegate:self];
    
}

#pragma mark - Actions

- (IBAction)resetRom:(id)sender
{
    NSInteger tag = [(NSControl *)sender tag];
    
    if (tag == e48kRom)
    {
        [self reset48kRom];
    }
    else if (tag == e128kRom_0)
    {
        [self reset128kRom0];
    }
    else if (tag == e128kRom_1)
    {
        [self reset128kRom1];
    }
}

- (IBAction)setRom:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"ROM"];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            if (![self isFileAtUrl:openPanel.URL size:cROM_SIZE_16K])
            {
                [self displayInvalidROM];
                return;
            }
            
            NSUInteger machineType = [(NSControl  *)sender tag];
            [self setRomWithURL:openPanel.URL forMachineType:machineType];
        }
    }];
}

#pragma mark - Methods

- (void)setRomWithURL:(NSURL *)url forMachineType:(NSUInteger)machineType
{
    if (machineType == e48kRom)
    {
        [self.preferences setURL:url forKey:cRom48Path];
        [self.preferences setObject:[url lastPathComponent] forKey:cRom48Name];
    }
    else if (machineType == e128kRom_0)
    {
        [self.preferences setURL:url forKey:cRom1280Path];
        [self.preferences setObject:[url lastPathComponent] forKey:cRom1280Name];
    }
    else if (machineType == e128kRom_1)
    {
        [self.preferences setURL:url forKey:cRom1281Path];
        [self.preferences setObject:[url lastPathComponent] forKey:cRom1281Name];
    }
    
    [self.preferences synchronize];
}

- (void)reset48kRom
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"48" withExtension:@"rom"];
    [self.preferences setURL:url forKey:cRom48Path];
    [self.preferences setObject:@"48.rom" forKey:cRom48Name];
    [self.preferences synchronize];
}

- (void)reset128kRom0
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"128-0" withExtension:@"rom"];
    [self.preferences setURL:url forKey:cRom1280Path];
    [self.preferences setObject:@"128-0.rom" forKey:cRom1280Name];
    [self.preferences synchronize];
}

- (void)reset128kRom1
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"128-1" withExtension:@"rom"];
    [self.preferences setURL:url forKey:cRom1281Path];
    [self.preferences setObject:@"128-1.rom" forKey:cRom1281Name];
    [self.preferences synchronize];
}

- (BOOL)isFileAtUrl:(NSURL *)url size:(NSUInteger)dataSize
{
    NSData *romData = [NSData dataWithContentsOfURL:url];
    
    if (romData.length != dataSize)
    {
        return NO;
    }
    
    return YES;
}

- (void)displayInvalidROM
{
    NSAlert *alert = [NSAlert new];
    alert.informativeText = @"The ROM file selected is not 16k?";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode)
     {
     }];
}

#pragma mark - Drag and Drop

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pBoard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pBoard = [sender draggingPasteboard];
    
    if ([[pBoard types] containsObject:NSFilenamesPboardType])
    {
        if (sourceDragMask * NSDragOperationCopy)
        {
            NSURL *fileURL = [NSURL URLFromPasteboard:pBoard];
            if ([[fileURL.pathExtension uppercaseString]isEqualToString:@"ROM"])
            {
                if ([self isFileAtUrl:fileURL size:cROM_SIZE_16K])
                {
                    if (NSPointInRect(sender.draggingLocation, self.rom48.bounds))
                    {
                        return NSDragOperationCopy;
                    }
                    else if (NSPointInRect(sender.draggingLocation, self.rom1280.bounds))
                    {
                        return NSDragOperationCopy;
                    }
                    else if (NSPointInRect(sender.draggingLocation, self.rom1281.bounds))
                    {
                        return NSDragOperationCopy;
                    }
                }
            }
            else
            {
                return NSDragOperationNone;
            }
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    if (NSPointInRect(sender.draggingLocation, self.rom48.bounds))
    {
        return NSDragOperationCopy;
    }
    else if (NSPointInRect(sender.draggingLocation, self.rom1280.bounds))
    {
        return NSDragOperationCopy;
    }
    else if (NSPointInRect(sender.draggingLocation, self.rom1281.bounds))
    {
        return NSDragOperationCopy;
    }

    return NSDragOperationNone;

}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pBoard = [sender draggingPasteboard];
    if ([[pBoard types] containsObject:NSURLPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pBoard];
        if (NSPointInRect(sender.draggingLocation, self.rom48.bounds))
        {
            [self setRomWithURL:fileURL forMachineType:e48kRom];
            return YES;
        }
        else if (NSPointInRect(sender.draggingLocation, self.rom1280.bounds))
        {
            [self setRomWithURL:fileURL forMachineType:e128kRom_0];
            return YES;
        }
        else if (NSPointInRect(sender.draggingLocation, self.rom1281.bounds))
        {
            [self setRomWithURL:fileURL forMachineType:e128kRom_1];
            return YES;
        }
    }
    return NO;
}

@end
