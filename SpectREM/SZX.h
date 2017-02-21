//
//  SZX.h
//  SpectREM
//
//  Created by Mike Daley on 21/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, SZXMachineType)
{
    ZXSpectrum16 = 0,
    ZXSpectrum48,
    ZXSpectrum128,
    ZXSpectrumPlus2,
    ZXSpectrumPlus2A,
    ZXSpectrumPlus3,
    ZXSpectrumPlus3E,
    Pentagon128,
    TC2048,
    TC2068,
    Scorpian,
    SE,
    TS2068,
    Pentagon512,
    Pentagon1024,
    ZXSpectrumNTSC48,
    ZXSpectrum128KE
};

static const char *cSZXFileSignature = "ZXST";
static const int cSZXFileSignatureLength = 4;

static

@interface SZX : NSObject


+ (void)machineNeededForSZXWithURL:(NSURL *)url;

@end
