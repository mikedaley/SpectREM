//
//  ConfigViewController.m
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ConfigViewController.h"
#import "EmulationViewController.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)curveSliderChanged:(id)sender
{
    [self.emulationViewController curveSliderChanged:sender];
}

- (IBAction)borderSliderChanged:(id)sender
{
    [self.emulationViewController borderSliderChanged:sender];
}

@end
