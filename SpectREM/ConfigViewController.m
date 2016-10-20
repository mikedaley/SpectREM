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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *userDefaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
        NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsPath];
        [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
        
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        
        [preferences addObserver:self forKeyPath:@"displayBorderWidth" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayCurve" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displaySaturation" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayContrast" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayBrightness" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayVignetteX" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayVignetteY" options:NSKeyValueObservingOptionNew context:NULL];

        [preferences addObserver:self forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];

    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"displayBorderWidth"])
    {
        self.displayBorderWidth = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displayCurve"])
    {
        self.displayCurve = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displaySaturation"])
    {
        self.displaySaturation = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displayContrast"])
    {
        self.displayContrast = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displayBrightness"])
    {
        self.displayBrightness = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displayVignetteX"])
    {
        self.displayVignetteX = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"displayVignetteY"])
    {
        self.displayVignetteY = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"soundVolume"])
    {
        self.soundVolume = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"soundLowPassFilter"])
    {
        self.soundLowPassFilter = [change[NSKeyValueChangeNewKey] floatValue];
    }
    else if ([keyPath isEqualToString:@"soundHighPassFilter"])
    {
        self.soundHighPassFilter = [change[NSKeyValueChangeNewKey] floatValue];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
}

@end
