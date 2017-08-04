//
//  GraphicalMemViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PixelImageView.h"

@class ZXSpectrum;

@interface GraphicalMemViewController : NSViewController

@property (weak) IBOutlet PixelImageView *memoryView;

@property (assign) int displayByteWidth;

- (void)updateViewWithMachine:(ZXSpectrum *)m;

@end
