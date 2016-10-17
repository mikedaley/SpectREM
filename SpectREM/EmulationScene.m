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
    _shader.uniforms = @[[SKUniform uniformWithName:@"size"
                                      vectorFloat2:vector2((float)352, (float)304)]];

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
    _emulationDisplaySprite.shader.uniforms = @[[SKUniform uniformWithName:@"size"
                                                              vectorFloat2:vector2((float)newSize.width,
                                                                                   (float)newSize.height)]];
}

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

