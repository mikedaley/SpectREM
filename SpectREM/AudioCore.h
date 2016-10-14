//
//  AudioCore.h
//  ZXRetroEmulator
//
//  Created by Mike Daley on 03/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZXSpectrum48;

@interface AudioCore : NSObject

@property (nonatomic) double lowPassFilter;
@property (nonatomic) double highPassFilter;

/*! @method initWithSampleRate:fps
	@abstract
 Initialize the audio engine
	@param sampleRate to be used for audio
	@param fps being rendered which is used to calculate the frame capacity for each audio buffer
 */
- (instancetype)initWithSampleRate:(int)sampleRate framesPerSecond:(float)fps emulationQueue:queue machine:(ZXSpectrum48 *)machine;

/*! @method updateBeeperAudioWithValue:
	@abstract
 Update the beepers buffer with the value provided
	@param value the value to be added to the audio buffer
	@discussion
 This method is called when the number of T-States in a frame exceeds the audio step could
 which is calculated as (framesTStates / FPS) / sampleRate e.g. (69888 / 50) / 44100
 */
//- (void)updateBeeperAudioWithValue:(float)value;


@end
