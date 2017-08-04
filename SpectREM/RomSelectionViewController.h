//
//  RomSelectionViewController.h
//  SpectREM
//
//  Created by Michael Daley on 18/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const cROM_EXTENSION;

@interface RomSelectionViewController : NSViewController <NSDraggingDestination>

- (void)reset48kRom;
- (void)reset128kRom0;
- (void)reset128kRom1;

@end
