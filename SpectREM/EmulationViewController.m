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
#import "GraphicalMemViewController.h"
#import "CPUViewController.h"
#import "InfoViewController.h"
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
    InfoViewController      *_infoViewController;
    NSStoryboard            *_storyBoard;
    
    NSWindowController      *_graphicalMemoryWindowController;
    GraphicalMemViewController *_graphicalMemViewController;
    
    NSWindowController      *_cpuWindowController;
    CPUViewController       *_cpuViewController;
    
    IOHIDManagerRef         _hidManager;
    NSUserDefaults          *preferences;
    dispatch_queue_t        _debugTimerQueue;
    dispatch_source_t       _debugTimer;
}

- (void)dealloc
{
    NSLog(@"Deallocating EmulationViewController");
    [self removeBindings];
    [_configViewController removeObserver:self forKeyPath:@"currentMachineType"];
    if (_debugTimer)
    {
        dispatch_source_cancel(_debugTimer);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    _storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Setup debug window and view controllers
    _graphicalMemoryWindowController = [_storyBoard instantiateControllerWithIdentifier:@"GraphicalMemoryView"];
    _graphicalMemViewController = (GraphicalMemViewController *)_graphicalMemoryWindowController.contentViewController;
    
    _cpuWindowController = [_storyBoard instantiateControllerWithIdentifier:@"CPUView"];
    _cpuViewController = (CPUViewController *)_cpuWindowController.contentViewController;
    
    _configViewController = [_storyBoard instantiateControllerWithIdentifier:@"ConfigViewController"];
    self.configEffectsView.frame = (CGRect){-self.configEffectsView.frame.size.width, 0, 236, 256};
    self.configScrollView.documentView = _configViewController.view;
    
    _infoViewController = [_storyBoard instantiateControllerWithIdentifier:@"InfoViewController"];
    [_infoViewController.view setFrameOrigin:(NSPoint){10,10}];
    [self.skView addSubview:_infoViewController.view];
    
    preferences = [NSUserDefaults standardUserDefaults];

    _emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    _emulationScene.scaleMode = [[preferences valueForKey:@"sceneScaleMode"] integerValue];

    [self.skView setFrameSize:self.skView.window.frame.size];

    // Present the scene
    [self.skView presentScene:_emulationScene];

    [self setupLocalObservers];
    [self setupMachineBindings];
    [self setupSceneBindings];
    [self setupNotificationCenterObservers];
    [self setupGamepad];
    [self setupDebugTimer];
    
    [self switchToMachine:_configViewController.currentMachineType];
}

#pragma mark - CPU View Timer

- (void)setupDebugTimer
{
    _debugTimerQueue = dispatch_queue_create("DebugTimerQueue", nil);
    _debugTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _debugTimerQueue);
    dispatch_source_set_timer(_debugTimer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_debugTimer, ^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (_machine)
            {
                if ([_graphicalMemoryWindowController.window isVisible])
                {
                    [_graphicalMemViewController updateViewWithMachine:(__bridge void*)_machine];
                }
                if ([_cpuWindowController.window isVisible])
                {
                    [_cpuViewController updateViewWithMachine:(__bridge void *)_machine];
                }
            }
        });
    });
    
    dispatch_resume(_debugTimer);
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

- (void)setupNotificationCenterObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResize:) name:NSWindowDidResizeNotification object:nil];
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
    [_machine unbind:@"AYChannelABalance"];
    [_machine unbind:@"AYChannelBBalance"];
    [_machine unbind:@"AYChannelCBalance"];
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
- (void)updateEmulationDisplayWithTexture:(SKTexture *)emulationDisplayTexture
{
    emulationDisplayTexture.filteringMode = SKTextureFilteringNearest;
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
    dispatch_sync(_machine.emulationQueue, ^
    {
        [self.view.window setTitle:@"SpectREM"];
        [_machine.audioCore reset];
        [_machine reset];
    });
}

- (IBAction)configButtonPressed:(id)sender
{
    NSRect configFrame = self.configEffectsView.frame;
    configFrame.origin.y = 0;
    if (configFrame.origin.x == 0 - configFrame.size.width)
    {
        configFrame.origin.x = 0;
        configFrame.origin.y = 0;
    }
    else
    {
        configFrame.origin.x = 0 - configFrame.size.width;
        configFrame.origin.y = 0;
    }
    [self.configEffectsView.animator setFrame:configFrame];
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"SNA", @"Z80"];
    
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
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
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
    switch (machineType) {
        default:
        case eZXSpectrum48:
            _machine = [[ZXSpectrum48 alloc] initWithEmulationViewController:self machineInfo:machines[0]];
            break;
        case eZXSpectrum128:
            _machine = [[ZXSpectrum128 alloc] initWithEmulationViewController:self machineInfo:machines[1]];
            break;
        case eZXSpectrumSE:
            _machine = [[ZXSpectrumSE alloc] initWithEmulationViewController:self machineInfo:machines[2]];
            break;
    }
    _emulationScene.keyboardDelegate = _machine;
    [self setupMachineBindings];
    [self setupSceneBindings];
    
    _infoViewController.text = _machine.machineName;
    [_infoViewController displayMessage];
    
    [_machine start];
}

- (IBAction)switchMachine:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    preferences = [NSUserDefaults standardUserDefaults];
    [preferences setValue:@(menuItem.tag) forKey:@"currentMachineType"];
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
        [self.view.window.animator setFrame:windowFrame display:YES animate:NO];
    }
}

- (IBAction)showGraphicalMemoryWindow:(id)sender
{
    [self.view.window addChildWindow:_graphicalMemoryWindowController.window ordered:NSWindowAbove];
    [_graphicalMemViewController updateViewWithMachine:(__bridge void*)_machine];
//    [_graphicalMemoryWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)showCPUWindow:(id)sender
{
    [self.view.window addChildWindow:_cpuWindowController.window ordered:NSWindowAbove];
    [_cpuViewController updateViewWithMachine:(__bridge void*)_machine];
//    [_cpuWindowController.window orderFront:nil];
//    [_cpuWindowController.window setLevel:NSPopUpMenuWindowLevel];
}

- (IBAction)switchHexDecValues:(id)sender
{
    _cpuViewController.decimalFormat = (_cpuViewController.decimalFormat) ? NO : YES;
}

- (IBAction)pause:(id)sender
{
    [_machine.audioCore stop];
}

- (IBAction)start:(id)sender
{
    [_machine.audioCore start];
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

#pragma mark - Window Resize

- (void)windowResize:(NSNotification *)notification
{
    float xx = (self.view.frame.size.width - _infoViewController.view.frame.size.width) / 2;
    float yy = (self.view.frame.size.height - _infoViewController.view.frame.size.height) - 10;
    [_infoViewController.view setFrameOrigin:(NSPoint){xx, yy}];
}

@end

