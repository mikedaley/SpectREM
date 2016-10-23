//
//  ZXSpectrum48.h
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardEventProtocol.h"

@class AudioCore;
@class EmulationViewController;

@interface ZXSpectrum48 : NSObject <KeyboardEventProtocol>

#pragma mark - Properties

// Buffer used to hold the sound samples generated for each emulation frame
@property (assign) int16_t *audioBuffer;

// Reference to the audio core instance
@property (strong) AudioCore *audioCore;

// Queue on which the emulation is run
@property (strong) dispatch_queue_t emulationQueue;

@property (assign) float displayBorderWidth;
@property (assign) float soundVolume;
@property (assign) double soundLowPassFilter;
@property (assign) double soundHighPassFilter;

#pragma mark - Methods

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController;
- (void)start;
- (void)reset;
- (void)loadSnapshotWithPath:(NSString *)path;
- (void)doFrame;

@end
