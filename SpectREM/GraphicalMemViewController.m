//
//  GraphicalMemViewController.m
//  SpectREM
//
//  Created by Mike Daley on 14/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "GraphicalMemViewController.h"
#import "ZXSpectrum.h"

@interface GraphicalMemViewController ()
{
    CGColorSpaceRef _colorSpace;
}

@end

@implementation GraphicalMemViewController

- (void)dealloc
{
    CGColorSpaceRelease(_colorSpace);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _colorSpace = CGColorSpaceCreateDeviceGray();
}

- (void)updateViewWithMachine:(void *)m
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    CFDataRef memoryDataRef = CFDataCreate(kCFAllocatorDefault, machine->memory, 65536);
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData(memoryDataRef);

    CGImageRef cgImage = CGImageCreate(256,
                                        2048,
                                        1,
                                        1,
                                        32,
                                        _colorSpace,
                                        (CGBitmapInfo)kCGBitmapByteOrderDefault,
                                        providerRef,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    self.memoryImage = [[NSImage alloc] initWithCGImage:cgImage size:(NSSize){256, 2048}];
    self.memoryView.memoryImage = self.memoryImage;
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(providerRef);
    CFRelease(memoryDataRef);
}

@end
