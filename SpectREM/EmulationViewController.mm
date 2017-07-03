//
//  ViewController.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <IOKit/hid/IOHIDLib.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#import "EmulationViewController.h"
#import "EmulationScene.h"
#import "ConfigViewController.h"
#import "GraphicalMemViewController.h"
#import "CPUViewController.h"
#import "TapeViewController.h"
#import "DisassemblyViewController.h"
#import "MemoryViewController.h"
#import "SaveAccessoryViewController.h"
#import "RomSelectionViewController.h"
#import "EmulationView.h"
#import "Snapshot.h"
#import "ZXTape.h"

#import "ZXSpectrum48.h"
#import "ZXSpectrum128.h"
#import "SmartLink.h"
#import "Z80Core.h"

#import <OpenGL/gl.h>

#pragma mark - Interface

@interface EmulationViewController ()

@property (strong) NSMutableArray *disassemblyArray;
@property (strong) NSMutableDictionary *debugLabels;

@end

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
    
    NSWindowController      *_disassemblyWindowController;
    DisassemblyViewController *_disassemblyViewController;
    
    NSWindowController      *_memoryWindowController;
    MemoryViewController    *_memoryViewController;
    
    SaveAccessoryViewController *_saveAccessoryController;
    NSView                  *_saveAccessoryView;
    
    NSWindowController      *_romSelectionWindowController;
    RomSelectionViewController *_romSelectionViewController;
    
    IOHIDManagerRef         _hidManager;
    NSUserDefaults          *_preferences;
    dispatch_queue_t        _debugTimerQueue;
    dispatch_source_t       _debugTimer;
    dispatch_queue_t        _fastTimerQueue;
    dispatch_source_t       _fastTimer;
    dispatch_queue_t        _serialQueue;
    dispatch_source_t       _serialTimer;
    dispatch_queue_t        _smartlinkQueue;
    
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
        self.configEffectsView.frame.size.height - 10};
    self.configEffectsView.alphaValue = 0;
    self.configScrollView.documentView = _configViewController.view;
    
    // Init the keyboard mapping view
    _keyboardMapWindowController = [_storyBoard instantiateControllerWithIdentifier:@"KeyboardWindow"];
    
    // Setup the tape view view controller;
    _tapeBrowserWindowController = [_storyBoard instantiateControllerWithIdentifier:@"TAPBrowserWindow"];
    _tapeViewController = (TapeViewController *)_tapeBrowserWindowController.contentViewController;
    
    // Setup the debug window
    _disassemblyWindowController = [_storyBoard instantiateControllerWithIdentifier:@"DisassemblyWindow"];
    _disassemblyViewController = (DisassemblyViewController *)_disassemblyWindowController.contentViewController;
    
    //  Setup memory view window
    _memoryWindowController = [_storyBoard instantiateControllerWithIdentifier:@"MemoryWindow"];
    _memoryViewController = (MemoryViewController *)_memoryWindowController.contentViewController;
    
    _saveAccessoryController = [_storyBoard instantiateControllerWithIdentifier:@"SaveAccessoryController"];
    _saveAccessoryView = _saveAccessoryController.view;
    
    _romSelectionWindowController = [_storyBoard instantiateControllerWithIdentifier:@"RomSelectionWindow"];
    _romSelectionViewController = (RomSelectionViewController *)_romSelectionWindowController.contentViewController;
    
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
    [self checkForDefaultROM];
    [self setupMachineBindings];
    [self switchToMachine:_configViewController.currentMachineType];
    [self restoreSession];
}

- (void)restoreSession
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *supportDir = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if (supportDir.count > 0)
    {
        NSURL *supportDirUrl = [[supportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];

        // Load the last session file it if exists
        supportDirUrl = [supportDirUrl URLByAppendingPathComponent:@"session.z80"];
        if ([fileManager fileExistsAtPath:supportDirUrl.path])
        {
            NSLog(@"Restoring session");
            [self loadFileWithURL:supportDirUrl];
        }
        else
        {
            NSLog(@"No session to restore");
        }
    }
}

- (void)viewWillDisappear
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *supportDir = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if (supportDir.count > 0)
    {
        NSURL *supportDirUrl = [[supportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
        
        NSError *error = nil;
        if (![fileManager createDirectoryAtURL:supportDirUrl withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"ERROR: creating support directory.");
            return;
        }
        
        supportDirUrl = [supportDirUrl URLByAppendingPathComponent:@"session.z80"];
        snap sessionSnapshot = [Snapshot createZ80SnapshotFromMachine:_machine];
        NSData *data = [NSData dataWithBytes:sessionSnapshot.data length:sessionSnapshot.length];
        [data writeToURL:supportDirUrl atomically:YES];
    }
}

- (void)checkForDefaultROM
{
    // If any of the default rom keys are missing from preferences then point them to the ROMS that come with SpectREM
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *rom48Path = [(NSURL *)[_preferences URLForKey:cRom48Path] path];
    NSString *rom1280Path = [(NSURL *)[_preferences URLForKey:cRom1280Path] path];
    NSString *rom1281Path = [(NSURL *)[_preferences URLForKey:cRom1281Path] path];

    if (![_preferences stringForKey:cRom48Name] || ![fileManager fileExistsAtPath:rom48Path])
    {
        [_romSelectionViewController reset48kRom];
    }

    if (![_preferences stringForKey:cRom1280Name] || ![fileManager fileExistsAtPath:rom1280Path])
    {
        [_romSelectionViewController reset128kRom0];
    }

    if (![_preferences stringForKey:cRom1281Name] || ![fileManager fileExistsAtPath:rom1281Path])
    {
        [_romSelectionViewController reset128kRom1];
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
    [_machine.smartLink bind:cSerialPort toObject:_configViewController withKeyPath:cSerialPort options:nil];
    [_machine bind:cUseSmartLink toObject:_configViewController withKeyPath:cUseSmartLink options:nil];

    [_machine bind:cSpecDrum toObject:_configViewController withKeyPath:cSpecDrum options:nil];
    [_machine bind:cMultiface1 toObject:_configViewController withKeyPath:cMultiface1 options:nil];
    [_machine bind:cMultiface128 toObject:_configViewController withKeyPath:cMultiface128 options:nil];
    [_machine bind:cMultiface128Lockout toObject:_configViewController withKeyPath:cMultiface128Lockout options:nil];
    [_machine bind:cInstaTAPLoading toObject:_configViewController withKeyPath:cInstaTAPLoading options:nil];
	[_machine bind:cSmartCardEnabled toObject:_configViewController withKeyPath:cSmartCardEnabled options:nil];
	
    [_tapeViewController bind:@"tape" toObject:self withKeyPath:@"zxTape" options:nil];
    [_disassemblyViewController bind:@"machine" toObject:self withKeyPath:@"_machine" options:nil];
    [_cpuViewController bind:@"machine" toObject:self withKeyPath:@"_machine" options:nil];
    [_memoryViewController bind:@"machine" toObject:self withKeyPath:@"_machine" options:nil];
}

- (void)setupLocalObservers
{
    [_configViewController addObserver:self forKeyPath:cCurrentMachineType options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cAccelerationMultiplier options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cAccelerate options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cUseSmartLink options:NSKeyValueObservingOptionNew context:NULL];
    [_configViewController addObserver:self forKeyPath:cSmartCardEnabled options:NSKeyValueObservingOptionNew context:NULL];
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
    [_machine.smartLink unbind:cSerialPort];
    [_machine unbind:cSpecDrum];
    [_machine unbind:cMultiface1];
    [_machine unbind:cMultiface128];
    [_machine unbind:cMultiface128Lockout];
    [_machine unbind:cInstaTAPLoading];
	[_machine unbind:cSmartCardEnabled];
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
            _machine.accelerated = YES;
            dispatch_resume(_fastTimer);
        }
        else
        {
            [self notifyUserWithMessage:NSLocalizedString(@"Acceleration mode off", nil)];
            [_machine.audioCore start];
            _machine.accelerated = NO;
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

    if ([keyPath isEqualToString:cSmartCardEnabled])
    {
        if ([[change valueForKey:NSKeyValueChangeNewKey] boolValue])
        {
            [self notifyUserWithMessage:NSLocalizedString(@"SmartCard Enabled", nil)];
            [_machine enableSmartCard];
        }
        else
        {
            [self notifyUserWithMessage:NSLocalizedString(@"SmartCard Disabled", nil)];
            [_machine disableSmartCard];
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
                      _machine.zxTape = _zxTape;
                      [_machine.audioCore reset];
                      [_machine reset:menuItem.tag];
                  });
}

- (IBAction)NMI:(id)sender
{
    [_machine NMI];
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
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.3;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.configEffectsView.animator setAlphaValue:(self.configEffectsView.alphaValue) ? 0 : 1];
        [self.configEffectsView.animator setFrame:configFrame];
    }  completionHandler:^{
        
    }];
    
}

- (IBAction)openFile:(id)sender
{
    if ([(NSControl *)sender tag] == 1)
    {
        [self loadLastUrl:nil];
        return;
    }
    
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

- (IBAction)saveFile:(id)sender
{    
    NSSavePanel *savePanel = [NSSavePanel new];

    if (_machine->machineInfo.machineType == eZXSpectrum48)
    {
        [[_saveAccessoryController.exportPopup itemAtIndex:cSNA_SNAPSHOT_TYPE] setEnabled:YES];
        savePanel.allowedFileTypes = @[@"z80", @"sna"];
    }
    else
    {
        [[_saveAccessoryController.exportPopup itemAtIndex:cSNA_SNAPSHOT_TYPE] setEnabled:NO];
        [_saveAccessoryController.exportPopup selectItemAtIndex:cZ80_SNAPSHOT_TYPE];
        savePanel.allowedFileTypes = @[@"z80"];
    }
    
    savePanel.accessoryView = _saveAccessoryController.view;
    dispatch_async(dispatch_get_main_queue(), ^{
        [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK)
            {
                snap snapshotData;
                NSURL *url = savePanel.URL;
                
                switch (_saveAccessoryController.exportType) {
                    case cZ80_SNAPSHOT_TYPE:
                        snapshotData = [Snapshot createZ80SnapshotFromMachine:_machine];
                        url = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"z80"];
                        break;
                        
                    case cSNA_SNAPSHOT_TYPE:
                        snapshotData = [Snapshot createSnapshotFromMachine:_machine];
                        url = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"sna"];
                    default:
                        break;
                }
                
                NSData *data = [NSData dataWithBytes:snapshotData.data length:snapshotData.length];
                [data writeToURL:url atomically:YES];
            }
        }];
    });
}

- (void)loadFileWithURL:(NSURL *)url
{
    
    if (_machine.accelerated)
    {
        [_configViewController setValue:@(NO) forKey:cAccelerate];
        [self notifyUserWithMessage:NSLocalizedString(@"Acceleration mode off", nil)];
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
        if (_machine.instaTAPLoading)
        {
            if (_machine->machineInfo.machineType == eZXSpectrum48)
            {
                [_machine.keystrokesBuffer addObject:@(239)];
                [_machine.keystrokesBuffer addObject:@(34)];
                [_machine.keystrokesBuffer addObject:@(34)];
                [_machine.keystrokesBuffer addObject:@(13)];
            }
            else if (_machine->machineInfo.machineType == eZXSpectrum128)
            {
                [_machine.keystrokesBuffer addObject:@(13)];
            }
        }
    }
    else if ([[[url pathExtension] uppercaseString] isEqualToString:@"ROM"])
    {
        if (_machine->machineInfo.machineType != eZXSpectrum48)
        {
            [self switchToMachine:eZXSpectrum48];
            [_preferences setValue:@(eZXSpectrum48) forKey:cCurrentMachineType];
        }
        [_machine loadROMWithPath:url.path];
        [_machine reset:NO];
    }
    
    // Check to see if the loaded file has a Pasmo debug file and if so then load the labels and addresses into the debug dictionary
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *debugURL = [[url URLByDeletingPathExtension] URLByAppendingPathExtension:@"dbg"];
    
    self.debugLabels = [NSMutableDictionary new];

    if ([fileManager fileExistsAtPath:debugURL.path])
    {
        NSString *addresses = [NSString stringWithContentsOfURL:debugURL encoding:NSUTF8StringEncoding error:NULL];
        [addresses enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            long labelPos = [line rangeOfString:@"label"].location;
            if (labelPos != NSNotFound)
            {
                NSString *addr = [line substringToIndex:4];
                NSString *label = [line substringFromIndex:labelPos + 6];
                [self.debugLabels setObject:label forKey:addr];
            }
        }];
    }
    
    [self.view.window setTitle:[NSString stringWithFormat:@"SpectREM - %@", [url.path lastPathComponent]]];
    
    // Don't add the session snapshot to the recent files list
    if (![(NSString *)[url.path lastPathComponent] isEqualToString:@"session.z80"])
    {
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
        [_preferences setURL:url forKey:cLastUrl];
        [_preferences synchronize];
    }
}

- (IBAction)loadLastUrl:(id)sender
{
    if ([_preferences URLForKey:cLastUrl])
    {
        [self loadFileWithURL:[_preferences URLForKey:cLastUrl]];
    }
}

- (IBAction)resetPreferences:(id)sender
{
    [_configViewController resetPreferences];
}

- (void)switchToMachine:(NSInteger)machineType
{
    if (_machine.accelerated)
    {
        [_configViewController setValue:@(NO) forKey:cAccelerate];
        [self notifyUserWithMessage:NSLocalizedString(@"Acceleration mode off", nil)];
    }

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
        float height = (256 * menuItem.tag) + 22;
        float originX = self.view.window.frame.origin.x;
        float originY = self.view.window.frame.origin.y - (height - self.view.window.frame.size.height);
        NSRect windowFrame = CGRectMake(originX, originY, width, height);
        [self.view.window.animator setFrame:windowFrame display:YES animate:NO];
    }
}

- (IBAction)switchHexDecValues:(id)sender
{
    _cpuViewController.decimalFormat = (_cpuViewController.decimalFormat) ? NO : YES;
    _disassemblyViewController.decimalFormat = (_disassemblyViewController.decimalFormat) ? NO : YES;
}

- (IBAction)pause:(id)sender
{
    [_machine resetSound];
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

- (IBAction)showDisassemblyWindow:(id)sender
{
    [_disassemblyWindowController showWindow:nil];
}

- (IBAction)showCPUWindow:(id)sender
{
    [_cpuWindowController showWindow:nil];
}

- (IBAction)showGraphicalMemoryWindow:(id)sender
{
    [_graphicalMemoryWindowController showWindow:nil];
}

- (IBAction)showMemoryWindow:(id)sender
{
    [_memoryWindowController showWindow:nil];
}

- (IBAction)sendToSmartLink:(id)sender
{
    if (!_machine.smartLink.serialPort || !_machine.smartLink)
    {
        NSAlert *alert = [NSAlert new];
        alert.informativeText = @"No SmartLINK port has been selected.";
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode)
         {
         }];
        return;
    }
    
    _machine.useSmartLink = NO;
    
    snap snapShot = [Snapshot createSnapshotFromMachine:_machine];

    [_machine.smartLink sendSnapshot:snapShot.data];
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
    // Reduce the size of the view so that it sits below the title bar of the window. The window is setup to use the entire window contents
    // so that the titlebar doesn't show the contents of the config panel through it. This seems to cause performance issues. So to ensure
    // that the view is not drawn below the titlebar its height is reduced.
    self.view.frame = (CGRect) {0, 0, self.view.window.frame.size.width, self.view.window.frame.size.height - 22};
}

@end

