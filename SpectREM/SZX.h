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

#pragma mark - SZX Header

static const int cSZXHeaderLength = 8;

static const char *cSZXHeaderSignature = "ZXST";
static const int cSZXHeaderSignatureLength = 4;

static const int cSZXHeaderSignaturePosition = 0;
static const int cSZXHeaderMajorVersionPosition = 4;
static const int cSZXHeaderMinorVersionPosition = 5;
static const int cSZXHeaderMachineIdPosition = 6;
static const int cSZXHeaderFlagsPosition = 7;

static const int cSZXHeaderFlag_AlternateTimings = 1;

#pragma mark - SZX Block

static const int cSZXBlockHeaderLength = 8;

static const int cSZXBlockHeaderSignatureLength = 4;

static const int cSZXBlockHeader_SignaturePosition = 0;
static const int cSZXBlockHeader_SizePosition = 4;

@interface SZX : NSObject

+ (BOOL)isSZXValidWithURL:(NSURL *)url;
+ (int)machineNeededForSZXWithURL:(NSURL *)url;

@end
