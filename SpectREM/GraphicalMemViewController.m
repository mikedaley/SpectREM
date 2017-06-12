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
    NSImage *_memoryImage;
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
    self.displayByteWidth = 32;
}

- (void)updateViewWithMachine:(void *)m
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    
    CFDataRef memoryDataRef = CFDataCreate(kCFAllocatorDefault, machine->memory, 65536);
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData(memoryDataRef);

    NSUInteger displayWidth = self.displayByteWidth * 8;
    NSUInteger displayHeight = 65536 / self.displayByteWidth;
    
    CGImageRef cgImage = CGImageCreate(displayWidth,
                                        displayHeight,
                                        1,
                                        1,
                                        _displayByteWidth,
                                        _colorSpace,
                                        (CGBitmapInfo)kCGBitmapByteOrderDefault,
                                        providerRef,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    _memoryImage = [[NSImage alloc] initWithCGImage:cgImage size:(NSSize){displayWidth, displayHeight}];
    [self.memoryView setFrameSize:(NSSize){displayWidth, displayHeight}];
    self.memoryView.memoryImage = _memoryImage;
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(providerRef);
    CFRelease(memoryDataRef);
}



@end
