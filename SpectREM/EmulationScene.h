//
//  GameScene.h
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface EmulationScene : SKScene

@property (strong) SKSpriteNode *emulationDisplaySprite;
@property (assign) id keyboardDelegate;

@end
