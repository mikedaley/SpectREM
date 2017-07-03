//
//  GameScene.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationScene.h"
#import "ConfigViewController.h"

#pragma mark - Implementation

@implementation EmulationScene {
    
    SKShader *_shader;

}

- (void)dealloc
{
    NSLog(@"Deallocating Scene");
    [self removeObserver:self forKeyPath:cDisplayCurve];
    [self removeObserver:self forKeyPath:cDisplaySaturation];
    [self removeObserver:self forKeyPath:cDisplayContrast];
    [self removeObserver:self forKeyPath:cDisplayBrightness];
    [self removeObserver:self forKeyPath:cDisplayShowVignette];
    [self removeObserver:self forKeyPath:cDisplayVignetteX];
    [self removeObserver:self forKeyPath:cDisplayVignetteY];
    [self removeObserver:self forKeyPath:cDisplayScanLine];
    [self removeObserver:self forKeyPath:cDisplayRGBOffset];
    [self removeObserver:self forKeyPath:cDisplayHorizOffset];
    [self removeObserver:self forKeyPath:cDisplayVertJump];
    [self removeObserver:self forKeyPath:cDisplayVertRoll];
    [self removeObserver:self forKeyPath:cDisplayStatic];
    [self removeObserver:self forKeyPath:cDisplayShowReflection];
    [self removeObserver:self forKeyPath:@"screenHeight"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.emulationBackingSprite = (SKSpriteNode *)[self childNodeWithName:@"/emulationBackingSprite"];
        self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"/emulationDisplaySprite"];

//        _shader = [SKShader shaderWithFileNamed:@"OpenGL.fsh"];
        _shader = [SKShader shaderWithFileNamed:@"CRT.fsh"];
        _shader.attributes = @[
                               [SKAttribute attributeWithName:@"u_distortion" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_saturation" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_contrast" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_brightness" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_show_vignette" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_vignette_x" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_vignette_y" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_screen_height" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_scan_line" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_rgb_offset" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_horiz_offset" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_vert_jump" type:SKAttributeTypeHalfFloat],
//                               [SKAttribute attributeWithName:@"u_vert_roll" type:SKAttributeTypeHalfFloat],
//                               [SKAttribute attributeWithName:@"u_static" type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:@"u_show_reflection" type:SKAttributeTypeHalfFloat]
                               ];
        _shader.uniforms = @[
                             [SKUniform uniformWithName:@"u_reflection" texture:[SKTexture textureWithImageNamed:@"reflection"]]
                             ];
        self.emulationDisplaySprite.shader = _shader;
        [self setupObservers];
    }
    return self;
}

#pragma mark - Observers

- (void)setupObservers
{
    [self addObserver:self forKeyPath:cDisplayCurve options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplaySaturation options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayContrast options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayBrightness options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayShowVignette options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayVignetteX options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayVignetteY options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayScanLine options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayRGBOffset options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayHorizOffset options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayVertJump options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayVertRoll options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayStatic options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:cDisplayShowReflection options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"screenHeight" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:cDisplayCurve])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_distortion"];
    }
    else if ([keyPath isEqualToString:cDisplaySaturation])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_saturation"];
    }
    else if ([keyPath isEqualToString:cDisplayContrast])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_contrast"];
    }
    else if ([keyPath isEqualToString:cDisplayBrightness])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_brightness"];
    }
    else if ([keyPath isEqualToString:cDisplayShowVignette])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_show_vignette"];
    }
    else if ([keyPath isEqualToString:cDisplayVignetteX])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vignette_x"];
    }
    else if ([keyPath isEqualToString:cDisplayVignetteY])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vignette_y"];
    }
    else if ([keyPath isEqualToString:cDisplayScanLine])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_scan_line"];
    }
    else if ([keyPath isEqualToString:cDisplayRGBOffset])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_rgb_offset"];
    }
    else if ([keyPath isEqualToString:cDisplayHorizOffset])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_horiz_offset"];
    }
    else if ([keyPath isEqualToString:cDisplayVertJump])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vert_jump"];
    }
    else if ([keyPath isEqualToString:cDisplayVertRoll])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vert_roll"];
    }
    else if ([keyPath isEqualToString:cDisplayStatic])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_static"];
    }
    else if ([keyPath isEqualToString:cDisplayShowReflection])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_show_reflection"];
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
    [self.emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:newSize.height] forAttributeNamed:@"u_screen_height"];
}

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

