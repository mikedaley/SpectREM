//
//  MachineDetails.h
//  SpectREM
//
//  Created by Mike Daley on 29/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#ifndef MachineDetails_h
#define MachineDetails_h

static NS_ENUM(NSUInteger, MachineType)
{
    eZXSpectrum48 = 0,
    eZXSpectrum128,
    eZXSpectrumNext
};

// Details for each machine type being emulated
typedef struct
{
    int intLength;              // 1
    
    int tsPerFrame;             // 2
    int tsToOrigin;             // 3
    int tsPerLine;              // 4
    int tsTopBorder;            // 5
    int tsVerticalBlank;        // 6
    int tsVerticalDisplay;      // 7
    int tsHorizontalDisplay;    // 8
    int tsPerChar;              // 9
    
    int pxTopBorder;            // 10
    int pxVerticalBlank;        // 11
    int pxHorizontalDisplay;    // 12
    int pxVerticalDisplay;      // 13
    int pxHorizontalTotal;      // 14
    int pxVerticalTotal;        // 15
    
    bool hasAY;                 // 16
    bool hasPaging;             // 17
    
    // Offsets used during border and screen drawing. Calculated using trial and error!!!
    int borderDrawingOffset;    // 18
    int paperDrawingOffset;     // 19
    
    int machineType;            // 20
    
} MachineInfo;

static MachineInfo machines[] = {
    //1   2      3      4    5      6     7      8    9  10 11  12   13   14   15   16     17     18  19  20
    { 32, 69888, 14335, 224, 12544, 1792, 43008, 128, 4, 56, 8, 256, 192, 448, 312, false, false, 10, 16, eZXSpectrum48 }, // 48k
    { 36, 70908, 14362, 228, 12768, 1596, 43776, 128, 4, 56, 7, 256, 192, 448, 311, true,  true,  12, 16, eZXSpectrum128 },  // 128k
    { 36, 70908, 14362, 228, 12768, 1596, 43776, 128, 4, 56, 7, 256, 192, 448, 311, true,  true,  12, 16, eZXSpectrumNext }  // Next
};

#endif /* MachineDetails_h */

