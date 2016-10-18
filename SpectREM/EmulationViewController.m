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
#import "ConfigViewController.h"

#pragma mark - Private Interface

@interface EmulationViewController ()

@end

#pragma mark - Implementation

@implementation EmulationViewController
{
    EmulationScene *_emulationScene;
    ZXSpectrum48 *_machine;
    ConfigViewController *_configViewController;
    NSPopover *_configPopover;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    _emulationScene.scaleMode = SKSceneScaleModeAspectFit;
    
    _configViewController = [ConfigViewController new];
    _configPopover = [NSPopover new];
    _configPopover.contentViewController = _configViewController;
    _configPopover.behavior = NSPopoverBehaviorTransient;
    _configViewController.emulationViewController = self;
    
    // Present the scene
    [self.skView presentScene:_emulationScene];
    
    //Setup the machine to be emulated
    _machine = [[ZXSpectrum48 alloc] initWithEmulationViewController:self];
    _emulationScene.keyboardDelegate = _machine;
    [_machine start];
}

#pragma mark - View events

- (void)viewDidLayout
{
    [_emulationScene sceneViewSizeChanged:self.view.frame.size];
}

#pragma mark - Keyboard events

- (void)flagsChanged:(NSEvent *)event
{
    [_machine flagsChanged:event];
}

- (void)updateEmulationDisplayTextureWithImage:(SKTexture *)emulationDisplayTexture
{
    _emulationScene.emulationDisplaySprite.texture = emulationDisplayTexture;
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

- (void)curveSliderChanged:(id)sender
{
    [_emulationScene curveSliderChanged:[(NSSlider *)sender floatValue]];
}

- (void)borderSliderChanged:(id)sender
{
    _machine.borderWidth = [(NSSlider *)sender floatValue];
}

- (IBAction)configButtonPressed:(id)sender
{
    CGRect rect = [(NSButton *)sender frame];
    [_configPopover showRelativeToRect:rect ofView:self.view preferredEdge:NSRectEdgeMaxY];
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
