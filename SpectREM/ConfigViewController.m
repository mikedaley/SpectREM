//
//  ConfigViewController.m
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "ConfigViewController.h"
@import ORSSerial;

#pragma mark - Key Path Constants

NSString *const cDisplayBorderWidth = @"displayBorderWidth";
NSString *const cDisplayCurve = @"displayCurve";
NSString *const cDisplaySaturation = @"displaySaturation";
NSString *const cDisplayContrast = @"displayContrast";
NSString *const cDisplayBrightness = @"displayBrightness";
NSString *const cDisplayShowVignette = @"displayShowVignette";
NSString *const cDisplayVignetteX = @"displayVignetteX";
NSString *const cDisplayVignetteY = @"displayVignetteY";
NSString *const cDisplayScanLine = @"displayScanLine";
NSString *const cDisplayRGBOffset = @"displayRGBOffset";
NSString *const cDisplayHorizOffset = @"displayHorizOffset";
NSString *const cDisplayVertJump = @"displayVertJump";
NSString *const cDisplayVertRoll = @"displayVertRoll";
NSString *const cDisplayStatic = @"displayStatic";
NSString *const cDisplayShowReflection = @"displayShowReflection";
NSString *const cSoundVolume = @"soundVolume";
NSString *const cSoundLowPassFilter = @"soundLowPassFilter";
NSString *const cSoundHighPassFilter = @"soundHighPassFilter";
NSString *const cAYChannelA = @"AYChannelA";
NSString *const cAYChannelB = @"AYChannelB";
NSString *const cAYChannelC = @"AYChannelC";
NSString *const cAYChannelABalance = @"AYChannelABalance";
NSString *const cAYChannelBBalance = @"AYChannelBBalance";
NSString *const cAYChannelCBalance = @"AYChannelCBalance";
NSString *const cCurrentMachineType = @"currentMachineType";
NSString *const cAccelerationMultiplier = @"accelerationMultiplier";
NSString *const cAccelerate = @"accelerate";
NSString *const cSerialPort = @"serialPort";
NSString *const cUseSmartLink = @"useSmartLink";
NSString *const cSceneScaleMode = @"sceneScaleMode";
NSString *const cUseAYOn48k = @"useAYOn48k";
NSString *const cSpecDrum = @"specDrum";
NSString *const cMultiface1 = @"multiface1";
NSString *const cMultiface128 = @"multiface128";
NSString *const cMultiface128Lockout = @"multiface128Lockout";

#pragma mark - Implementation 

@implementation ConfigViewController
{
    NSUserDefaults *_preferences;
}

- (void)dealloc
{
    _preferences = [NSUserDefaults standardUserDefaults];
    [_preferences removeObserver:self forKeyPath:cDisplayBorderWidth];
    [_preferences removeObserver:self forKeyPath:cDisplayCurve];
    [_preferences removeObserver:self forKeyPath:cDisplaySaturation];
    [_preferences removeObserver:self forKeyPath:cDisplayContrast];
    [_preferences removeObserver:self forKeyPath:cDisplayBrightness];
    [_preferences removeObserver:self forKeyPath:cDisplayShowVignette];
    [_preferences removeObserver:self forKeyPath:cDisplayVignetteX];
    [_preferences removeObserver:self forKeyPath:cDisplayVignetteY];
    [_preferences removeObserver:self forKeyPath:cDisplayScanLine];
    [_preferences removeObserver:self forKeyPath:cDisplayRGBOffset];
    [_preferences removeObserver:self forKeyPath:cDisplayHorizOffset];
    [_preferences removeObserver:self forKeyPath:cDisplayVertJump];
    [_preferences removeObserver:self forKeyPath:cDisplayVertRoll];
    [_preferences removeObserver:self forKeyPath:cDisplayStatic];
    [_preferences removeObserver:self forKeyPath:cDisplayShowReflection];

    [_preferences removeObserver:self forKeyPath:cSoundVolume];
    [_preferences removeObserver:self forKeyPath:cSoundLowPassFilter];
    [_preferences removeObserver:self forKeyPath:cSoundHighPassFilter];
    [_preferences removeObserver:self forKeyPath:cAYChannelA];
    [_preferences removeObserver:self forKeyPath:cAYChannelB];
    [_preferences removeObserver:self forKeyPath:cAYChannelC];
    [_preferences removeObserver:self forKeyPath:cAYChannelABalance];
    [_preferences removeObserver:self forKeyPath:cAYChannelBBalance];
    [_preferences removeObserver:self forKeyPath:cAYChannelCBalance];
    [_preferences removeObserver:self forKeyPath:cUseAYOn48k];

    [_preferences removeObserver:self forKeyPath:cSpecDrum];
    [_preferences removeObserver:self forKeyPath:cMultiface1];
    [_preferences removeObserver:self forKeyPath:cMultiface128];
    [_preferences removeObserver:self forKeyPath:cMultiface128Lockout];

    [_preferences removeObserver:self forKeyPath:cCurrentMachineType];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        _preferences = [NSUserDefaults standardUserDefaults];
        
        [_preferences addObserver:self forKeyPath:cDisplayBorderWidth options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayCurve options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplaySaturation options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayContrast options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayBrightness options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayShowVignette options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayVignetteX options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayVignetteY options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayScanLine options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayRGBOffset options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayHorizOffset options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayVertJump options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayVertRoll options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayStatic options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cDisplayShowReflection options:NSKeyValueObservingOptionNew context:NULL];
        
        // Set the maximum volume that the volume control can select with > 1.0 means we are amplifying the output
        self.maxSoundVolume = 3.0;
        
        [_preferences addObserver:self forKeyPath:cSoundVolume options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cSoundLowPassFilter options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cSoundHighPassFilter options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelA options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelB options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelC options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelABalance options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelBBalance options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cAYChannelCBalance options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cUseAYOn48k options:NSKeyValueObservingOptionNew context:NULL];

        [_preferences addObserver:self forKeyPath:cSpecDrum options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cMultiface1 options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cMultiface128 options:NSKeyValueObservingOptionNew context:NULL];
        [_preferences addObserver:self forKeyPath:cMultiface128Lockout options:NSKeyValueObservingOptionNew context:NULL];

        [_preferences addObserver:self forKeyPath:cCurrentMachineType options:NSKeyValueObservingOptionNew context:NULL];
        
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
             cDisplayBorderWidth,
             cDisplayCurve,
             cDisplaySaturation,
             cDisplayBrightness,
             cDisplayContrast,
             cDisplayShowVignette,
             cDisplayVignetteX,
             cDisplayVignetteY,
             cSoundVolume,
             cSoundLowPassFilter,
             cSoundHighPassFilter,
             cAYChannelABalance,
             cAYChannelBBalance,
             cAYChannelCBalance,
             cAccelerationMultiplier,
             cDisplayScanLine,
             cDisplayRGBOffset,
             cDisplayHorizOffset,
             cDisplayVertJump,
             cDisplayVertRoll,
             cDisplayStatic,
             cDisplayShowReflection
             ];
}

- (NSArray *)observableUIntKeys
{
    return @[
             cCurrentMachineType
             ];
}

- (NSArray *)observableBoolKeys
{
    return @[
             cAYChannelA,
             cAYChannelB,
             cAYChannelC,
             cUseAYOn48k,
             cAccelerate,
             cSpecDrum,
             cMultiface1,
             cMultiface128,
             cMultiface128Lockout
             ];
}

- (ORSSerialPortManager *)serialPortManager
{
    return [ORSSerialPortManager sharedSerialPortManager];
}

@end
