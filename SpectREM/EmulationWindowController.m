//
//  EmulationWindowController.m
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationWindowController.h"

@interface EmulationWindowController () <NSWindowDelegate>

@end

@implementation EmulationWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window center];
    [self.window setAcceptsMouseMovedEvents:YES];

}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseMoved:(NSEvent *)event
{
    NSLog(@"Moved");
}

@end
