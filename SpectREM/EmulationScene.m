//
//  GameScene.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationScene.h"
#import "ConfigViewController.h"

#pragma mark - Constants

static NSString *const cU_DISTORTION =          @"u_distortion";
static NSString *const cU_SATURATION =          @"u_saturation";
static NSString *const cU_CONTRAST =            @"u_contrast";
static NSString *const cU_BRIGHTNESS =          @"u_brightness";
static NSString *const cU_SHOW_VIGNETTE =       @"u_show_vignette";
static NSString *const cU_VIGNETTE_X =          @"u_vignette_x";
static NSString *const cU_VIGNETTE_Y =          @"u_vignette_y";
static NSString *const cU_SCREEN_HEIGHT =       @"u_screen_height";
static NSString *const cU_SCAN_LINE =           @"u_scan_line";
static NSString *const cU_RGB_OFFSET =          @"u_rgb_offset";
static NSString *const cU_HORIZ_OFFSET =        @"u_horiz_offset";
static NSString *const cU_VERT_JUMP =           @"u_vert_jump";
static NSString *const cU_SHOW_REFLECTION =     @"u_show_reflection";
static NSString *const cU_VERT_ROLL =           @"u_vert_roll";
static NSString *const cU_STATIC =              @"u_static";
static NSString *const cU_REFLECTION =          @"u_reflection";

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

        _shader = [SKShader shaderWithFileNamed:@"CRT.fsh"];
        _shader.attributes = @[
                               [SKAttribute attributeWithName:cU_DISTORTION type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_SATURATION type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_CONTRAST type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_BRIGHTNESS type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_SHOW_VIGNETTE type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_VIGNETTE_X type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_VIGNETTE_Y type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_SCREEN_HEIGHT type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_SCAN_LINE type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_RGB_OFFSET type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_HORIZ_OFFSET type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_VERT_JUMP type:SKAttributeTypeHalfFloat],
                               [SKAttribute attributeWithName:cU_SHOW_REFLECTION type:SKAttributeTypeHalfFloat]
//                               [SKAttribute attributeWithName:cU_VERT_ROLL type:SKAttributeTypeHalfFloat],
//                               [SKAttribute attributeWithName:cU_STATIC type:SKAttributeTypeHalfFloat],
                               ];
        _shader.uniforms = @[
                             [SKUniform uniformWithName:cU_REFLECTION texture:[SKTexture textureWithImageNamed:@"reflection"]]
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
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_DISTORTION];
    }
    else if ([keyPath isEqualToString:cDisplaySaturation])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_SATURATION];
    }
    else if ([keyPath isEqualToString:cDisplayContrast])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_CONTRAST];
    }
    else if ([keyPath isEqualToString:cDisplayBrightness])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_BRIGHTNESS];
    }
    else if ([keyPath isEqualToString:cDisplayShowVignette])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_SHOW_VIGNETTE];
    }
    else if ([keyPath isEqualToString:cDisplayVignetteX])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_VIGNETTE_X];
    }
    else if ([keyPath isEqualToString:cDisplayVignetteY])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_VIGNETTE_Y];
    }
    else if ([keyPath isEqualToString:cDisplayScanLine])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_SCAN_LINE];
    }
    else if ([keyPath isEqualToString:cDisplayRGBOffset])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_RGB_OFFSET];
    }
    else if ([keyPath isEqualToString:cDisplayHorizOffset])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_HORIZ_OFFSET];
    }
    else if ([keyPath isEqualToString:cDisplayVertJump])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_VERT_JUMP];
    }
    else if ([keyPath isEqualToString:cDisplayVertRoll])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_VERT_ROLL];
    }
    else if ([keyPath isEqualToString:cDisplayStatic])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_STATIC];
    }
    else if ([keyPath isEqualToString:cDisplayShowReflection])
    {
        [_emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:[change[NSKeyValueChangeNewKey] floatValue]] forAttributeNamed:cU_SHOW_REFLECTION];
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
    [self.emulationDisplaySprite setValue:[SKAttributeValue valueWithFloat:newSize.height] forAttributeNamed:cU_SCREEN_HEIGHT];
}

#pragma mark - Game tick

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end

