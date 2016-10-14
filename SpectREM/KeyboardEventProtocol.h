//
//  ViewEventProtocol.h
//  ZXRetroEmu
//
//  Created by Mike Daley on 02/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardEventProtocol <NSObject>

@required

- (void)keyDown:(NSEvent *)theEvent;
- (void)keyUp:(NSEvent *)theEvent;
- (void)flagsChanged:(NSEvent *)theEvent;

@end
