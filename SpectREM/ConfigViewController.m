//
//  ConfigViewController.m
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ConfigViewController.h"

@implementation ConfigViewController

- (void)dealloc
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences removeObserver:self forKeyPath:@"displayBorderWidth"];
    [preferences removeObserver:self forKeyPath:@"displayCurve"];
    [preferences removeObserver:self forKeyPath:@"displaySaturation"];
    [preferences removeObserver:self forKeyPath:@"displayContrast"];
    [preferences removeObserver:self forKeyPath:@"displayBrightness"];
    [preferences removeObserver:self forKeyPath:@"displayShowVignette"];
    [preferences removeObserver:self forKeyPath:@"displayVignetteX"];
    [preferences removeObserver:self forKeyPath:@"displayBorderWidth"];
    [preferences removeObserver:self forKeyPath:@"displayVignetteY"];

    [preferences removeObserver:self forKeyPath:@"soundVolume"];
    [preferences removeObserver:self forKeyPath:@"soundLowPassFilter"];
    [preferences removeObserver:self forKeyPath:@"soundHighPassFilter"];
    [preferences removeObserver:self forKeyPath:@"AYChannelA"];
    [preferences removeObserver:self forKeyPath:@"AYChannelB"];
    [preferences removeObserver:self forKeyPath:@"AYChannelC"];
    [preferences removeObserver:self forKeyPath:@"AYChannelABalance"];
    [preferences removeObserver:self forKeyPath:@"AYChannelBBalance"];
    [preferences removeObserver:self forKeyPath:@"AYChannelCBalance"];

    [preferences removeObserver:self forKeyPath:@"currentMachineType"];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        
        [preferences addObserver:self forKeyPath:@"displayBorderWidth" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayCurve" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displaySaturation" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayContrast" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayBrightness" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayShowVignette" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayVignetteX" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"displayVignetteY" options:NSKeyValueObservingOptionNew context:NULL];
        
        [preferences addObserver:self forKeyPath:@"soundVolume" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"soundLowPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"soundHighPassFilter" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelA" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelB" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelC" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelABalance" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelBBalance" options:NSKeyValueObservingOptionNew context:NULL];
        [preferences addObserver:self forKeyPath:@"AYChannelCBalance" options:NSKeyValueObservingOptionNew context:NULL];
        
        [preferences addObserver:self forKeyPath:@"currentMachineType" options:NSKeyValueObservingOptionNew context:NULL];
        
        // Apply default values
        NSString *userDefaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
        NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsPath];
        [preferences registerDefaults:userDefaults];
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
             @"AYChannelCBalance"
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
             @"AYChannelC"
             ];
}

@end
