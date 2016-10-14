//
//  KeyboardMatrix.h
//  ZXRetroEmulator
//
//  Created by Mike Daley on 20/09/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#ifndef KeyboardMatrix_h
#define KeyboardMatrix_h

/**
    0xfefe  SHIFT, Z, X, C, V            0xeffe  0, 9, 8, 7, 6
    0xfdfe  A, S, D, F, G                0xdffe  P, O, I, U, Y
    0xfbfe  Q, W, E, R, T                0xbffe  ENTER, L, K, J, H
    0xf7fe  1, 2, 3, 4, 5                0x7ffe  SPACE, SYM SHFT, M, N, B
 */

// Keyboard data structure
struct KeyboardEntry {
    int keyCode;
    int mapEntry;
    int mapBit;
};

KeyboardEntry keyboardLookup[] = {
    { 6, 0,	1 },    // Z
    { 7, 0,	2 },    // X
    { 8, 0,	3 },    // C
    { 9, 0,	4 },    // V
    
    { 0, 1,	0 },    // A
    { 1, 1,	1 },    // S
    { 2, 1,	2 },    // D
    { 3, 1,	3 },    // F
    { 5, 1,	4 },    // G
    
    { 12, 2, 0 },   // Q
    { 13, 2, 1 },   // W
    { 14, 2, 2 },   // E
    { 15, 2, 3 },   // R
    { 17, 2, 4 },   // T
    
    { 18, 3, 0 },   // 1
    { 19, 3, 1 },   // 2
    { 20, 3, 2 },   // 3
    { 21, 3, 3 },   // 4
    { 23, 3, 4 },   // 5
    
    { 29, 4, 0 },   // 0
    { 25, 4, 1 },   // 9
    { 28, 4, 2 },   // 8
    { 26, 4, 3 },   // 7
    { 22, 4, 4 },   // 6
    
    { 35, 5, 0 },   // P
    { 31, 5, 1 },   // O
    { 34, 5, 2 },   // I
    { 32, 5, 3 },   // U
    { 16, 5, 4 },   // Y
    
    { 36, 6, 0 },   // ENTER
    { 37, 6, 1 },   // L
    { 40, 6, 2 },   // K
    { 38, 6, 3 },   // J
    { 4,  6, 4 },   // H
    
    { 49, 7, 0 },   // Space
    { 46, 7, 2 },   // M
    { 45, 7, 3 },   // N
    { 11, 7, 4 }    // B
};

#endif /* KeyboardMatrix_h */
