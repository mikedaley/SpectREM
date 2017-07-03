//
//  Snapshot.h
//  SpectREM
//
//  Created by Mike Daley on 30/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//
//  Methods used to load both SNA and Z80 Snapshot files

#import <Foundation/Foundation.h>
#import "ZXSpectrum.h"

int const               cSNA_HEADER_SIZE = 27;
unsigned short const    cZ80_V3_HEADER_SIZE = 86;
unsigned short const    cZ80_V3_ADD_HEADER_SIZE = 54;
unsigned char const     cZ80_V3_PAGE_HEADER_SIZE = 3;

extern NSString *const cSNA_EXTENSION;
extern NSString *const cZ80_EXTENSION;

enum
{
    cZ80_SNAPSHOT_TYPE = 0,
    cSNA_SNAPSHOT_TYPE
};

struct snap {
    int length;
    unsigned char *data;
};

@interface Snapshot : NSObject

// SNA Snapshot
+ (snap)createSnapshotFromMachine:(ZXSpectrum *)machine;
+ (int)machineNeededForZ80SnapshotWithPath:(NSString *)snapshotPath;
+ (int)loadSnapshotWithPath:(NSString *)snapshotPath IntoMachine:(ZXSpectrum *)machine;

// Z80 Snapshot
+ (snap)createZ80SnapshotFromMachine:(ZXSpectrum *)machine;
+ (int)loadZ80SnapshotWithPath:(NSString *)snapshotpath intoMachine:(ZXSpectrum *)machine;
+ (void)extractMemoryBlock:(const char*)fileBytes memAddr:(int)memAddr fileOffset:(int)fileOffset compressed:(BOOL)isCompressed unpackedLength:(int)unpackedLength intoMachine:(ZXSpectrum *)machine;

// Decoded hardware string
+ (NSString *)hardwareStringForVersion:(int)version hardwareType:(int)hardwareType;

@end
