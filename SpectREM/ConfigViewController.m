//
//  ConfigViewController.m
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ConfigViewController.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - UI Actions

- (IBAction)displayBorderChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)displayCurveChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)displaySaturationChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)displayContrastChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)displayBrightnessChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)soundVolumeChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)soundHighPassChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

- (IBAction)soundLowPassChanged:(id)sender
{
    [self propagateValue:@([(NSSlider *)sender floatValue]) forBinding:@"value"];
}

@end
