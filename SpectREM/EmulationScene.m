//
//  GameScene.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationScene.h"
#import "CALayer+Actions.h"

#pragma mark - Implementation

@implementation EmulationScene {
    
    SKShader *_shader;

}

- (void)sceneDidLoad
{
    self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"//emulationDisplaySprite"];
    self.emulationDisplaySprite.texture.filteringMode = SKTextureFilteringLinear;
    
    _shader = [SKShader shaderWithFileNamed:@"CRT.fsh"];
    _shader.attributes = @[
                           [SKAttribute attributeWithName:@"u_distortion" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_saturation" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_contrast" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_brightness" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_show_vignette" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_vignette_x" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_vignette_y" type:SKAttributeTypeFloat],
                           [SKAttribute attributeWithName:@"u_screen_height" type:SKAttributeTypeFloat],
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
    [self addObserver:self forKeyPath:@"displayShowVignette" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVignetteX" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVignetteY" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"screenHeight" options:NSKeyValueObservingOptionNew context:NULL];
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
    else if ([keyPath isEqualToString:@"displayShowVignette"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_show_vignette"];
    }
    else if ([keyPath isEqualToString:@"displayVignetteX"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vignette_x"];
    }
    else if ([keyPath isEqualToString:@"displayVignetteY"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vignette_y"];
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
    [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:newSize.height] forAttributeNamed:@"u_screen_height"];
}

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

