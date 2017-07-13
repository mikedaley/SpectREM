//
//  EmulationView.m
//  SpectREM
//
//  Created by Mike Daley on 21/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "EmulationView.h"
#import "EmulationViewController.h"

@implementation EmulationView
{
    NSTrackingArea *_trackingArea;
    NSWindowController *_windowController;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {

    }
    
    return self;
}

#pragma mark - Drag/Drop

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pBoard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pBoard = [sender draggingPasteboard];
    
    if ([[pBoard types] containsObject:NSFilenamesPboardType])
    {
        if (sourceDragMask * NSDragOperationCopy)
        {
            NSURL *fileURL = [NSURL URLFromPasteboard:pBoard];
            if ([[fileURL.pathExtension uppercaseString] isEqualToString:@"Z80"] ||
                [[fileURL.pathExtension uppercaseString]isEqualToString:@"SNA"] ||
                [[fileURL.pathExtension uppercaseString]isEqualToString:@"TAP"] ||
                [[fileURL.pathExtension uppercaseString]isEqualToString:@"ROM"]
                )
            {
                return NSDragOperationCopy;
            }
            else
            {
                return NSDragOperationNone;
            }
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pBoard = [sender draggingPasteboard];
    if ([[pBoard types] containsObject:NSURLPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pBoard];
        if ([[fileURL.pathExtension uppercaseString] isEqualToString:@"Z80"] ||
            [[fileURL.pathExtension uppercaseString] isEqualToString:@"SNA"] ||
            [[fileURL.pathExtension uppercaseString]isEqualToString:@"TAP"] ||
            [[fileURL.pathExtension uppercaseString]isEqualToString:@"ROM"]
            )
        {
            EmulationViewController *emulationViewController = (EmulationViewController *)[self.window contentViewController];
            [emulationViewController loadFileWithURL:fileURL];
            return YES;
        }
    }
    return NO;
}

@end
