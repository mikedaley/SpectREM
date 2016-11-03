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

}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.wantsLayer = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configPopoverClosed:) name:NSPopoverDidCloseNotification object: NULL];
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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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
    
    if (![emulationViewController.configPopover isShown])
    {
        if (distance > 50)
        {
            [_configButton.animator setAlphaValue:0.3];
        }
        else
        {
            [_configButton.animator setAlphaValue:1.0];
        }
    }
    else
    {
        _configButton.alphaValue = 1.0;
    }
}

- (void)configPopoverClosed:(NSNotification *)notification
{
    [self updateButtonWithMouseLocation:self.window.mouseLocationOutsideOfEventStream];
}

@end
