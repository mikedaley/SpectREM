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
    [self removeObserver:self forKeyPath:@"displayCurve"];
    [self removeObserver:self forKeyPath:@"displaySaturation"];
    [self removeObserver:self forKeyPath:@"displayContrast"];
    [self removeObserver:self forKeyPath:@"displayBrightness"];
    [self removeObserver:self forKeyPath:@"displayShowVignette"];
    [self removeObserver:self forKeyPath:@"displayVignetteX"];
    [self removeObserver:self forKeyPath:@"displayVignetteY"];
    [self removeObserver:self forKeyPath:@"displayScanLine"];
    [self removeObserver:self forKeyPath:@"displayRGBOffset"];
    [self removeObserver:self forKeyPath:@"displayHorizOffset"];
    [self removeObserver:self forKeyPath:@"displayVertJump"];
    [self removeObserver:self forKeyPath:@"displayVertRoll"];
    [self removeObserver:self forKeyPath:@"displayStatic"];
    [self removeObserver:self forKeyPath:@"displayShowReflection"];
    [self removeObserver:self forKeyPath:@"screenHeight"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.emulationBackingSprite = (SKSpriteNode *)[self childNodeWithName:@"/emulationBackingSprite"];
        self.emulationDisplaySprite = (SKSpriteNode *)[self childNodeWithName:@"/emulationDisplaySprite"];

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
                               [SKAttribute attributeWithName:@"u_scan_line" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_rgb_offset" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_horiz_offset" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_vert_jump" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_vert_roll" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_static" type:SKAttributeTypeFloat],
                               [SKAttribute attributeWithName:@"u_show_reflection" type:SKAttributeTypeFloat],
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
    [self addObserver:self forKeyPath:@"displayCurve" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displaySaturation" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayContrast" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayBrightness" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayShowVignette" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVignetteX" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVignetteY" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayScanLine" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayRGBOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayHorizOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVertJump" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayVertRoll" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayStatic" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"displayShowReflection" options:NSKeyValueObservingOptionNew context:NULL];
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
    else if ([keyPath isEqualToString:@"displayScanLine"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_scan_line"];
    }
    else if ([keyPath isEqualToString:@"displayRGBOffset"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_rgb_offset"];
    }
    else if ([keyPath isEqualToString:@"displayHorizOffset"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_horiz_offset"];
    }
    else if ([keyPath isEqualToString:@"displayVertJump"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vert_jump"];
    }
    else if ([keyPath isEqualToString:@"displayVertRoll"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_vert_roll"];
    }
    else if ([keyPath isEqualToString:@"displayStatic"])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:@"u_static"];
    }
    else if ([keyPath isEqualToString:@"displayShowReflection"])
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

