//
//  ViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>

@class EmulationView;

@interface EmulationViewController : NSViewController

// Emulation view that contains the SpriteKit scene used to render the emulations display
@property (assign) IBOutlet EmulationView *skView;

@property (weak) IBOutlet NSVisualEffectView *configEffectsView;
@property (weak) IBOutlet NSScrollView *configScrollView;

#pragma mark - Methods

// Called by the machine being emulated when a new display image is ready to be displayed
- (void)updateEmulationDisplayWithTexture:(SKTexture *)emulationDisplayTexture;

// Load the file referenced in the supplied URL into the currently running machine
- (void)loadFileWithURL:(NSURL *)url;

@end

