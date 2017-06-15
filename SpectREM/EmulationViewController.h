//
//  ViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "PixelData.h"

@class EmulationView;
@class ZXTape;
@class EmulationScene;

enum
{
    cZ80_SNAPSHOT_TYPE = 0,
    cSNA_SNAPSHOT_TYPE
};

@interface EmulationViewController : NSViewController

// Emulation view that contains the SpriteKit scene used to render the emulations display
@property (assign) IBOutlet EmulationView *skView;
@property (strong) EmulationScene *emulationScene;

@property (weak) IBOutlet NSVisualEffectView *configEffectsView;
@property (weak) IBOutlet NSScrollView *configScrollView;

@property (strong) NSMutableArray *disassemblyArray;

@property (strong) NSMutableDictionary *debugLabels;

#pragma mark - Methods

// Called by the machine being emulated when a new display image is ready to be displayed
- (void)updateEmulationViewWithPixelBuffer:(unsigned char *)pixelBuffer length:(CFIndex)length size:(CGSize)size;

// Load the file referenced in the supplied URL into the currently running machine
- (void)loadFileWithURL:(NSURL *)url;

@end

