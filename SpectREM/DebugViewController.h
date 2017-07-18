//
//  DebugViewController.h
//  SpectREM
//
//  Created by Mike Daley on 17/07/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXSpectrum;

@interface DebugViewController : NSViewController <NSTableViewDataSource, NSTabViewDelegate, NSTextFieldDelegate>

@property (assign) BOOL decimalFormat;

// Registers
@property (strong) NSString *pc;
@property (strong) NSString *sp;

@property (strong) NSString *af;
@property (strong) NSString *bc;
@property (strong) NSString *de;
@property (strong) NSString *hl;

@property (strong) NSString *a_af;
@property (strong) NSString *a_bc;
@property (strong) NSString *a_de;
@property (strong) NSString *a_hl;

@property (strong) NSString *ix;
@property (strong) NSString *iy;

@property (strong) NSString *i;
@property (strong) NSString *r;

@property (strong) NSString *im;

// Flag
@property (strong) NSString *fs;
@property (strong) NSString *fz;
@property (strong) NSString *f5;
@property (strong) NSString *fh;
@property (strong) NSString *f3;
@property (strong) NSString *fpv;
@property (strong) NSString *fn;
@property (strong) NSString *fc;

// Machine specifics
@property (strong) NSString *currentRom;
@property (strong) NSString *displayPage;
@property (strong) NSString *ramPage;
@property (strong) NSString *iff1;
@property (strong) NSString *tStates;

@property (assign) ZXSpectrum *machine;
@property (weak) IBOutlet NSTableView *disassemblyTableview;
@property (weak) IBOutlet NSTableView *memoryTableView;
@property (weak) IBOutlet NSTableView *stackTable;
@property (strong) NSData *imageData;
@property (strong) NSImage *displayImage;

- (void)step;

@end

#pragma mark - Disassembled Instruction Class

@interface DisassembledOpcode : NSObject

@property (assign) int address;
@property (strong) NSString *bytes;
@property (strong) NSString *instruction;

@end
