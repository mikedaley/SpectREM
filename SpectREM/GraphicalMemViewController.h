//
//  GraphicalMemViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PixelImageView.h"

@interface GraphicalMemViewController : NSViewController

@property (strong) NSImage *memoryImage;
@property (weak) IBOutlet PixelImageView *memoryView;

- (void)updateViewWithMachine:(void *)m;

@end
