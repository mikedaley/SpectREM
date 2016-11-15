//
//  CPUViewController.m
//  SpectREM
//
//  Created by Mike Daley on 15/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import "CPUViewController.h"
#import "ZXSpectrum.h"
#import "Z80Core.h"

@interface CPUViewController ()

@end

@implementation CPUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _decimalFormat = NO;
}

- (void)updateViewWithMachine:(void *)m
{
    ZXSpectrum *machine = (__bridge ZXSpectrum *)m;
    CZ80Core *core = (CZ80Core *)[machine getCore];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.decimalFormat)
        {
            self.pc = [NSString stringWithFormat:@"0x%04X", core->GetRegister(CZ80Core::eREG_PC)];
            self.sp = [NSString stringWithFormat:@"0x%04X", core->GetRegister(CZ80Core::eREG_SP)];
            self.a = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_A)];
            self.f = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_F)];
            self.b = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_B)];
            self.c = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_C)];
            self.d = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_D)];
            self.e = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_E)];
            self.h = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_H)];
            self.l = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_L)];
            self.i = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_I)];
            self.r = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_R)];
            self.im = [NSString stringWithFormat:@"0x%02X", core->GetIMMode()];
            self.ix = [NSString stringWithFormat:@"0x%04X", core->GetRegister(CZ80Core::eREG_IX)];
            self.iy = [NSString stringWithFormat:@"0x%04X", core->GetRegister(CZ80Core::eREG_IY)];

        
            self.aa = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_A)];
            self.ff = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_F)];
            self.bb = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_B)];
            self.cc = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_C)];
            self.dd = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_D)];
            self.ee = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_E)];
            self.hh = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_H)];
            self.ll = [NSString stringWithFormat:@"0x%02X", core->GetRegister(CZ80Core::eREG_ALT_L)];
}
//    });

}

@end
