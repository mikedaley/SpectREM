//
//  EmulationView.m
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationView.h"

@implementation EmulationView
{

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
    CGFloat x = fabs(NSMaxX(self.window.contentView.bounds) - point.x);
    CGFloat y = fabs(NSMinY(self.window.contentView.bounds) - point.y);
    
    CGFloat distance = MAX(0, MAX(x, y) - 50);
    
    CGFloat intensity = 0.3 / 50.0 * (distance - 100);
    _configButton.alphaValue = MAX(1.0 - intensity, 0.3);
}

@end
