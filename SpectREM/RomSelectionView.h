//
//  RomSelectionView.h
//  SpectREM
//
//  Created by Mike Daley on 27/06/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RomSelectionView : NSImageView <NSDraggingDestination>

@property (assign) id delegate;

@end
