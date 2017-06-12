//
//  KeyboardViewController.h
//  SpectREM
//
//  Created by Mike Daley on 23/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyboardViewController : NSViewController

@property (nonatomic, assign) NSUInteger selectedKeyboard;
@property (weak) IBOutlet NSImageView *keyboardImageView;

@end
