//
//  CALayer+Actions.m
//  SpectREM
//
//  Created by Mike Daley on 26/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "CALayer+Actions.h"

@implementation CALayer (Actions)

- (void)clearActions
{
    NSDictionary *actions = @{ kCATransition : [NSNull null],
                               kCAOnOrderIn : [NSNull null],
                               kCAOnOrderOut : [NSNull null],
                               @"bounds" : [NSNull null],
                               @"position" : [NSNull null],
                               @"frame" : [NSNull null],
                               @"contents" : [NSNull null],
                               @"transform" : [NSNull null],
                               @"sublayers" : [NSNull null],
                               @"anchorPoint" : [NSNull null],
                               @"backgroundColor" : [NSNull null]
                               };
    
    [self setActions:actions];
}

@end
