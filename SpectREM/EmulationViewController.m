//
//  ViewController.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <IOKit/hid/IOHIDLib.h>

#import "EmulationViewController.h"
#import "EmulationScene.h"
#import "ConfigViewController.h"
#import "CPUViewController.h"
#import "EmulationView.h"

#import "ZXSpectrum48.h"
#import "ZXSpectrum128.h"
#import "ZXSpectrumSE.h"

#pragma mark - Enums

NS_ENUM(NSUInteger, MachineType)
{
    eZXSpectrum48 = 0,
    eZXSpectrum128,
    eZXSpectrumSE
};

#pragma mark - Implementation

@implementation EmulationViewController
{
    ZXSpectrum              *_machine;
    EmulationScene          *_emulationScene;
    ConfigViewController    *_configViewController;
    CPUViewController       *_cpuViewController;
    
    IOHIDManagerRef         _hidManager;
    NSUserDefaults          *preferences;
    dispatch_queue_t        _UITimerQueue;
    dispatch_source_t       _UITimer;
}

- (void)dealloc
{
    NSLog(@"Deallocating EmulationViewController");
    [self removeBindings];
    [_configViewController removeObserver:self forKeyPath:@"currentMachineType"];
    dispatch_source_cancel(_UITimer);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _cpuViewController = [CPUViewController new];

    _configViewController = [ConfigViewController new];
    [self.configEffectsView setFrameOrigin:(NSPoint){-self.configEffectsView.frame.size.width, 0}];
    self.configScrollView.documentView = _configViewController.view;
    
    preferences = [NSUserDefaults standardUserDefaults];
    
    _emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    _emulationScene.scaleMode = [[preferences valueForKey:@"sceneScaleMode"] integerValue];

    // Ensure that the view is the same size as the parent window before presenting the scene. Not
    // doing this causes the view to appear breifly at the size it is defined in the story board.
    self.skView.frame = self.skView.window.frame;
    
    // Present the scene
    [self.skView presentScene:_emulationScene];

    [self setupLocalObservers];
    [self setupMachineBindings];
    [self setupSceneBindings];
    [self switchToMachine:_configViewController.currentMachineType];
    [self setupGamepad];
    [self setupCPUViewTimer];
    
    [_machine start];
}

#pragma mark - CPU View Timer

- (void)setupCPUViewTimer
{
    _UITimerQueue = dispatch_queue_create("UITimerQueue", nil);
    _UITimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _UITimerQueue);
    dispatch_source_set_timer(_UITimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_UITimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _cpuViewController.corePC = _machine.corePC;
        });
    });
    
    dispatch_resume(_UITimer);
}

#pragma mark - Bindings/Observers

- (void)setupSceneBindings
{
    [_emulationScene bind:@"displayCurve" toObject:_configViewController withKeyPath:@"displayCurve" options:nil];
    [_emulationScene bind:@"displaySaturation" toObject:_configViewController withKeyPath:@"displaySaturation" options:nil];
    [_emulationScene bind:@"displayContrast" toObject:_configViewController withKeyPath:@"displayContrast" options:nil];
    [_emulationScene bind:@"displayBrightness" toObject:_configViewController withKeyPath:@"displayBrightness" options:nil];
    [_emulationScene bind:@"displayShowVignette" toObject:_configViewController withKeyPath:@"displayShowVignette" options:nil];
    [_emulationScene bind:@"displayVignetteX" toObject:_configViewController withKeyPath:@"displayVignetteX" options:nil];
    [_emulationScene bind:@"displayVignetteY" toObject:_configViewController withKeyPath:@"displayVignetteY" options:nil];
}

- (void)setupMachineBindings
{
    [_machine bind:@"displayBorderWidth" toObject:_configViewController withKeyPath:@"displayBorderWidth" options:nil];
    [_machine bind:@"soundHighPassFilter" toObject:_configViewController withKeyPath:@"soundHighPassFilter" options:nil];
    [_machine bind:@"soundLowPassFilter" toObject:_configViewController withKeyPath:@"soundLowPassFilter" options:nil];
    [_machine bind:@"soundVolume" toObject:_configViewController withKeyPath:@"soundVolume" options:nil];
    [_machine bind:@"AYChannelA" toObject:_configViewController withKeyPath:@"AYChannelA" options:nil];
    [_machine bind:@"AYChannelB" toObject:_configViewController withKeyPath:@"AYChannelB" options:nil];
    [_machine bind:@"AYChannelC" toObject:_configViewController withKeyPath:@"AYChannelC" options:nil];
    [_machine bind:@"AYChannelABalance" toObject:_configViewController withKeyPath:@"AYChannelABalance" options:nil];
    [_machine bind:@"AYChannelBBalance" toObject:_configViewController withKeyPath:@"AYChannelBBalance" options:nil];
    [_machine bind:@"AYChannelCBalance" toObject:_configViewController withKeyPath:@"AYChannelCBalance" options:nil];
}

- (void)setupLocalObservers
{
    [_configViewController addObserver:self forKeyPath:@"currentMachineType" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeBindings
{
    [_emulationScene unbind:@"displayCurve"];
    [_emulationScene unbind:@"displaySaturation"];
    [_emulationScene unbind:@"displayContrast"];
    [_emulationScene unbind:@"displayCurve"];
    [_emulationScene unbind:@"displayBrightness"];
    [_emulationScene unbind:@"displayVignetteX"];
    [_emulationScene unbind:@"displayVignetteY"];
    
    [_machine unbind:@"displayBorderWidth"];
    [_machine unbind:@"soundHighPassFilter"];
    [_machine unbind:@"soundLowPassFilter"];
    [_machine unbind:@"soundVolume"];
    [_machine unbind:@"AYChannelA"];
    [_machine unbind:@"AYChannelB"];
    [_machine unbind:@"AYChannelC"];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentMachineType"])
    {
        [self switchToMachine:[[change valueForKey:NSKeyValueChangeNewKey] unsignedIntegerValue]];
    }
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

#pragma mark - 
- (void)updateEmulationDisplayTextureWithImage:(SKTexture *)emulationDisplayTexture
{
    _emulationScene.emulationDisplaySprite.texture = emulationDisplayTexture;
}

#pragma mark - UI Actions

- (IBAction)setAspectFitMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeAspectFit;
    [preferences setValue:@(SKSceneScaleModeAspectFit) forKey:@"sceneScaleMode"];
    [preferences synchronize];
}

- (IBAction)setFillMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeFill;
    [preferences setValue:@(SKSceneScaleModeFill) forKey:@"sceneScaleMode"];
    [preferences synchronize];
}

- (IBAction)machineRestart:(id)sender
{
    dispatch_sync(_machine.emulationQueue, ^{
        [self.view.window setTitle:@"SpectREM"];
        [_machine.audioCore reset];
        [_machine reset];
    });
}

- (IBAction)configButtonPressed:(id)sender
{
    NSRect configFrame = self.configEffectsView.frame;
    if (configFrame.origin.x == -configFrame.size.width)
    {
        configFrame.origin.x = 0;
    }
    else
    {
        configFrame.origin.x = -configFrame.size.width;
    }
    [self.configEffectsView.animator setFrame:configFrame];
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
                [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:openPanel.URLs[0]];
            }
        }];
    });
}

- (void)loadFileWithURL:(NSURL *)url
{
    [self.view.window setTitle:[NSString stringWithFormat:@"SpectREM - %@", [url.path lastPathComponent]]];
    [_machine loadSnapshotWithPath:url.path];
}

- (IBAction)resetPreferences:(id)sender
{
    [_configViewController resetPreferences];
}

- (void)switchToMachine:(NSUInteger)machineType
{
    [_machine stop];
    [self removeBindings];
    _machine = nil;
    switch (machineType) {
        default:
        case eZXSpectrum48:
            _machine = [[ZXSpectrum48 alloc] initWithEmulationViewController:self];
            break;
        case eZXSpectrum128:
            _machine = [[ZXSpectrum128 alloc] initWithEmulationViewController:self];
            break;
        case eZXSpectrumSE:
            _machine = [[ZXSpectrumSE alloc] initWithEmulationViewController:self];
            break;
    }
    _emulationScene.keyboardDelegate = _machine;
    [self setupMachineBindings];
    [self setupSceneBindings];
}

- (IBAction)setWindowSize:(id)sender
{
    // Only allow window resizing if not in full screen
    if (([self.view.window styleMask] & NSFullScreenWindowMask) != NSFullScreenWindowMask)
    {
        NSMenuItem *menuItem = (NSMenuItem*)sender;
        float width = 320 * menuItem.tag;
        float height = 256 * menuItem.tag + 22;
        float originX = self.view.window.frame.origin.x;
        float originY = self.view.window.frame.origin.y - (height - self.view.window.frame.size.height);
        NSRect windowFrame = CGRectMake(originX, originY, width, height);
        [self.view.window.animator setFrame:windowFrame display:YES animate:YES];
    }
}

#pragma mark - USB Controllers

void gamepadWasAdded(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    NSLog(@"USB Device Found: %@", IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey)));
}

void gamepadWasRemoved(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
    NSLog(@"USB Device Unplugged: %@", IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductKey)));
}

void gamepadAction(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value) {
    IOHIDElementRef element = IOHIDValueGetElement(value);
    NSLog(@"Element: %@", element);
    int elementValue = (int)IOHIDValueGetIntegerValue(value);
    NSLog(@"Element value: %i", elementValue);
}

-(void) setupGamepad {
    _hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    NSMutableDictionary* criterion = [[NSMutableDictionary alloc] init];
    [criterion setObject: [NSNumber numberWithInt: kHIDPage_GenericDesktop] forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
    //    [criterion setObject: [NSNumber numberWithInt: kHIDUsage_GD_GamePad] forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
    IOHIDManagerSetDeviceMatching(_hidManager, (CFDictionaryRef)criterion);
    IOHIDManagerRegisterDeviceMatchingCallback(_hidManager, gamepadWasAdded, (void*)self);
    IOHIDManagerRegisterDeviceRemovalCallback(_hidManager, gamepadWasRemoved, (void*)self);
    IOHIDManagerScheduleWithRunLoop(_hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

    // Uncomment line below to get device input details
//    IOReturn tIOReturn = IOHIDManagerOpen(_hidManager, kIOHIDOptionsTypeNone);
    IOHIDManagerRegisterInputValueCallback(_hidManager, gamepadAction, (void*)self);
}

@end

