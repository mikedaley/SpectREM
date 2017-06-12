//
//  KeyboardViewController.m
//  SpectREM
//
//  Created by Mike Daley on 23/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "KeyboardViewController.h"

@interface KeyboardViewController ()

@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.selectedKeyboard = 0;
}

#pragma mark - Properties

- (void)setSelectedKeyboard:(NSUInteger)selectedKeyboard
{
    switch (selectedKeyboard) {
        default:
        case 0:
            self.keyboardImageView.image = [NSImage imageNamed:@"WirelessKeyboard"];
            break;
            
        case 1:
            self.keyboardImageView.image = [NSImage imageNamed:@"WiredKeyboard"];
            break;
    }
}

@end
