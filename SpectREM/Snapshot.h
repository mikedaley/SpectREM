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

@interface Snapshot : NSObject

+ (void)loadSnapshotWithPath:(NSString *)snapshotPath IntoMachine:(ZXSpectrum *)machine;
+ (void)loadZ80SnapshotWithPath:(NSString *)snapshotpath intoMachine:(ZXSpectrum *)machine;
+ (void)extractMemoryBlock:(const char*)fileBytes memAddr:(int)memAddr fileOffset:(int)fileOffset compressed:(BOOL)isCompressed unpackedLength:(int)unpackedLength intoMachine:(ZXSpectrum *)machine;
+ (NSString *)hardwareStringForVersion:(int)version hardwareType:(int)hardwareType;

@end
