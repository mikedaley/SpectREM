//
//  RomSelectionView.m
//  SpectREM
//
//  Created by Mike Daley on 27/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "RomSelectionView.h"

@implementation RomSelectionView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if (self.delegate)
    {
        return [self.delegate draggingEntered:sender];
    }
    
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    if (self.delegate)
    {
        return [self.delegate draggingUpdated:sender];
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if (self.delegate)
    {
        return [self.delegate performDragOperation:sender];
    }
    
    return NO;
}

- (BOOL)wantsPeriodicDraggingUpdates
{
    return YES;
}

@end
