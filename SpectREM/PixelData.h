//
//  PixelData.h
//  SpectREM
//
//  Created by Mike Daley on 24/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#ifndef PixelData_h
#define PixelData_h

// Structure of pixel data used in the emulation display buffer
struct PixelColor
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
};

// Pallette
static struct PixelColor pallette[] = {
    
    // Normal colours
    {0, 0, 0, 255},         // Black
    {0, 0, 200, 255},       // Blue
    {200, 0, 0, 255},       // Red
    {200, 0, 200, 255},     // Green
    {0, 200, 0, 255},       // Magenta
    {0, 200, 200, 255},     // Cyan
    {200, 200, 0, 255},     // Yellow
    {200, 200, 200, 255},   // White
    
    // Bright colours
    {0, 0, 0, 255},
    {0, 0, 255, 255},
    {255, 0, 0, 255},
    {255, 0, 255, 255},
    {0, 255, 0, 255},
    {0, 255, 255, 255},
    {255, 255, 0, 255},
    {255, 255, 255, 255}
};

#endif /* PixelData_h */
