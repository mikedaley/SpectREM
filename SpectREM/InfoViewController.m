//
//  InfoViewController.m
//  SpectREM
//
//  Created by Mike Daley on 01/12/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.wantsLayer = YES;
    
    self.view.layer.frame = self.view.bounds;
    self.view.layer.cornerRadius = 10;
    self.view.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    [self.view setAlphaValue:0.0];
}

- (void)displayMessage
{
    [self.view.animator setAlphaValue:1.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view.animator setAlphaValue:0.0];
    });
}

@end
