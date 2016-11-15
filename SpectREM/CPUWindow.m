//
//  CPUWindow.m
//  SpectREM
//
//  Created by Mike Daley on 15/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "CPUWindow.h"

@implementation CPUWindow

-(BOOL)isExcludedFromWindowsMenu
{
    return YES;
}

- (BOOL)isMovableByWindowBackground
{
    return YES;
}

@end
