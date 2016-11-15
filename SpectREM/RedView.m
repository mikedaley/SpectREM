//
//  RedView.m
//  SpectREM
//
//  Created by Mike Daley on 15/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "RedView.h"

@implementation RedView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [[NSColor redColor] setFill];
    NSRectFill(self.frame);
}

@end
