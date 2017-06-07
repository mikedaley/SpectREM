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

@end


#pragma mark - Constants


int const cSERIAL_BAUD_RATE = 115200;
int const cSNAPSHOT_START_ADDRESS = 16384;
int const cBLOCK_SIZE = 8000;
int const cSNAPSHOT_DATA_SIZE = 49152;
int const cSNAPSHOT_HEADER_LENGTH = 27;
int const cCOMMAND_HEADER_SIZE = 5;
int const cSERIAL_TIMEOUT = 2;


#pragma mark - Static


static char snapshotBuffer[cBLOCK_SIZE + cCOMMAND_HEADER_SIZE];


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
        ORSSerialRequest *request = [ORSSerialRequest requestWithDataToSend:data
                                                                   userInfo:NULL
                                                            timeoutInterval:cSERIAL_TIMEOUT
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
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData: %@", data.description);
}

- (void)serialPort:(ORSSerialPort *)serialPort requestDidTimeout:(ORSSerialRequest *)request
{
    NSLog(@"Command timed out!");
    [self.serialPort cancelAllQueuedRequests];
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
    int snapshotIndex = 0;
    unsigned short spectrumAddress = cSNAPSHOT_START_ADDRESS;
    
    // Reset Retroleum card
    [self sendBlockWithCommand:eRETROLEUM_RESET
                      location:0
                        length:0
                          data:snapshot
              expectedResponse:self.sendOkResponse];

    
    // Send register data
    [self sendBlockWithCommand:eSEND_SNAPSHOT_REGISTERS
                      location:snapshotIndex
                        length:cSNAPSHOT_HEADER_LENGTH
                          data:snapshot
              expectedResponse:self.sendOkResponse];

    snapshotIndex += cSNAPSHOT_HEADER_LENGTH;
    
    // Send memory data
    for (int block = 0; block < (cSNAPSHOT_DATA_SIZE / cBLOCK_SIZE); block++)
    {
        [self sendBlockWithCommand:eSEND_SNAPSHOT_DATA
                          location:spectrumAddress
                            length:cBLOCK_SIZE
                              data:snapshot + snapshotIndex
                  expectedResponse:self.self.sendOkResponse];

        snapshotIndex += cBLOCK_SIZE;
        spectrumAddress += cBLOCK_SIZE;
    }
    
    // Deal with any partial block data left over
    if (cSNAPSHOT_DATA_SIZE % cBLOCK_SIZE)
    {
        [self sendBlockWithCommand:eSEND_SNAPSHOT_DATA
                          location:spectrumAddress
                            length:cSNAPSHOT_DATA_SIZE % cBLOCK_SIZE
                              data:snapshot + snapshotIndex
                  expectedResponse:self.sendOkResponse];
    }
    
    // Send start game
    [self sendBlockWithCommand:eRUN_SNAPSHOT
                      location:0
                        length:0
                          data:snapshot
              expectedResponse:self.sendOkResponse];
    
}

- (void)sendBlockWithCommand:(uint8_t)command location:(uint16_t)location length:(uint16_t)length data:(unsigned char *)data expectedResponse:(ORSSerialPacketDescriptor *)expectedResponse
{
    snapshotBuffer[0] = command;
    snapshotBuffer[1] = location & 255;
    snapshotBuffer[2] = location >> 8;
    snapshotBuffer[3] = length & 255;
    snapshotBuffer[4] = length >> 8;
    memcpy(snapshotBuffer + cCOMMAND_HEADER_SIZE, data, length);
    
    [self sendData:[NSData dataWithBytes:snapshotBuffer length:length + cCOMMAND_HEADER_SIZE] expectedResponse:expectedResponse responseLength:1];
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
        _serialPort.baudRate = @(cSERIAL_BAUD_RATE);
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

