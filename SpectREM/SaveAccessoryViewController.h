//
//  SaveAccessoryViewController.h
//  SpectREM
//
//  Created by Mike Daley on 15/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SaveAccessoryViewController : NSViewController

@property (assign) NSInteger exportType;
@property (weak) IBOutlet NSPopUpButton *exportPopup;

@end
