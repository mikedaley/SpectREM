//
//  SZX.m
//  SpectREM
//
//  Created by Mike Daley on 21/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "SZX.h"

@implementation SZX


+ (BOOL)isSZXValidWithURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    const char *bytes = (const char*)[data bytes];
    
    if (data.length < cSZXHeaderLength)
    {
        NSLog(@"SZX: Not enough data for header");
        return NO;
    }
    
    if (memcmp(cSZXHeaderSignature, bytes, cSZXHeaderSignatureLength))
    {
        NSLog(@"SZX: Signature invalid");
        return NO;
    }
    
    char major = bytes[ cSZXHeaderMajorVersionPosition ];
    char minor = bytes[ cSZXHeaderMinorVersionPosition ];

    NSLog(@"SZX: Version: %i.%i", major, minor);
    
    char machine = bytes[ cSZXHeaderMachineIdPosition ];
    
    NSLog(@"SZX: Machine: %@", [SZX machineNameForID:machine]);
    
    char flags = bytes[ cSZXHeaderFlagsPosition ];
    
    if (flags & cSZXHeaderFlag_AlternateTimings)
    {
        NSLog(@"SZX: Alternate timings");
    }
    else
    {
        NSLog(@"SZX: Normal timings");
    }
    
    return YES;
}


+ (int)machineNeededForSZXWithURL:(NSURL *)url
{
    if ([SZX isSZXValidWithURL:url])
    {
        NSData *data = [NSData dataWithContentsOfURL:url];
        const char *bytes = (const char*)[data bytes];
        char machine = bytes[ cSZXHeaderMachineIdPosition ];
        switch (machine) {
            case ZXSpectrum16:
            case ZXSpectrum48:
                return 0;
                break;
                
            case ZXSpectrum128:
                return 1;
        }
    }
    
    return -1;
}


+ (NSString *)machineNameForID:(char)machineId
{
    switch (machineId) {
        case ZXSpectrum16:
            return @"ZX Spectrum 16k";
            break;

        case ZXSpectrum48:
            return @"ZX Spectrum 48k";
            break;

        case ZXSpectrum128:
            return @"ZX Spectrum 128k";
            break;
    }
    
    return @"Unknown";
}

@end
