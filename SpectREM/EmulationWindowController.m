//
//  EmulationWindowController.m
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationWindowController.h"
#import <CoreImage/CoreImage.h>

@interface EmulationWindowController () <NSWindowDelegate>

@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation EmulationWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    
    for (NSView *view in self.window.contentView.superview.subviews) {
        if (view != self.window.contentView && ![[view className] isEqualToString:@"NSVisualEffectsView"]) {
            self.controlsView = view;
            
            CIFilter *monoFilter = [CIFilter filterWithName:@"CIColorMonochrome"]; // CIImage
            [monoFilter setDefaults];
            [monoFilter setValue:[CIColor colorWithRed:.3 green:.3 blue:.3 alpha:1] forKey:@"inputColor"];
            [monoFilter setValue:@(0.0) forKey:@"inputIntensity"];
            [monoFilter setName:@"mono"];
            
            CIFilter *gammaFilter = [CIFilter filterWithName:@"CIGammaAdjust"]; // CIImage
            [gammaFilter setDefaults];
            [gammaFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputPower"];
            [gammaFilter setName:@"gamma"];
            
            [view setContentFilters:@[monoFilter, gammaFilter]];
            
            break;
        }
    }
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = self.window.frame.origin;
    
    mouseLocation = (NSPoint){mouseLocation.x - windowLocation.x, mouseLocation.y - windowLocation.y};
    [self updateTrafficlightsWithMouseLocation:mouseLocation];
    
    [self.window setAcceptsMouseMovedEvents:YES];
}

- (void)updateTrafficlightsWithMouseLocation:(NSPoint)point
{
    CGFloat x = fabs(NSMinX(self.window.contentView.bounds) - point.x);
    CGFloat y = fabs(NSMaxY(self.window.contentView.bounds) - point.y);
    
    CGFloat distance = MAX(0, MAX(x, y) - 40);
    
    if (distance < 100) {
        CGFloat intensity = 0.7 / 200.0 * distance;
        self.controlsView.alphaValue = MAX(1.0 - intensity, 0.3);
    }
    else {
        CGFloat intensity = 0.3 / 200.0 * (distance - 200);
        self.controlsView.alphaValue = MAX(0.0, 0.3 - intensity);
    }
    
    CGFloat mono = MIN(1.0, 1.0 / 200.0 * distance);
    [self.controlsView setValue:@(mono) forKeyPath:@"contentFilters.mono.inputIntensity"];
    
    CGFloat gamma = MIN(0.7, 0.7 / 200.0 * distance);
    [self.controlsView setValue:@(1.0 - gamma) forKeyPath:@"contentFilters.gamma.inputPower"];
}

@end
