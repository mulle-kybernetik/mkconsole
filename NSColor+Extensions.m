//---------------------------------------------------------------------------------------
//  NSColor+Extensions.m created by erik on Mon Jul 01 2002
//  @(#)$Id: NSColor+Extensions.m,v 1.1.1.1 2002-12-02 23:57:12 erik Exp $
//
//  Copyright (c) 2002 by Mulle Kybernetik. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mulle Kybernetik in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "NSColor+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSColor(MkConsoleExtensions)
//---------------------------------------------------------------------------------------

+ (id)colorWithCalibratedStringRep:(NSString *)stringRep
{
    NSScanner	*scanner;
    float		redComponent, greenComponent, blueComponent, alphaComponent;
    
    scanner = [NSScanner scannerWithString:stringRep];
    [scanner scanFloat:&redComponent];
    [scanner scanFloat:&greenComponent];
    [scanner scanFloat:&blueComponent];
    [scanner scanFloat:&alphaComponent];
    
    return [NSColor colorWithCalibratedRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];

}

- (NSString *)stringRep
{
    return [NSString stringWithFormat:@"%g %g %g %g", [self redComponent], [self greenComponent], [self blueComponent], [self alphaComponent]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
