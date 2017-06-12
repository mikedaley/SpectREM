//
//  AudioCore.h
//  ZXRetroEmulator
//
//  Created by Mike Daley on 03/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZXSpectrum;

#pragma mark - Type Defs

typedef NS_ENUM(NSUInteger, AY_Registers)
{
    eAYREGISTER_A_FINE = 0,
    eAYREGISTER_A_COARSE,
    eAYREGISTER_B_FINE,
    eAYREGISTER_B_COARSE,
    eAYREGISTER_C_FINE,
    eAYREGISTER_C_COARSE,
    eAYREGISTER_NOISEPER,
    eAYREGISTER_ENABLE,
    eAYREGISTER_A_VOL,
    eAYREGISTER_B_VOL,
    eAYREGISTER_C_VOL,
    eAYREGISTER_E_FINE,
    eAYREGISTER_E_COARSE,
    eAYREGISTER_E_SHAPE,
    eAYREGISTER_PORT_A,
    eAYREGISTER_PORT_B,
    
    // Used to emulate the odd floating behaviour of setting an AY register > 15. The value
    // written to registers > 15 decays over time and this is the value returned when reading
    // a register > 15
    eAYREGISTER_FLOATING,
    
    eAY_MAX_REGISTERS
};

typedef NS_ENUM(NSUInteger, ENVELOPE_FLAGS)
{
    eENVFLAG_HOLD = 0x01,
    eENVFLAG_ALTERNATE = 0x02,
    eENVFLAG_ATTACK = 0x04,
    eENVFLAG_CONTINUE = 0x08
};

@interface AudioCore : NSObject
{
@public
    signed int      channelOutput[3];
}

@property (assign) double lowPassFilter;
@property (assign) double highPassFilter;
@property (assign) double soundVolume;

#pragma mark - Methods

/*! @method initWithSampleRate:fps
	@abstract
 Initialize the audio engine
	@param sampleRate to be used for audio
	@param fps being rendered which is used to calculate the frame capacity for each audio buffer
 */
- (instancetype)initWithSampleRate:(int)sampleRate framesPerSecond:(float)fps emulationQueue:queue machine:(ZXSpectrum *)machine;

- (void)setAYRegister:(unsigned char)reg;
- (void)writeAYData:(unsigned char)data;
- (unsigned char)readAYData;
- (void)updateAY:(int)audioSteps;
- (void)reset;
- (void)stop;
- (void)start;

@end
