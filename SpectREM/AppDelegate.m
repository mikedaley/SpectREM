//
//  AppDelegate.m
//  SpectREM
//
//  Created by Mike Daley on 14/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "EmulationViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    NSWindow *window = [[NSApplication sharedApplication] mainWindow];
    EmulationViewController *emulationViewController = (EmulationViewController *)[window contentViewController];
    [emulationViewController loadFileWithURL:[NSURL fileURLWithPath:filename]];
    return YES;
}

@end
