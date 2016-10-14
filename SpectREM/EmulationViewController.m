//
//  ViewController.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationViewController.h"
#import "EmulationScene.h"
#import "ZXSpectrum48.h"

@interface EmulationViewController ()

@property (strong) EmulationScene *emulationScene;

@property (strong) ZXSpectrum48 *machine;

@end

@implementation EmulationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the SKScene from 'GameScene.sks'
    self.emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    
    // Set the scale mode to scale to fit the window
    self.emulationScene.scaleMode = SKSceneScaleModeFill;
    
    // Present the scene
    [self.skView presentScene:self.emulationScene];
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    //Setup the machine to be emulated
    
    self.machine = [[ZXSpectrum48 alloc] initWithEmulationViewController:self];

    self.emulationScene.keyboardDelegate = self.machine;

    [self.machine start];
}

- (void)flagsChanged:(NSEvent *)event
{
    [self.machine flagsChanged:event];
}

- (void)updateEmulationDisplay:(CGImageRef)emulationDisplayImageRef
{
    self.emulationScene.emulationDisplaySprite.texture = [SKTexture textureWithCGImage:emulationDisplayImageRef];
}

- (IBAction)setAspectFitMode:(id)sender
{
    self.emulationScene.scaleMode = SKSceneScaleModeAspectFit;
}

- (IBAction)setFillMode:(id)sender
{
    self.emulationScene.scaleMode = SKSceneScaleModeFill;
}

- (IBAction)machineRestart:(id)sender
{
    dispatch_sync(self.machine.emulationQueue, ^{
        [self.machine reset];
    });
}

@end
