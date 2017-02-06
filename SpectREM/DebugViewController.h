//
//  DebugViewController.h
//  SpectREM
//
//  Created by Mike Daley on 06/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXSpectrum;

@interface DebugViewController : NSViewController <NSTableViewDataSource, NSTabViewDelegate>

@property (assign) ZXSpectrum *machine;
@property (weak) IBOutlet NSTableView *disassemblyTableview;

@end
