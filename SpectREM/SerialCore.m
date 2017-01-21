//
//  SerialCore.m
//  SpectREM
//
//  Created by Mike Daley on 21/01/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "SerialCore.h"
@import ORSSerial;

#pragma mark - Private Interface

@interface SerialCore() <ORSSerialPortDelegate, NSUserNotificationCenterDelegate>

@end

#pragma mark - Implementation 

@implementation SerialCore

- (instancetype)init
{
    self = [super init];
    if (self)
    {
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

- (void)sendData:(NSData *)data
{
    if (self.serialPort)
    {
        [self.serialPort sendData:data];
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
    self.dataReceivedBlock(data);
    
//    if (data.length == 10) {
//        char buffer[10];
//        [data getBytes:buffer range:NSMakeRange(0, 10)];
//        if (buffer[0] == 0x77)
//        {
//            NSLog(@"%@", data.description);
//        }
//    }
}

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    
}

#pragma mark - Properties

- (ORSSerialPortManager *)serialPortManager
{
    return [ORSSerialPortManager sharedSerialPortManager];
}

- (void)setSerialPort:(ORSSerialPort *)serialPort
{
    if (serialPort != _serialPort) {
        [_serialPort close];
        _serialPort.delegate = nil;
        
        _serialPort = serialPort;
        
        _serialPort.baudRate = @115200;
        _serialPort.delegate = self;
        _serialPort.RTS = YES;
        [_serialPort open];
    }
}

#pragma mark - Notifications

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

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
