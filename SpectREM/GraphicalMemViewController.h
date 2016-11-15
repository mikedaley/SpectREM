//
//  GraphicalMemViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GraphicalMemViewController : NSViewController

@property (strong) NSImage *memoryImage;

- (void)updateImageFromMachine:(void *)m;

@end
