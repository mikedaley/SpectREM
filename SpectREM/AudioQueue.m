//
//  AudioQueue.m
//  ZXRetroEmulator
//
//  Created by Mike Daley on 15/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "AudioQueue.h"

#define kExponent 18
#define kMask (_capacity - 1)
#define kUsed ((_written - _read) & ((1 << kExponent) - 1))
#define kSpace (_capacity - 1 - kUsed)
#define kSize (_capacity - 1)

@interface AudioQueue ()

@property (assign) int16_t *queueBuffer;
@property (assign) int read;
@property (assign) int written;
@property (assign) int capacity;

- (void)setup;

@end

@implementation AudioQueue

- (void)dealloc
{
    free(_queueBuffer);
}

+ (AudioQueue *)queue
{
    AudioQueue *audioQueue = [AudioQueue new];
    [audioQueue setup];
    return audioQueue;
}

- (void)setup
{
    _capacity = 1 << kExponent;
    _queueBuffer = malloc(_capacity << 1);
    _read = 0;
    _written = 0;
}

- (int)write:(int16_t *)buffer count:(uint)count
{
    
    if (!count) {
        return 0;
    }
    
    int t;
    int i;
    
    t = kSpace;
    
    if (count > t)
    {
        count = t;
    } else {
        t = count;
    }
    
    i = _written;
    
    if ((i + count) > _capacity)
    {
        memcpy(_queueBuffer + i, buffer, (_capacity - i) << 1);
        buffer += _capacity - i;
        count -= _capacity - i;
        i = 0;
    }
    
    memcpy(_queueBuffer + i, buffer, count << 1);
    _written = i + count;
    
    return t;
}

- (int)read:(int16_t *)buffer count:(uint)count
{
    
    int t;
    int i;
    
    t = kUsed;
    
    if (count > t)
    {
        count = t;
    } else {
        t = count;
    }
    
    i = _read;
    
    if ((i + count) > _capacity)
    {
        memcpy(buffer, _queueBuffer + i, (_capacity - i) << 1);
        buffer += _capacity - i;
        count -= _capacity - i;
        i = 0;
    }
    
    memcpy(buffer, _queueBuffer + i, count << 1);
    _read = i + count;
        
    return t;
}

- (int)used
{
    return kUsed;
}

@end
