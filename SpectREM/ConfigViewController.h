//
//  ConfigViewController.h
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORSSerialPortManager;
@class ORSSerialPort;

@interface ConfigViewController : NSViewController

// Machine properties
@property (assign) BOOL accelerate;
@property (assign) double accelerationMultiplier;

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

// Emulation Properties
@property (assign) NSInteger currentMachineType;
@property (strong) IBOutlet NSView *scrollDocView;
@property (weak) IBOutlet NSScrollView *scrollView;

@property (nonatomic, readonly) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, assign) BOOL useSmartLink;

- (void)resetPreferences;

@end
