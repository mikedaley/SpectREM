//
//  RomSelectionViewController.m
//  SpectREM
//
//  Created by Michael Daley on 18/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "RomSelectionViewController.h"
#import "ConfigViewController.h"

typedef NS_ENUM(int, SZXMachineType)
{
    e48kRom = 0,
    e128kRom_0,
    e128kRom_1
};

static NSUInteger const cROM_SIZE_16K = 16384;

@interface RomSelectionViewController ()

@property (strong) NSUserDefaults *preferences;

@end

@implementation RomSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferences = [NSUserDefaults standardUserDefaults];
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

- (IBAction)selectRom:(id)sender
{

}

#pragma mark - Methods

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

            NSInteger tag = [(NSControl  *)sender tag];
            
            if (tag == e48kRom)
            {
                [self.preferences setURL:openPanel.URL forKey:cRom48Path];
                [self.preferences setObject:[openPanel.URL lastPathComponent] forKey:cRom48Name];
            }
            else if (tag == e128kRom_0)
            {
                [self.preferences setURL:openPanel.URL forKey:cRom1280Path];
                [self.preferences setObject:[openPanel.URL lastPathComponent] forKey:cRom1280Name];
            }
            else if (tag == e128kRom_1)
            {
                [self.preferences setURL:openPanel.URL forKey:cRom1281Path];
                [self.preferences setObject:[openPanel.URL lastPathComponent] forKey:cRom1281Name];
            }
            
            [self.preferences synchronize];
        }
    }];
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

@end
