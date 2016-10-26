//
//  ZXSpectrum.h
//  SpectREM
//
//  Created by Mike Daley on 26/10/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "KeyboardEventProtocol.h"

#define kDisplayBorder 1
#define kDisplayPaper 2
#define kDisplayRetrace 3

#define kBitmapAddress 16384
#define kBitmapSize 6144
#define kAttributeAddress kBitmapAddress + kBitmapSize

@class AudioCore;
@class EmulationViewController;

@interface ZXSpectrum : NSObject <KeyboardEventProtocol>
{
    // Main Memory array
    // TODO: Break memory up into 16k banks. This will be needed for 128k machines
    unsigned char *memory;
    
    // Keyboard matrix data
    unsigned char keyboardMap[8];
    
    // Machine specific tState values
    int             tsPerFrame;
    int             tsPerLine;
    int             tsTopBorder;
    int             tsVerticalBlank;
    int             tsVerticalDisplay;
    int             tsHorizontalDisplay;
    int             tsPerChar;
    int             tsToOrigin;
    
    // Machine specific pixel values
    int             pxTopBorder;
    int             pxVerticalBlank;
    int             pxHorizontalDisplay;
    int             pxVerticalDisplay;
    int             pxHorizontalTotal;
    int             pxVerticalTotal;
    
    uint16          emuTsLine[192];
    uint8           emuDisplayTsTable[313][225];

    // Image buffer array buffer, its length and current index into the buffer used when drawing
    unsigned char   *emuDisplayBuffer;
    unsigned int    emuDisplayBufferLength;
    unsigned int    emuDisplayBufferIndex;
    
    // Holds the current border colour as set by the ULA
    int             borderColour;
    
    // Tracks the number of tStates used for drawing the screen. This is compared with the number of tStates that have passed
    // in the current frame so that the right number of 8x1 screen chunks are drawn
    int            emuDisplayTs;

    // Used to track the flash phase
    int             frameCounter;
    
}

#pragma mark - Properties
    
    // Buffer used to hold the sound samples generated for each emulation frame
    @property (assign) int16_t *audioBuffer;
    
    // Reference to the audio core instance
    @property (strong) AudioCore *audioCore;
    
    // Queue on which the emulation is run
    @property (strong) dispatch_queue_t emulationQueue;
    
    @property (assign) float displayBorderWidth;
    @property (assign) float soundVolume;
    @property (assign) double soundLowPassFilter;
    @property (assign) double soundHighPassFilter;

#pragma mark - Methods

- (instancetype)initWithEmulationViewController:(EmulationViewController *)emulationViewController;
- (void)start;
- (void)reset;
- (void)loadSnapshotWithPath:(NSString *)path;
- (void)doFrame;
- (void)resetKeyboardMap;
- (void)buildDisplayTsTable;
- (void)buildScreenLineAddressTable;

void updateScreenWithTStates(int numberTs, void *m);

@end
