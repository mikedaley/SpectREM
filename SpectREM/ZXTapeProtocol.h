//
//  ZXTapeProtocol.h
//  SpectREM
//
//  Created by Mike Daley on 06/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZXTapeProtocol <NSObject>

- (void)tapeBytesProcessed:(NSInteger)bytes;
- (void)blocksChanged;

@end
