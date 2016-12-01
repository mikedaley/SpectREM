//
//  InfoViewController.h
//  SpectREM
//
//  Created by Mike Daley on 01/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InfoViewController : NSViewController

@property (strong) NSString *text;

- (void)displayMessage;

@end
