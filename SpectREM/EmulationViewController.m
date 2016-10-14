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

#pragma mark - Private Interface

@interface EmulationViewController ()

@end

#pragma mark - Implementation

@implementation EmulationViewController
{
    EmulationScene *_emulationScene;
    ZXSpectrum48 *_machine;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the SKScene from 'GameScene.sks'
    _emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    
    // Set the scale mode to scale to fit the window
    _emulationScene.scaleMode = SKSceneScaleModeFill;
    
    // Present the scene
    [self.skView presentScene:_emulationScene];
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    //Setup the machine to be emulated
    
    _machine = [[ZXSpectrum48 alloc] initWithEmulationViewController:self];

    _emulationScene.keyboardDelegate = _machine;

    [_machine start];
}

#pragma mark - Keyboard events

- (void)flagsChanged:(NSEvent *)event
{
    [_machine flagsChanged:event];
}

- (void)updateEmulationDisplay:(CGImageRef)emulationDisplayImageRef
{
    _emulationScene.emulationDisplaySprite.texture = [SKTexture textureWithCGImage:emulationDisplayImageRef];
}

#pragma mark - UI Actions

- (IBAction)setAspectFitMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeAspectFit;
}

- (IBAction)setFillMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeFill;
}

- (IBAction)machineRestart:(id)sender
{
    dispatch_sync(_machine.emulationQueue, ^{
        [self.view.window setTitle:@"SpectREM"];
        [_machine reset];
    });
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"sna", @"z80"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK)
            {
                [self loadFileWithURL:openPanel.URLs[0]];
            }
        }];
    });
}

- (void)loadFileWithURL:(NSURL *)url
{
    [self.view.window setTitle:[NSString stringWithFormat:@"SpectREM - %@", [url.path lastPathComponent]]];
    [_machine loadSnapshotWithPath:url.path];
}

@end
