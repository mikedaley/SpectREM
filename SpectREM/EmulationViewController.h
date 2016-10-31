//
//  ViewController.h
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>

@class EmulationView;

@interface EmulationViewController : NSViewController

@property (assign) IBOutlet EmulationView *skView;

#pragma mark - Methods

// Called by the machine being emulated when a new display image is ready to be displayed
- (void)updateEmulationDisplayTextureWithImage:(SKTexture *)emulationDisplayTexture;

- (void)loadFileWithURL:(NSURL *)url;

@end

