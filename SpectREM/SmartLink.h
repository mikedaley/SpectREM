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

typedef NS_ENUM(unsigned char, command) {
    eRETROLEUM_RESET = 0x66,
    eSEND_SNAPSHOT_REGISTERS = 0xa0,
    eSEND_SNAPSHOT_DATA = 0xaa,
    eRUN_SNAPSHOT = 0x80
};

@interface SmartLink : NSObject_Bindings

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, assign) BOOL dataReceived;
@property (nonatomic, assign) BOOL sendFailed;

- (void)sendData:(NSData *)data code:(unsigned char)code waitForResponse:(BOOL)wait;
- (void)sendSnapshot:(unsigned char *)snapshot;
@end
