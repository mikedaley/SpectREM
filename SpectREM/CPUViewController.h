//
//  CPUViewController.h
//  SpectREM
//
//  Created by Mike Daley on 15/11/2016.
//  Copyright © 2016 71Squared Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPUViewController : NSViewController

@property (assign) BOOL decimalFormat;

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

#pragma mark - Methods

- (void)updateViewWithMachine:(void *)m;

@end
