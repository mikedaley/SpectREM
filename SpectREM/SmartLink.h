//
//  SerialCore.h
//  SpectREM
//
//  Created by Mike Daley on 21/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Bindings.h"

@class ORSSerialPortManager;
@class ORSSerialPort;
@class ORSSerialPacketDescriptor;

typedef NS_ENUM(unsigned char, command)
{
    eRETROLEUM_RESET = 0x66,
    eSEND_SNAPSHOT_REGISTERS = 0xa0,
    eSEND_SNAPSHOT_DATA = 0xaa,
    eRUN_SNAPSHOT = 0x80
};

typedef NS_ENUM(unsigned char, response)
{
    eSEND_OK = 0xaa,
    eVERIFY_RESPONSE = 0x88
};

@interface SmartLink : NSObject_Bindings

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;

- (void)sendData:(NSData *)data expectedResponse:(ORSSerialPacketDescriptor *)expectedResponse responseLength:(int)length;
- (void)sendSnapshot:(unsigned char *)snapshot;

@end
