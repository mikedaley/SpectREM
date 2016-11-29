//
//  MachineDetails.h
//  SpectREM
//
//  Created by Mike Daley on 29/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#ifndef MachineDetails_h
#define MachineDetails_h

// Details for each machine type being emulated
typedef struct
{
    int intLength;
    
    int tsPerFrame;
    int tsToOrigin;
    int tsPerLine;
    int tsTopBorder;
    int tsVerticalBlank;
    int tsVerticalDisplay;
    int tsHorizontalDisplay;
    int tsPerChar;
    
    int pxTopBorder;
    int pxVerticalBlank;
    int pxHorizontalDisplay;
    int pxVerticalDisplay;
    int pxHorizontalTotal;
    int pxVerticalTotal;
    
    bool hasAY;
    
} MachineInfo;

static MachineInfo machines[] = {
    
    { 32, 69888, 14335, 224, 12544, 1792, 43008, 128, 4, 56, 8, 256, 192, 448, 312, true }, // 48k
    { 36, 70908, 14363, 228, 12768, 1596, 43776, 128, 4, 56, 7, 256, 192, 448, 311, true }, // 128k
    { 32, 69888, 14335, 224, 12544, 1792, 43008, 128, 4, 56, 8, 256, 192, 448, 312, false } // 48k SE
    
};

#endif /* MachineDetails_h */

