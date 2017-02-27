//
//  DebugViewController.h
//  SpectREM
//
//  Created by Mike Daley on 06/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZXSpectrum;

@interface DisassemblyViewController : NSViewController <NSTableViewDataSource, NSTabViewDelegate, NSTextFieldDelegate>

#pragma mark - UI

@property (strong) NSString *pc;
@property (strong) NSString *sp;
@property (strong) NSString *a;
@property (strong) NSString *f;
@property (strong) NSString *b;
@property (strong) NSString *c;
@property (strong) NSString *d;
@property (strong) NSString *e;
@property (strong) NSString *h;
@property (strong) NSString *l;
@property (strong) NSString *i;
@property (strong) NSString *r;
@property (strong) NSString *im;
@property (strong) NSString *ix;
@property (strong) NSString *iy;

@property (strong) NSString *aa;
@property (strong) NSString *ff;
@property (strong) NSString *bb;
@property (strong) NSString *cc;
@property (strong) NSString *dd;
@property (strong) NSString *ee;
@property (strong) NSString *hh;
@property (strong) NSString *ll;

@property (strong) NSString *fs;
@property (strong) NSString *fz;
@property (strong) NSString *f5;
@property (strong) NSString *fh;
@property (strong) NSString *f3;
@property (strong) NSString *fpv;
@property (strong) NSString *fn;
@property (strong) NSString *fc;

@property (strong) NSString *tStates;

#pragma mark -

@property (assign, nonatomic) BOOL decimalFormat;

@property (assign) ZXSpectrum *machine;
@property (weak) IBOutlet NSTableView *disassemblyTableview;
@property (weak) IBOutlet NSTextField *addressTextField;
@property (weak) IBOutlet NSTableView *memoryContentTableview;


@end

#pragma mark - Disassembled Instruction Class

@interface DisassembledInstruction : NSObject

@property (assign) int address;
@property (strong) NSString *bytes;
@property (strong) NSString *instruction;

@end
