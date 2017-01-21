//
//  SerialCore.h
//  SpectREM
//
//  Created by Mike Daley on 21/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORSSerialPortManager;
@class ORSSerialPort;

@interface SerialCore : NSObject

@property (nonatomic, readonly) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, copy) void (^dataReceivedBlock)(NSData *responseData);

- (void)sendData:(NSData *)data;

@end
