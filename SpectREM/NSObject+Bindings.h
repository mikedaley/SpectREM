//
//  NSViewController+Bindings.h
//  SpectREM
//
//  Created by Mike Daley on 19/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject_Bindings : NSObject

// Used to propogate changes to a property to objects that are bound to that property
-(void)propagateValue:(id)value forBinding:(NSString*)binding;

@end
