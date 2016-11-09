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
        self.wantsLayer = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configPopoverClosed:) name:NSPopoverDidCloseNotification object: NULL];
        isFaded = YES;
    }
    
    return self;
}

- (void)viewDidMoveToSuperview
{
}

- (void)viewDidMoveToWindow
{
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = self.window.frame.origin;
    mouseLocation = (NSPoint){mouseLocation.x - windowLocation.x, mouseLocation.y - windowLocation.y};
    [self updateButtonWithMouseLocation:mouseLocation];    
}

- (void)mouseMoved:(NSEvent *)event
{
    [super mouseMoved:event];
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = self.window.frame.origin;
    mouseLocation = (NSPoint){mouseLocation.x - windowLocation.x, mouseLocation.y - windowLocation.y};
    [self updateButtonWithMouseLocation:mouseLocation];
}

- (void)updateButtonWithMouseLocation:(NSPoint)point
{
    EmulationViewController *emulationViewController = (EmulationViewController *)[self.window contentViewController];
    
    CGFloat x = fabs(NSMaxX(self.configButton.frame) - (self.configButton.bounds.size.width / 2) - point.x);
    CGFloat y = fabs(NSMaxY(self.configButton.frame) - (self.configButton.bounds.size.height / 2) - point.y);
    float distance = hypotf(x, y);
    
//    if (![emulationViewController.configPopover isShown])
//    {
        NSRect configButtonFrame = _configButton.frame;
        if (distance > 50 && !isFaded)
        {
            isFaded = YES;
            [_configButton.animator setAlphaValue:0.25];
            configButtonFrame.origin.y = -32;
            [_configButton.animator setFrame:configButtonFrame];
        }
        else if (distance <= 50 && isFaded)
        {
            isFaded = NO;
            [_configButton.animator setAlphaValue:1.0];
            configButtonFrame.origin.y = 0;
            [_configButton.animator setFrame:configButtonFrame];
        }
//    }
//    else
//    {
//        _configButton.alphaValue = 1.0;
//    }
}

- (void)configPopoverClosed:(NSNotification *)notification
{
    [self updateButtonWithMouseLocation:self.window.mouseLocationOutsideOfEventStream];
}

@end
