//
//  GameScene.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationScene.h"

@interface EmulationScene ()

@end

#pragma mark - Implementation

@implementation EmulationScene {
    

}

- (void)didMoveToView:(SKView *)view {
    self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"//emulationDisplaySprite"];
    
    SKShader *shader = [SKShader shaderWithFileNamed:@"Plasma.fsh"];
    
    shader.uniforms = @[[SKUniform uniformWithName:@"size" vectorFloat2:vector2((float)self.frame.size.width*3, (float)self.frame.size.height*3)]];
    
    self.emulationDisplaySprite.shader = shader;


}

- (void)keyDown:(NSEvent *)event {
    [self.keyboardDelegate keyDown:event];
}

- (void)keyUp:(NSEvent *)event
{
    [self.keyboardDelegate keyUp:event];
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end


//    CGFloat w = (self.size.width + self.size.height) * 0.05;

// Create shape node to use during mouse interaction
//    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
//    _spinnyNode.lineWidth = 2.5;
//
//    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
//    [_spinnyNode runAction:[SKAction sequence:@[
//                                                [SKAction waitForDuration:0.5],
//                                                [SKAction fadeOutWithDuration:0.5],
//                                                [SKAction removeFromParent],
//                                                ]]];
