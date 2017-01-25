//
//  ConfigViewController.m
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ConfigViewController.h"
@import ORSSerial;

@implementation ConfigViewController
{
    NSUserDefaults *_preferences;
}

- (void)dealloc
{
    _preferences = [NSUserDefaults standardUserDefaults];
    [_preferences removeObserver:self forKeyPath:@"displayBorderWidth"];
    [_preferences removeObserver:self forKeyPath:@"displayCurve"];
    [_preferences removeObserver:self forKeyPath:@"displaySaturation"];
    [_preferences removeObserver:self forKeyPath:@"displayContrast"];
    [_preferences removeObserver:self forKeyPath:@"displayBrightness"];
    [_preferences removeObserver:self forKeyPath:@"displayShowVignette"];
    [_preferences removeObserver:self forKeyPath:@"displayVignetteX"];
    [_preferences removeObserver:self forKeyPath:@"displayBorderWidth"];
    [_preferences removeObserver:self forKeyPath:@"displayVignetteY"];
    [_preferences removeObserver:self forKeyPath:@"displayScanLine"];
    [_preferences removeObserver:self forKeyPath:@"displayRGBOffset"];
    [_preferences removeObserver:self forKeyPath:@"displayHorizOffset"];
    [_preferences removeObserver:self forKeyPath:@"displayVertJump"];
    [_preferences removeObserver:self forKeyPath:@"displayVertRoll"];
    [_preferences removeObserver:self forKeyPath:@"displayStatic"];
    [_preferences removeObserver:self forKeyPath:@"displayShowReflection"];

    [_preferences removeObserver:self forKeyPath:@"soundVolume"];
    [_preferences removeObserver:self forKeyPath:@"soundLowPassFilter"];
    [_preferences removeObserver:self forKeyPath:@"soundHighPassFilter"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelA"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelB"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelC"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelABalance"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelBBalance"];
    [_preferences removeObserver:self forKeyPath:@"AYChannelCBalance"];

    [_preferences removeObserver:self forKeyPath:@"currentMachineType"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _preferences = [NSUserDefaults standardUserDefaults];
        
        [_preferences addObserver:self forKeyPath:@"displayBorderWidth" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayCurve" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displaySaturation" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayContrast" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayBrightness" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayShowVignette" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayVignetteX" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayVignetteY" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayScanLine" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayRGBOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayHorizOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayVertJump" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayVertRoll" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayStatic" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"displayShowReflection" options:NSKeyValueObservingOptionNew context:NULL];
        
        // Set the maximum volume that the volume control can select with > 1.0 means we are amplifying the output
        self.maxSoundVolume = 3.0;
        
        [_preferences addObserver:self forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelA" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelB" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelC" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelABalance" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelBBalance" options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:@"AYChannelCBalance" options:NSKeyValueObservingOptionNew context:NULL];
        
        [_preferences addObserver:self forKeyPath:@"currentMachineType" options:NSKeyValueObservingOptionNew context:NULL];
        
        self.accelerate = NO;
        self.accelerationMultiplier = 2.0;
        
        // Apply default values
        NSString *userDefaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
        NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsPath];
        [_preferences registerDefaults:userDefaults];
        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [defaultsController setInitialValues:userDefaults];
    }
    return self;
}

- (void)resetPreferences
{
    NSWindow *window = [[NSApplication sharedApplication] mainWindow];
    
    NSAlert *alert = [NSAlert new];
    alert.informativeText = @"Are you sure you want to reset your preferences?";
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode)
    {
        if (returnCode == NSAlertSecondButtonReturn)
        {
            NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
            [defaultsController revertToInitialValues:[self observableFloatKeys]];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    for (NSString *key in [self observableFloatKeys])
    {
        if ([keyPath isEqualToString:key] && [[self valueForKey:key] floatValue] != [change[NSKeyValueChangeNewKey] floatValue])
        {
            [self setValue:change[NSKeyValueChangeNewKey] forKey:key];
            return;
        }
    }

    for (NSString *key in [self observableUIntKeys])
    {
        if ([keyPath isEqualToString:key] && [[self valueForKey:key] unsignedIntegerValue] != [change[NSKeyValueChangeNewKey] unsignedIntegerValue])
        {
            [self setValue:change[NSKeyValueChangeNewKey] forKey:key];
            return;
        }
    }

    for (NSString *key in [self observableBoolKeys])
    {
        if ([keyPath isEqualToString:key] && [[self valueForKey:key] boolValue] != [change[NSKeyValueChangeNewKey] boolValue])
        {
            [self setValue:change[NSKeyValueChangeNewKey] forKey:key];
            return;
        }
    }
}

- (NSArray *)observableFloatKeys
{
    return @[
             @"displayBorderWidth",
             @"displayCurve",
             @"displaySaturation",
             @"displayBrightness",
             @"displayContrast",
             @"displayShowVignette",
             @"displayVignetteX",
             @"displayVignetteY",
             @"soundVolume",
             @"soundLowPassFilter",
             @"soundHighPassFilter",
             @"AYChannelABalance",
             @"AYChannelBBalance",
             @"AYChannelCBalance",
             @"acceleratedMultiplier",
             @"displayScanLine",
             @"displayRGBOffset",
             @"displayHorizOffset",
             @"displayVertJump",
             @"displayVertRoll",
             @"displayStatic",
             @"displayShowReflection"
             ];
}

- (NSArray *)observableUIntKeys
{
    return @[
             @"currentMachineType"
             ];
}

- (NSArray *)observableBoolKeys
{
    return @[
             @"AYChannelA",
             @"AYChannelB",
             @"AYChannelC",
             @"accelerate"
             ];
}

- (ORSSerialPortManager *)serialPortManager
{
    return [ORSSerialPortManager sharedSerialPortManager];
}

@end
