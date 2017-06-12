//
//  RedView.m
//  SpectREM
//
//  Created by Mike Daley on 15/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "PixelImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PixelImageView

- (instancetype)init
{
    if (self = [super init])
    {
        self.wantsLayer = YES;
        self.canDrawConcurrently = YES;
        self.canDrawSubviewsIntoLayer = YES;
    }
    return self;
}

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (void)drawRect:(NSRect)dirtyRect
{
    const NSRect *rectsBeingDrawn = NULL;
    NSInteger rectsBeingDrawnCount = 0;
    
    [self getRectsBeingDrawn:&rectsBeingDrawn count:&rectsBeingDrawnCount];
    for (NSInteger i = 0; i < rectsBeingDrawnCount; i++)
    {
        @autoreleasepool {
            [self.memoryImage drawInRect:rectsBeingDrawn[i] fromRect:rectsBeingDrawn[i] operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:@{ NSImageHintInterpolation : @(NSImageInterpolationNone) }];
        }
    }
}

- (void)setMemoryImage:(NSImage *)memoryImage
{
    _memoryImage = memoryImage;
    [self setNeedsDisplay:YES];
}

@end
