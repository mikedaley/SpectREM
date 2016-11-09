//
//  EmulationView.m
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationView.h"
#import "EmulationViewController.h"

@implementation EmulationView
{
    BOOL isFaded;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        isFaded = YES;
    }
    
    return self;
}

- (void)mouseMoved:(NSEvent *)event
{
    [super mouseMoved:event];
    
//    NSPoint mouseLocation = [NSEvent mouseLocation];
//    NSPoint windowLocation = self.window.frame.origin;
//    mouseLocation = (NSPoint){mouseLocation.x - windowLocation.x, mouseLocation.y - windowLocation.y};
//    [self updateButtonWithMouseLocation:mouseLocation];
}


@end
