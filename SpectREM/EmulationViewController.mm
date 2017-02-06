//
//  ViewController.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

//#include "asio.hpp"

#import <IOKit/hid/IOHIDLib.h>
#import <Foundation/Foundation.h>

#import "EmulationViewController.h"
#import "EmulationScene.h"
#import "ConfigViewController.h"
#import "GraphicalMemViewController.h"
#import "CPUViewController.h"
#import "TapeViewController.h"
#import "EmulationView.h"
#import "Snapshot.h"
#import "ZXTape.h"

#import "ZXSpectrum48.h"
#import "ZXSpectrum128.h"
#import "ZXSpectrumSE.h"
#import "SerialCore.h"
#import "Z80Core.h"

#import <OpenGL/gl.h>

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
    ConfigViewController    *_configViewController;
    NSStoryboard            *_storyBoard;
    
    NSWindowController      *_graphicalMemoryWindowController;
    GraphicalMemViewController *_graphicalMemViewController;
    
    NSWindowController      *_cpuWindowController;
    CPUViewController       *_cpuViewController;
    
    NSWindowController      *_keyboardMapWindowController;
    
    NSWindowController      *_tapeBrowserWindowController;
    TapeViewController      *_tapeViewController;
    
    IOHIDManagerRef         _hidManager;
    NSUserDefaults          *_preferences;
    dispatch_queue_t        _debugTimerQueue;
    dispatch_source_t       _debugTimer;
    dispatch_queue_t        _fastTimerQueue;
    dispatch_source_t       _fastTimer;
    
    dispatch_queue_t        _serialQueue;
    dispatch_source_t       _serialTimer;
    
    ZXTape                  *_zxTape;
    
    SKTexture               *_backingTexture;
}

- (void)dealloc
{
    NSLog(@"Deallocating EmulationViewController");
    [self removeBindings];
    [_configViewController removeObserver:self forKeyPath:cCurrentMachineType];
    
    if (_debugTimer)
    {
        dispatch_source_cancel(_debugTimer);
    }
    
    if (_fastTimer)
    {
        dispatch_source_cancel(_fastTimer);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _preferences = [NSUserDefaults standardUserDefaults];

    _storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Setup debug window and view controllers
    _graphicalMemoryWindowController = [_storyBoard instantiateControllerWithIdentifier:@"GraphicalMemoryView"];
    _graphicalMemViewController = (GraphicalMemViewController *)_graphicalMemoryWindowController.contentViewController;
    
    _cpuWindowController = [_storyBoard instantiateControllerWithIdentifier:@"CPUView"];
    _cpuViewController = (CPUViewController *)_cpuWindowController.contentViewController;
    
    // Setup the config view controller used for the config panel on the right. This initially places the view off the
    // left edge of the window and drops the configViewController view into the config scroll view.
    _configViewController = [_storyBoard instantiateControllerWithIdentifier:@"ConfigViewController"];
    self.configEffectsView.frame = (CGRect){-self.configEffectsView.frame.size.width,
        0,
        self.configEffectsView.frame.size.width,
        self.configEffectsView.frame.size.height};
    self.configScrollView.documentView = _configViewController.view;
    
    // Init the keyboard mapping view
    _keyboardMapWindowController = [_storyBoard instantiateControllerWithIdentifier:@"KeyboardWindow"];
    
    // Setup the tape view view controller;
    _tapeBrowserWindowController = [_storyBoard instantiateControllerWithIdentifier:@"TAPBrowserWindow"];
    _tapeViewController = (TapeViewController *)_tapeBrowserWindowController.contentViewController;
    
    // Setup the Sprite Kit emulation scene
    self.emulationScene = (EmulationScene *)[SKScene nodeWithFileNamed:@"EmulationScene"];
    self.emulationScene.scaleMode = (SKSceneScaleMode)[[_preferences valueForKey:cSceneScaleMode] integerValue];
    [self.skView setFrameSize:self.skView.window.frame.size];
    [self.skView presentScene:_emulationScene];

    // Create an instance of the ZXTape controller
    _zxTape = [ZXTape new];
    _zxTape.delegate = _tapeViewController;

    [self setupLocalObservers];
    [self setupSceneBindings];
    [self setupNotificationCenterObservers];
    [self setupGamepad];
    [self setupTimers];
    
    // Switch to the last machine saved in preferences
    [self switchToMachine:_configViewController.currentMachineType];

    [self setupMachineBindings];
    
    // Disassemble ROM into an array of strings
    NSMutableArray *disassembly = [NSMutableArray new];
    
    int pc = 0;
    CZ80Core *core = (CZ80Core *)[_machine getCore];
    while (pc < 16384)
    {
        char opcode[128];
        int length = core->Debug_Disassemble(opcode, 128, pc, NULL);
        [disassembly addObject:[NSString stringWithCString:opcode encoding:NSUTF8StringEncoding]];
        pc += length;
    }
}

#pragma mark - CPU View Timer

- (void)setupTimers
{
    _debugTimerQueue = dispatch_queue_create("DebugTimerQueue", nil);
    _debugTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _debugTimerQueue);
    dispatch_source_set_timer(_debugTimer, DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_debugTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
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
    
    _fastTimerQueue = dispatch_queue_create("FastTimerQueue", nil);
    _fastTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _fastTimerQueue);
    dispatch_source_set_timer(_fastTimer, DISPATCH_TIME_NOW, (1.0 / (50.0 * 2)) * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_fastTimer, ^{
        [_machine doFrame];
    });
}

#pragma mark - Bindings/Observers

- (void)setupSceneBindings
{
    [_emulationScene bind:cDisplayCurve toObject:_configViewController withKeyPath:cDisplayCurve options:nil];
    [_emulationScene bind:cDisplaySaturation toObject:_configViewController withKeyPath:cDisplaySaturation options:nil];
    [_emulationScene bind:cDisplayContrast toObject:_configViewController withKeyPath:cDisplayContrast options:nil];
    [_emulationScene bind:cDisplayBrightness toObject:_configViewController withKeyPath:cDisplayBrightness options:nil];
    [_emulationScene bind:cDisplayShowVignette toObject:_configViewController withKeyPath:cDisplayShowVignette options:nil];
    [_emulationScene bind:cDisplayVignetteX toObject:_configViewController withKeyPath:cDisplayVignetteX options:nil];
    [_emulationScene bind:cDisplayVignetteY toObject:_configViewController withKeyPath:cDisplayVignetteY options:nil];
    [_emulationScene bind:cDisplayScanLine toObject:_configViewController withKeyPath:cDisplayScanLine options:nil];
    [_emulationScene bind:cDisplayRGBOffset toObject:_configViewController withKeyPath:cDisplayRGBOffset options:nil];
    [_emulationScene bind:cDisplayHorizOffset toObject:_configViewController withKeyPath:cDisplayHorizOffset options:nil];
    [_emulationScene bind:cDisplayVertJump toObject:_configViewController withKeyPath:cDisplayVertJump options:nil];
    [_emulationScene bind:cDisplayVertRoll toObject:_configViewController withKeyPath:cDisplayVertRoll options:nil];
    [_emulationScene bind:cDisplayStatic toObject:_configViewController withKeyPath:cDisplayStatic options:nil];
    [_emulationScene bind:cDisplayShowReflection toObject:_configViewController withKeyPath:cDisplayShowReflection options:nil];

}

- (void)setupMachineBindings
{
    [_machine bind:cSoundHighPassFilter toObject:_configViewController withKeyPath:cSoundHighPassFilter options:nil];
    [_machine bind:cSoundLowPassFilter toObject:_configViewController withKeyPath:cSoundLowPassFilter options:nil];
    [_machine bind:cSoundVolume toObject:_configViewController withKeyPath:cSoundVolume options:nil];
    [_machine bind:cAYChannelA toObject:_configViewController withKeyPath:cAYChannelA options:nil];
    [_machine bind:cAYChannelB toObject:_configViewController withKeyPath:cAYChannelB options:nil];
    [_machine bind:cAYChannelC toObject:_configViewController withKeyPath:cAYChannelC options:nil];
    [_machine bind:cAYChannelABalance toObject:_configViewController withKeyPath:cAYChannelABalance options:nil];
    [_machine bind:cAYChannelBBalance toObject:_configViewController withKeyPath:cAYChannelBBalance options:nil];
    [_machine bind:cAYChannelCBalance toObject:_configViewController withKeyPath:cAYChannelCBalance options:nil];
    [_machine bind:cUseAYOn48k toObject:_configViewController withKeyPath:cUseAYOn48k options:nil];
    [_machine.serialCore bind:cSerialPort toObject:_configViewController withKeyPath:cSerialPort options:nil];
    [_machine bind:cUseSmartLink toObject:_configViewController withKeyPath:cUseSmartLink options:nil];
    
    [_tapeViewController bind:@"tape" toObject:self withKeyPath:@"zxTape" options:nil];
}

- (void)setupLocalObservers
{
    [_configViewController addObserver:self forKeyPath:cCurrentMachineType options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cAccelerationMultiplier options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cAccelerate options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cUseSmartLink options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setupNotificationCenterObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResize:) name:NSWindowDidResizeNotification object:nil];
}

- (void)removeBindings
{
    [_emulationScene unbind:cDisplayCurve];
    [_emulationScene unbind:cDisplayBrightness];
    [_emulationScene unbind:cDisplayContrast];
    [_emulationScene unbind:cDisplayCurve];
    [_emulationScene unbind:cDisplayShowVignette];
    [_emulationScene unbind:cDisplayVignetteX];
    [_emulationScene unbind:cDisplayVignetteY];
    [_emulationScene unbind:cDisplayScanLine];
    [_emulationScene unbind:cDisplayRGBOffset];
    [_emulationScene unbind:cDisplayHorizOffset];
    [_emulationScene unbind:cDisplayVertJump];
    [_emulationScene unbind:cDisplayVertRoll];
    [_emulationScene unbind:cDisplayStatic];
    [_emulationScene unbind:cDisplayShowReflection];
    
    [_machine unbind:cSoundHighPassFilter];
    [_machine unbind:cSoundLowPassFilter];
    [_machine unbind:cSoundVolume];
    [_machine unbind:cAYChannelA];
    [_machine unbind:cAYChannelB];
    [_machine unbind:cAYChannelC];
    [_machine unbind:cAYChannelABalance];
    [_machine unbind:cAYChannelBBalance];
    [_machine unbind:cAYChannelCBalance];
    [_machine unbind:cUseAYOn48k];
    [_machine unbind:cUseSmartLink];
    [_machine.serialCore unbind:cSerialPort];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:cCurrentMachineType])
    {
        [self switchToMachine:[[change valueForKey:NSKeyValueChangeNewKey] unsignedIntegerValue]];
    }

    if ([keyPath isEqualToString:cAccelerationMultiplier])
    {
        dispatch_source_set_timer(_fastTimer, DISPATCH_TIME_NOW, (1.0 / (50.08 * [[change valueForKey:NSKeyValueChangeNewKey] doubleValue])) * NSEC_PER_SEC, 0);
    }

    if ([keyPath isEqualToString:cAccelerate])
    {
        if (_configViewController.accelerate)
        {
            [self notifyUserWithMessage:NSLocalizedString(@"Acceleration mode on", nil)];
            [_machine.audioCore stop];
            dispatch_resume(_fastTimer);
        }
        else
        {
            [self notifyUserWithMessage:NSLocalizedString(@"Acceleration mode off", nil)];
            [_machine.audioCore start];
            dispatch_suspend(_fastTimer);
        }
    }

    if ([keyPath isEqualToString:cUseSmartLink])
    {
        if ([[change valueForKey:NSKeyValueChangeNewKey] boolValue])
        {
            [self notifyUserWithMessage:NSLocalizedString(@"SmartLINK Enabled", nil)];
        }
        else
        {
            [self notifyUserWithMessage:NSLocalizedString(@"SmartLINK Disabled", nil)];
        }
    }
}

#pragma mark - View events

- (void)viewDidLayout
{
    [self.emulationScene sceneViewSizeChanged:self.view.frame.size];
}

#pragma mark - Keyboard events

- (void)flagsChanged:(NSEvent *)event
{
    [_machine flagsChanged:event];
}

#pragma mark - Emulation View Update

- (void)updateEmulationViewWithPixelBuffer:(unsigned char *)pixelBuffer length:(CFIndex)length size:(CGSize)size
{
    CFDataRef dataRef = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pixelBuffer, length, kCFAllocatorNull);
    _backingTexture = [SKTexture textureWithData:(__bridge NSData *)dataRef
                                                      size:size
                                                   flipped:YES];
    CFRelease(dataRef);
    
    _backingTexture.filteringMode = SKTextureFilteringNearest;
    self.emulationScene.emulationBackingSprite.texture = _backingTexture;
    self.emulationScene.emulationBackingSprite.size = (CGSize){size.width  * (floorf(self.view.frame.size.width / size.width)),
        size.height * (floorf(self.view.frame.size.width / size.height))};

    // Use the configurable border width to work out the rect that should be extraced from the texture
    CGRect textureRect = (CGRect){0, 0, 1, 1};
    float borderWidth = 32 - _configViewController.displayBorderWidth;
    float emuHScale = 1.0 / size.width;
    float emuVScale = 1.0 / size.height;
    
    textureRect = (CGRect){
        borderWidth * emuHScale,
        borderWidth * emuVScale,
        1.0 - (borderWidth * 2.0 * emuHScale),
        1.0 - (borderWidth * 2.0 * emuVScale)
    };
    
    _backingTexture = [SKTexture textureWithRect:textureRect
                                       inTexture:[self.skView textureFromNode:self.emulationScene.emulationBackingSprite]];
    self.emulationScene.emulationDisplaySprite.texture = _backingTexture;
}

#pragma mark - UI Actions

- (IBAction)setAspectFitMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeAspectFit;
    [_preferences setValue:@(SKSceneScaleModeAspectFit) forKey:cSceneScaleMode];
    [_preferences synchronize];
}

- (IBAction)setFillMode:(id)sender
{
    _emulationScene.scaleMode = SKSceneScaleModeFill;
    [_preferences setValue:@(SKSceneScaleModeFill) forKey:cSceneScaleMode];
    [_preferences synchronize];
}

- (IBAction)machineRestart:(id)sender
{
    dispatch_sync(_machine.emulationQueue, ^
                  {
                      NSMenuItem *menuItem = (NSMenuItem *)sender;
                      [self.view.window setTitle:@"SpectREM"];
                      [_zxTape reset];
                      _machine.zxTape = _zxTape;
                      [_machine.audioCore reset];
                      [_machine reset:menuItem.tag];
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
    openPanel.allowedFileTypes = @[@"SNA", @"Z80", @"TAP", @"ROM"];
    
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
    
    if (_machine.accelerated)
    {
        _machine.accelerated = NO;
        dispatch_suspend(_fastTimer);
        [_machine.audioCore start];
    }
    
    if ([[[url pathExtension] uppercaseString] isEqualToString:@"Z80"] ||
        [[[url pathExtension] uppercaseString] isEqualToString:@"SNA"])
    {
        // Check to see if the snapshot being loaded is compatible with the current machine and if not then switch
        // to the machine needed for the snapshot
        int machineType = [Snapshot machineNeededForZ80SnapshotWithPath:url.path];
        if (machineType != _machine->machineInfo.machineType)
        {
            // Storing the machine type in _preferences triggers an observer which runs the switchToMachine method
            _preferences = [NSUserDefaults standardUserDefaults];
            [_preferences setValue:@(machineType) forKey:cCurrentMachineType];
        }
        [_machine loadSnapshotWithPath:url.path];
    }
    else if ([[[url pathExtension] uppercaseString] isEqualToString:@"TAP"])
    {
        [_zxTape openTapeWithURL:url];
    }
    else if ([[[url pathExtension] uppercaseString] isEqualToString:@"ROM"])
    {
        if (_machine->machineInfo.machineType != eZXSpectrum48)
        {
            [self switchToMachine:eZXSpectrum48];
            _preferences = [NSUserDefaults standardUserDefaults];
            [_preferences setValue:@(eZXSpectrum48) forKey:cCurrentMachineType];
        }
        [_machine loadROMWithPath:url.path];
        [_machine reset:NO];
    }
    
    [self.view.window setTitle:[NSString stringWithFormat:@"SpectREM - %@", [url.path lastPathComponent]]];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
}

- (IBAction)resetPreferences:(id)sender
{
    [_configViewController resetPreferences];
}

- (void)switchToMachine:(NSInteger)machineType
{
    [_machine stop];
    if (_machine.accelerated)
    {
        dispatch_suspend(_fastTimer);
    }
    
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
    _machine.zxTape = _zxTape;
    _emulationScene.keyboardDelegate = _machine;
    [self setupMachineBindings];
    [self setupSceneBindings];
    
    [self notifyUserWithMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ Loaded", nil), _machine.machineName]];
    
    [_machine start];
}

- (IBAction)switchMachine:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    _preferences = [NSUserDefaults standardUserDefaults];
    [_preferences setValue:@(menuItem.tag) forKey:cCurrentMachineType];
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

- (IBAction)accelerate:(id)sender
{
    _configViewController.accelerate = (_configViewController.accelerate) ? NO : YES;
}

- (IBAction)playTape:(id)sender
{
    if (![_zxTape isTapeLoaded])
    {
        [self notifyUserWithMessage:NSLocalizedString(@"No tape loaded!", nil)];
        return;
    }
    [_zxTape play];
    [self notifyUserWithMessage:NSLocalizedString(@"Tape Playing", nil)];
}

- (IBAction)saveTape:(id)sender
{

}

- (IBAction)stopTape:(id)sender
{
    [_zxTape stop];
    [self notifyUserWithMessage:NSLocalizedString(@"Tape Stopped", nil)];
}

- (IBAction)rewindTape:(id)sender
{
    [_zxTape rewind];
    [self notifyUserWithMessage:NSLocalizedString(@"Tape Rewound", nil)];
}

- (IBAction)ejectTape:(id)sender
{
    [_zxTape eject];
    [self.view.window setTitle:@"SpectREM"];
    [self notifyUserWithMessage:NSLocalizedString(@"Tape Ejected", nil)];
}

- (IBAction)showKeyboardMapWindow:(id)sender
{
    [self.view.window addChildWindow:_keyboardMapWindowController.window ordered:NSWindowAbove];
}

- (IBAction)tapeBrowser:(id)sender
{
    [_tapeBrowserWindowController showWindow:nil];
}

#pragma mark - User Notifications

- (void)notifyUserWithMessage:(NSString *)message
{
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSUserNotification *userNote = [[NSUserNotification alloc] init];
    userNote.title = message;
    userNote.soundName = nil;
    [unc deliverNotification:userNote];
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

}

@end

