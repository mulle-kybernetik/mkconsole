//---------------------------------------------------------------------------------------
//  MKLogfile.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKLogfileReader.m,v 1.2 2003-02-02 20:59:37 erik Exp $
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

#import <Foundation/Foundation.h>
#import "MKLogfileReader.h"


//---------------------------------------------------------------------------------------
    @implementation MKLogfileReader
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	init/dealloc
//---------------------------------------------------------------------------------------

- (id)initWithFilename:(NSString *)aFilename
{
    [super init];
    filename = [aFilename copyWithZone:[self zone]];
    lastPosition = UINT_MAX;
    return self;
}


- (void)dealloc
{
    if(fileHandle != nil)
        [self close];
    [filename release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	accessor methods
//---------------------------------------------------------------------------------------

- (NSString *)filename
{
    return filename;
}



//---------------------------------------------------------------------------------------
//	open/close
//---------------------------------------------------------------------------------------

- (BOOL)open
{
    if(fileHandle != nil)
        return YES;
    if((fileHandle = [NSFileHandle fileHandleForReadingAtPath:filename]) == nil)
        return NO;
    [fileHandle retain];
    [fileHandle seekToEndOfFile];
    [fileHandle seekToFileOffset:MAX(0, (int)[fileHandle offsetInFile] - 2*1024)];
    buffer = [[NSMutableString allocWithZone:[self zone]] init];
    [self nextMessage];
    return YES;
}


- (void)close
{
    if(fileHandle == nil)
        return;
    [fileHandle release];
    fileHandle = nil;
    [buffer release];
    buffer = nil;
}



//---------------------------------------------------------------------------------------
//	read a line
//---------------------------------------------------------------------------------------

- (NSString *)nextMessage
{
    static NSCharacterSet *nlSet = nil;
    NSData		*data;
    NSString	*string;
    NSRange		r;

    if(nlSet == nil)
        nlSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n"] retain];

    r = [buffer rangeOfCharacterFromSet:nlSet];
    if(r.length == 0)
        {
        if(fileHandle == nil)
            return nil;
        NS_DURING
            data = [fileHandle readDataToEndOfFile];
        NS_HANDLER
            // Retry if we got a Stale NFS file handle exception
            if(([[localException name] isEqualToString:NSFileHandleOperationException] ==  NO) ||
               ([[localException reason] rangeOfString:@"Stale"].length == 0))
                [localException raise];
            [self close];
            [self open];
            data = [fileHandle readDataToEndOfFile];
        NS_ENDHANDLER
        if([data length] == 0)
            return nil;
        string = [[NSString allocWithZone:[self zone]] initWithData:data encoding:NSISOLatin1StringEncoding];
        [buffer appendString:string];
        [string release];
        r = [buffer rangeOfCharacterFromSet:nlSet];
        if(r.length == 0)
            return nil;
        }
    string = [buffer substringToIndex:NSMaxRange(r)];
    [buffer deleteCharactersInRange:NSMakeRange(0, NSMaxRange(r))];
    return string;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
