//
//  MemoryViewController.h
//  SpectREM
//
//  Created by Mike Daley on 25/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXSpectrum;

@interface MemoryViewController : NSViewController <NSTableViewDataSource, NSTabViewDelegate, NSTextFieldDelegate>

@property (assign) ZXSpectrum *machine;
@property (assign) BOOL decimalFormat;
@property (weak) IBOutlet NSTableView *memoryTableView;
@property (assign, nonatomic) unsigned int byteWidth;

@end
