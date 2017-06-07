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

// Smartlink command types
typedef NS_ENUM(unsigned char, command)
{
    eRETROLEUM_RESET = 0x66,
    eSEND_SNAPSHOT_REGISTERS = 0xa0,
    eSEND_SNAPSHOT_DATA = 0xaa,
    eRUN_SNAPSHOT = 0x80
};

// Smartlink response types
typedef NS_ENUM(unsigned char, response)
{
    eSEND_OK = 0xaa,
    eVERIFY_RESPONSE = 0x88
};

#pragma mark - Interface

@interface SmartLink : NSObject_Bindings

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;

// Sends data to the current serial port. Also provides an expected response and response length
- (void)sendData:(NSData *)data expectedResponse:(ORSSerialPacketDescriptor *)expectedResponse responseLength:(int)length;

// Sends the supplied snapshot data to the current serial port
- (void)sendSnapshot:(unsigned char *)snapshot;

@end
