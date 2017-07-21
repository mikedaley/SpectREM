//
//  DebugWindowController.m
//  SpectREM
//
//  Created by Mike Daley on 17/07/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "DebugWindowController.h"
#import "DebugViewController.h"

@interface DebugWindowController ()

@property (weak) DebugViewController *debugViewController;

@end

@implementation DebugWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.debugViewController = (DebugViewController *)self.contentViewController;
}

- (void)keyDown:(NSEvent *)event
{
    if ((event.modifierFlags & NSEventModifierFlagCommand))
    {
        switch (event.keyCode) {
            case 1:
                [self.debugViewController step];
                break;
                
            default:
                break;
        }
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSLog(@"kk");
}

@end
