//
//  GameScene.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationScene.h"

#pragma mark - Implementation

@implementation EmulationScene {
    SKShader *_shader;
}

- (void)didMoveToView:(SKView *)view {
    self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"//emulationDisplaySprite"];
    
    _shader = [SKShader shaderWithFileNamed:@"CRT.fsh"];    
    _shader.uniforms = @[[SKUniform uniformWithName:@"u_distortion" float:0.125]
                         ];

    self.emulationDisplaySprite.shader = _shader;

}

#pragma mark - Keyboard Events

- (void)keyDown:(NSEvent *)event {
    [self.keyboardDelegate keyDown:event];
}

- (void)keyUp:(NSEvent *)event
{
    [self.keyboardDelegate keyUp:event];
}

#pragma mark - Scene View Size Changes

- (void)sceneViewSizeChanged:(CGSize)newSize
{

}

#pragma mark - UI Control Values

- (void)curveSliderChanged:(float)newValue
{
    _emulationDisplaySprite.shader.uniforms = @[[SKUniform uniformWithName:@"u_distortion" float:newValue]];
}

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

