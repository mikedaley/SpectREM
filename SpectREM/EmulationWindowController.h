//
//  EmulationWindowController.h
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EmulationWindowController : NSWindowController

@property (nonatomic, assign) NSView *controlsView;

- (void)updateTrafficlightsWithMouseLocation:(NSPoint)point;

@end
