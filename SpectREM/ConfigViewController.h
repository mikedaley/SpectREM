//
//  ConfigViewController.h
//  SpectREM
//
//  Created by Mike Daley on 18/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConfigViewController : NSViewController

// Display properties
@property (assign) double displayBorderWidth;
@property (assign) bool displayPixelated;
@property (assign) double displayCurve;
@property (assign) double displaySaturation;
@property (assign) double displayContrast;
@property (assign) double displayBrightness;
@property (assign) double displayShowVignette;
@property (assign) double displayVignetteX;
@property (assign) double displayVignetteY;

// Sound properties
@property (assign) double maxSoundVolume;
@property (assign) double soundVolume;
@property (assign) double soundHighPassFilter;
@property (assign) double soundLowPassFilter;
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

- (void)resetPreferences;

@end
