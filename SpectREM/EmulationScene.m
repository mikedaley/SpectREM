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

- (void)sceneDidLoad
{
    
}

- (void)didMoveToView:(SKView *)view {
    self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"//emulationDisplaySprite"];
    
    _shader = [SKShader shaderWithFileNamed:@"CRT.fsh"];
    _shader.attributes = @[
                           [SKAttribute attributeWithName:@"u_distortion" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_saturation" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_contrast" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_brightness" type:SKAttributeTypeFloat]
                           ];
    self.emulationDisplaySprite.shader = _shader;

    [self setupObservers];
}

#pragma mark - Observers

- (void)setupObservers
{
    [self addObserver:self forKeyPath:@"displayCurve" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displaySaturation" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayContrast" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayBrightness" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"displayCurve"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_distortion"];
    }
    else if ([keyPath isEqualToString:@"displaySaturation"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_saturation"];
    }
    else if ([keyPath isEqualToString:@"displayContrast"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_contrast"];
    }
    else if ([keyPath isEqualToString:@"displayBrightness"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_brightness"];
    }
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

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

