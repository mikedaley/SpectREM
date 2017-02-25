//
//  DecimalOnlyFormatter.m
//  SpectREM
//
//  Created by Mike Daley on 22/02/2017.
//  Copyright © 2017 71Squared Ltd. All rights reserved.
//

#import "DecimalOnlyFormatter.h"

@implementation DecimalOnlyFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing  _Nullable *)newString errorDescription:(NSString *__autoreleasing  _Nullable *)error
{
    if (newString)
    {
        *newString = nil;
    }
    
    if (error)
    {
        *error = nil;
    }
    
    // Setup a nonDecimals character set which can be used when checking for non decimal characrers;
    static NSCharacterSet *nonDecimalCharacters = nil;
    if (nonDecimalCharacters == nil)
    {
        nonDecimalCharacters = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    
    // It's OK for the length to be 0 as the user may well be deleting everything
    if ([partialString length] == 0)
    {
        return YES;
    }
    
    // If we find a non-decimal character that is not valid, so return NO
    else if ([partialString rangeOfCharacterFromSet:nonDecimalCharacters].location != NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

@end
