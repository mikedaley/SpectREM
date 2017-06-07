//
//  SerialCore.m
//  SpectREM
//
//  Created by Mike Daley on 21/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartLink.h"

@import ORSSerial;

#pragma mark - Private Interface

@interface SmartLink() <ORSSerialPortDelegate, NSUserNotificationCenterDelegate>

@property (strong) ORSSerialPacketDescriptor *sendOkResponse;
@property (strong) ORSSerialPacketDescriptor *verifyResponse;

@property (strong) NSMutableData *sendData;
@property (strong) NSMutableData *receivedData;
@property (assign) int responseBytes;

@end

#pragma mark - Implementation 

@implementation SmartLink

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        char responseCode[1] = {eSEND_OK};
        _sendOkResponse = [[ORSSerialPacketDescriptor alloc] initWithPacketData:[NSData dataWithBytes:responseCode
                                                                                                          length:1]
                                                                       userInfo:NULL];

        responseCode[0] = eVERIFY_RESPONSE;
        _verifyResponse = [[ORSSerialPacketDescriptor alloc] initWithPacketData:[NSData dataWithBytes:responseCode
                                                                                               length:1]
                                                                       userInfo:NULL];


        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
        [nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
        
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
#endif

    }
    return self;
}

#pragma mark - Actions

- (void)sendData:(NSData *)data expectedResponse:(ORSSerialPacketDescriptor *)expectedResponse responseLength:(int)length
{
    if (self.serialPort)
    {
        [self.sendData appendData:[data subdataWithRange:NSMakeRange(5, data.length - 5)]];
        ORSSerialRequest *request = [ORSSerialRequest requestWithDataToSend:data
                                                                   userInfo:NULL
                                                            timeoutInterval:2
                                                         responseDescriptor:expectedResponse];
        [self.serialPort sendRequest:request];
    }
}

#pragma mark - ORSSerialPortDelegate

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    self.serialPort = nil;
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSLog(@"Serial port %@ encountered an error: %@", self.serialPort, error);
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveResponse:(NSData *)responseData toRequest:(ORSSerialRequest *)request
{
    NSLog(@"didReceiveResponse: %@", responseData.description);
//    self.receivedData = [NSMutableData new];
}

- (void)serialPort:(ORSSerialPort *)serialPort requestDidTimeout:(ORSSerialRequest *)request
{
    NSLog(@"Command timed out!");
    [self.serialPort cancelAllQueuedRequests];
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    if (data.length > 5)
    {
        [self.receivedData appendData:[data subdataWithRange:NSMakeRange(1, data.length - 5)]];
        NSLog(@"%@", data.description);
    }
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port opened");
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    NSLog(@"Serial port closed");
}

#pragma mark - SmartLINK


- (void)sendSnapshot:(unsigned char *)snapshot
{
    if (self.sendData && self.receivedData)
    {
        if (self.receivedData.length > 0)
        {
            if (![self.receivedData isEqualToData:self.sendData])
            {
                NSLog(@"MISMATCH!");
            }
        }
    }
    
    self.sendData = [NSMutableData new];
    self.receivedData = [NSMutableData new];
    
    self.responseBytes = 0;
    
    int snapshotIndex = 0;
    int transferAmount = 16384;
    unsigned short blockSize = 8000;
    unsigned short spectrumAddress = 0x4000;
    
    // Reset Retroleum card
//    [self sendBlockWithCommand:eRETROLEUM_RESET
//                      location:0
//                        length:0
//                          data:snapshot
//              expectedResponse:self.verifyResponse];

    
    // Send register data
//    [self sendBlockWithCommand:eSEND_SNAPSHOT_REGISTERS
//                      location:snapshotIndex
//                        length:27
//                          data:snapshot
//              expectedResponse:self.verifyResponse];

    snapshotIndex += 27;

//    [self sendBlockWithCommand:eSEND_SNAPSHOT_DATA
//                      location:0x4000
//                        length:8000
//                          data:snapshot + snapshotIndex
//              expectedResponse:self.verifyResponse];
//    
//    return;
    
    // Send memory data
    for (int block = 0; block < (transferAmount / blockSize); block++)
    {
        [self sendBlockWithCommand:eSEND_SNAPSHOT_DATA
                          location:spectrumAddress
                            length:blockSize
                              data:snapshot + snapshotIndex
                  expectedResponse:self.verifyResponse];

        snapshotIndex += blockSize;
        spectrumAddress += blockSize;
    }
    
//    return;
    
    // Deal with any partial block data left over
    if (transferAmount % blockSize)
    {
        [self sendBlockWithCommand:eSEND_SNAPSHOT_DATA
                          location:spectrumAddress
                            length:transferAmount % blockSize
                              data:snapshot + snapshotIndex
                  expectedResponse:self.verifyResponse];
    }
    
    // Send start game
//    [self sendBlockWithCommand:eRUN_SNAPSHOT
//                      location:0
//                        length:0
//                          data:snapshot
//              expectedResponse:self.verifyResponse];
    
}

- (void)sendBlockWithCommand:(uint8_t)command location:(uint16_t)location length:(uint16_t)length data:(unsigned char *)data expectedResponse:(ORSSerialPacketDescriptor *)expectedResponse
{
    static char tmpbuffer[5 + 8192];
    tmpbuffer[0] = command;
    tmpbuffer[1] = location & 0xff;
    tmpbuffer[2] = location >> 8;
    tmpbuffer[3] = length & 0xff;
    tmpbuffer[4] = length >> 8;
    memcpy(tmpbuffer + 5, data, length);
    
    [self sendData:[NSData dataWithBytes:tmpbuffer length:length + 5] expectedResponse:expectedResponse responseLength:1];
}


#pragma mark - Properties

- (ORSSerialPortManager *)serialPortManager
{
    return [ORSSerialPortManager sharedSerialPortManager];
}

- (void)setSerialPort:(ORSSerialPort *)serialPort
{
    if (serialPort != _serialPort)
    {
        [_serialPort close];
        _serialPort.baudRate = @115200;
        _serialPort = serialPort;
        _serialPort.delegate = self;
        _serialPort.RTS = YES;
        _serialPort.DTR = YES;
        [_serialPort open];

        // Make sure that the change is propogated back to any bindings which may exist for this property
        [self propagateValue:_serialPort forBinding:@"serialPort"];
    }
}

#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [center removeDeliveredNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
    NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
    NSLog(@"Ports were connected: %@", connectedPorts);
    [self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
    NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
    NSLog(@"Ports were disconnected: %@", disconnectedPorts);
    [self postUserNotificationForDisconnectedPorts:disconnectedPorts];
    
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in connectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in disconnectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}

@end



//        if (responseData.length == 10)
//        {
//            __block char responseBuffer[10], *dataPtr;
//            [responseData getBytes:responseBuffer range:NSMakeRange(0, 10)];
//            dataPtr = responseBuffer;
//
//            if (responseBuffer[0] == 0x77)
//            {
//                dispatch_sync(weakSelf.emulationQueue, ^{
//                    for (int row = 0; row < 8; row++)
//                    {
//                        keyboardMap[row] ^= keyboardMap[row] ^ dataPtr[row + 1];
//                    };
//                    smartlinkKempston = dataPtr[9];
//                });
//            }
//        }
//        else
//        {

