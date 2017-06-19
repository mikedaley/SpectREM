//
//  ConfigViewController.h
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RomSelectionViewController.h"

#pragma mark - Key Path Constants

extern NSString *const displayBorderWidth;


@class ORSSerialPortManager;
@class ORSSerialPort;

extern NSString *const cDisplayBorderWidth;
extern NSString *const cDisplayCurve;
extern NSString *const cDisplaySaturation;
extern NSString *const cDisplayContrast;
extern NSString *const cDisplayBrightness;
extern NSString *const cDisplayShowVignette;
extern NSString *const cDisplayVignetteX;
extern NSString *const cDisplayVignetteY;
extern NSString *const cDisplayScanLine;
extern NSString *const cDisplayRGBOffset;
extern NSString *const cDisplayHorizOffset;
extern NSString *const cDisplayVertJump;
extern NSString *const cDisplayVertRoll;
extern NSString *const cDisplayStatic;
extern NSString *const cDisplayShowReflection;
extern NSString *const cSoundVolume;
extern NSString *const cSoundLowPassFilter;
extern NSString *const cSoundHighPassFilter;
extern NSString *const cAYChannelA;
extern NSString *const cAYChannelB;
extern NSString *const cAYChannelC;
extern NSString *const cAYChannelABalance;
extern NSString *const cAYChannelBBalance;
extern NSString *const cAYChannelCBalance;
extern NSString *const cCurrentMachineType;
extern NSString *const cAccelerationMultiplier;
extern NSString *const cAccelerate;
extern NSString *const cSerialPort;
extern NSString *const cUseSmartLink;
extern NSString *const cSceneScaleMode;
extern NSString *const cUseAYOn48k;;
extern NSString *const cSpecDrum;
extern NSString *const cMultiface1;
extern NSString *const cMultiface128;
extern NSString *const cMultiface128Lockout;
extern NSString *const cInstaTAPLoading;
extern NSString *const cSmartCardEnabled;
extern NSString *const cRom48Name;
extern NSString *const cRom48Path;
extern NSString *const cRom1280Name;
extern NSString *const cRom1280Path;
extern NSString *const cRom1281Name;
extern NSString *const cRom1281Path;

@interface ConfigViewController : NSViewController

// Machine properties
@property (assign) BOOL accelerate;
@property (assign) double accelerationMultiplier;
@property (assign) NSInteger currentMachineType;
@property (assign) BOOL instaTAPLoading;
@property (strong) NSString *rom48Name;
@property (strong) NSString *rom48Path;
@property (strong) NSString *rom1280Name;
@property (strong) NSString *rom1280Path;
@property (strong) NSString *rom1281Name;
@property (strong) NSString *rom1281Path;

// Display properties
@property (assign) double displayBorderWidth;
@property (assign) bool displayPixelated;
@property (assign) float displayCurve;
@property (assign) float displaySaturation;
@property (assign) float displayContrast;
@property (assign) float displayBrightness;
@property (assign) float displayShowVignette;
@property (assign) float displayVignetteX;
@property (assign) float displayVignetteY;
@property (assign) float displayScanLine;
@property (assign) float displayRGBOffset;
@property (assign) float displayHorizOffset;
@property (assign) float displayVertJump;
@property (assign) float displayVertRoll;
@property (assign) float displayStatic;
@property (assign) float displayShowReflection;

// Sound properties
@property (assign) float maxSoundVolume;
@property (assign) float soundVolume;
@property (assign) float soundHighPassFilter;
@property (assign) float soundLowPassFilter;
@property (assign) bool AYChannelA;
@property (assign) bool AYChannelB;
@property (assign) bool AYChannelC;
@property (assign) float AYChannelABalance;
@property (assign) float AYChannelBBalance;
@property (assign) float AYChannelCBalance;

// Peripherals
@property (assign) bool useAYOn48k;
@property (assign) bool specDrum;
@property (assign) bool multiface1;
@property (assign) bool multiface128;
@property (assign) bool multiface128Lockout;
@property (assign) bool smartCardEnabled;
@property (nonatomic, readonly) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, assign) BOOL useSmartLink;

// UI Properties
@property (strong) IBOutlet NSView *scrollDocView;
@property (weak) IBOutlet NSScrollView *scrollView;

#pragma mark - Methods

- (void)resetPreferences;

@end
