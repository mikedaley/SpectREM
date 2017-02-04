//
//  TapeViewController.h
//  SpectREM
//
//  Created by Mike Daley on 01/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXTape;

@interface TapeViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) ZXTape *tape;

@end
