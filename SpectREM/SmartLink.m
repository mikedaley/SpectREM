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

@property (assign) bool slDataSent;

@property (strong) dispatch_queue_t smartLinkQueue;

@end

#pragma mark - Implementation 

@implementation SmartLink

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _smartLinkQueue = dispatch_queue_create("com.71squared.smartlink", DISPATCH_QUEUE_SERIAL);

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

- (void)sendData:(NSData *)data code:(unsigned char)code waitForResponse:(BOOL)wait
{
    if (self.serialPort)
    {
        dispatch_async(_smartLinkQueue, ^{
            
            if (self.sendFailed)
            {
                NSLog(@"FAILED!");
                return;
            }
            
            NSLog(@"Sending code: %i", code);
            
            [self.serialPort sendData:data];
            
            if (wait)
            {
                self.dataReceived = NO;
                CFTimeInterval startTime = CACurrentMediaTime();
                CFTimeInterval elapsedTime = 0;
                while(!self.dataReceived)
                {
                    elapsedTime = CACurrentMediaTime() - startTime;
                    if (elapsedTime > 2)
                    {
                        NSLog(@"SmartLINK timeout!");
                        self.sendFailed = YES;
                        break;
                    }
                };
            }
        });
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

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    unsigned char responseBuffer[1], *dataPtr;
    [data getBytes:responseBuffer range:NSMakeRange(0, data.length)];
    dataPtr = responseBuffer;

    NSLog(@"Response: %i", responseBuffer[0]);

    // If the first byte of the response is 0xaa, then we know the data that was sent has been received
    if (responseBuffer[0] == 0xaa)
    {
        self.dataReceived = YES;
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
    self.sendFailed = NO;
    int snapshotIndex = 0;
    int transferAmount = 48 * 1024;
    unsigned short blockSize = 8000;
    unsigned short spectrumAddress = 0x4000;
    
    // Reset Retroleum card
    unsigned char spectrumReset[1];
    spectrumReset[0] = eRETROLEUM_RESET;
    [self sendData:[NSData dataWithBytes:spectrumReset length:1] code:eRETROLEUM_RESET waitForResponse:YES];

    // Send register data
    [self sendBlockWithCode:eSEND_SNAPSHOT_REGISTERS
                   location:snapshotIndex
                     length:27
                       data:snapshot];

    snapshotIndex += 27;
    
    // Send memory data
    for (int block = 0; block < (transferAmount / blockSize); block++)
    {
        [self sendBlockWithCode:eSEND_SNAPSHOT_DATA
                       location:spectrumAddress
                         length:blockSize
                           data:snapshot + snapshotIndex];
        snapshotIndex += blockSize;
        spectrumAddress += blockSize;
    }
    
    // Deal with any partial block data left over
    if (transferAmount % blockSize)
    {
        [self sendBlockWithCode:0xaa
                       location:spectrumAddress
                         length:transferAmount % blockSize
                           data:snapshot + snapshotIndex];
    }
    
    // Send start game
    [self sendBlockWithCode:eRUN_SNAPSHOT
                   location:0
                     length:0
                       data:snapshot];
    
}

- (void)sendBlockWithCode:(uint8_t)code location:(uint16_t)location length:(uint16_t)length data:(unsigned char *)data
{
    static char tmpbuffer[5 + 8192];
    tmpbuffer[0] = code;
    tmpbuffer[1] = location & 0xff;
    tmpbuffer[2] = location >> 8;
    tmpbuffer[3] = length & 0xff;
    tmpbuffer[4] = length >> 8;
    memcpy(tmpbuffer + 5, data, length);
    
    [self sendData:[NSData dataWithBytes:tmpbuffer length:length + 5] code:code waitForResponse:YES];
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

