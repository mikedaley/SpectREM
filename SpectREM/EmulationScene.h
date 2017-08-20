//
//  GameScene.h
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface EmulationScene : SKScene

#pragma mark - Properties

@property (strong) SKSpriteNode *emulationDisplaySprite;
@property (strong) SKSpriteNode *emulationBackingSprite;
@property (strong) SKMutableTexture *backingTexture;
@property (assign) id keyboardDelegate;

@property (assign) double displayCurve;
@property (assign) double displaySaturation;
@property (assign) double displayContrast;
@property (assign) double displayBrightness;
@property (assign) double displayShowVignette;
@property (assign) double displayVignetteX;
@property (assign) double displayVignetteY;
@property (assign) double displayScanLine;
@property (assign) double displayRGBOffset;
@property (assign) double displayHorizOffset;
@property (assign) double displayVertJump;
@property (assign) double displayVertRoll;
@property (assign) double displayStatic;
@property (assign) double screenHeight;
@property (assign) double displayShowReflection;

#pragma mark - Methods

// Called when the size of the scene view changes. Any updates that are needed when the size
// changes such as updating uniform values
- (void)sceneViewSizeChanged:(CGSize)newSize;


@end
