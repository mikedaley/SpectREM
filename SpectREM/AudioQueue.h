//
//  AudioQueue.h
//  ZXRetroEmulator
//
//  Created by Mike Daley on 15/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

/**
 This class deals with moving data from its internal buffer to the buffer passed in when writing and reading.
 This allows the amount of the buffer being used to be tracked and this info is then used by the AudioCore to
 decide when a new frame should be generated on the associated machine.
*/

#import <Foundation/Foundation.h>

@interface AudioQueue : NSObject

// Provides a new instance of this class
+ (AudioQueue *)queue;

// Write the supplied number of bytes into the queues buffer from the supplied buffer pointer
- (int)write:(int16_t *)buffer count:(uint)count;

// Read the supplied number of bytes from the queues buffer into the supplied buffer pointer
- (int)read:(int16_t *)buffer count:(uint)count;

// Return the number of used samples in the buffer
- (int)used;

@end
