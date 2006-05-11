//---------------------------------------------------------------------------------------
//  MKLogfile.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKLogfileReader.m,v 1.7 2006-05-11 22:25:33 erik Exp $
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


@interface MKLogfileReader(Private)
- (BOOL)_fillBuffer;
@end


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


- (void)setFileCreationDateFromFilesystem
{
    NSDictionary *attrs;

    attrs = [[NSFileManager defaultManager] fileAttributesAtPath:filename traverseLink:YES];
    [fileCreationDate autorelease];
    fileCreationDate = [[attrs fileCreationDate] retain];
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
    [self setFileCreationDateFromFilesystem];
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
    [fileCreationDate release];
    fileCreationDate = nil;
}


- (BOOL)reopen
{
    NSCalendarDate  *lastCreationDate;
    unsigned int    lastPosition, newLength;

    if(fileHandle != nil)
        {
		NS_DURING
			[self _fillBuffer]; // make sure we don't miss anything
			lastPosition = [fileHandle offsetInFile];
			[fileHandle closeFile];
		NS_HANDLER
			NSLog(@"## problem with file %@: failed to read rest before reopening (ignoring)", filename);
		NS_ENDHANDLER
        [fileHandle release];
        fileHandle = nil;
        }
    else
        {
        lastPosition = 0;
        }

    if((fileHandle = [NSFileHandle fileHandleForReadingAtPath:filename]) == nil)
        {
        NSLog(@"## problem with file %@: failed to reopen.", filename);
        return NO;
        }
    [fileHandle retain];

    lastCreationDate = [[fileCreationDate retain] autorelease];
    [self setFileCreationDateFromFilesystem];
    if([fileCreationDate compare:lastCreationDate] == NSOrderedSame)
        {
        newLength = [fileHandle seekToEndOfFile];
        if(newLength < lastPosition) // uh, same creation date but shorter now? start at "beginning"
            [fileHandle seekToFileOffset:MAX(0, (int)newLength - 2*1024)];
        else if(newLength > lastPosition) // busy, busy. go back to where we were
            [fileHandle seekToFileOffset:lastPosition];
        }
    
    return YES;
}


//---------------------------------------------------------------------------------------
//	get next line
//---------------------------------------------------------------------------------------

- (NSString *)nextMessage
{
    static NSCharacterSet *nlSet = nil;
    NSString	*string;
    NSRange		r;

    if(nlSet == nil)
        nlSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n"] retain];

    r = [buffer rangeOfCharacterFromSet:nlSet];
    if(r.length == 0)
        {
        [self _fillBuffer];
        r = [buffer rangeOfCharacterFromSet:nlSet];
        if(r.length == 0)
            return nil;
        }
    string = [buffer substringToIndex:NSMaxRange(r)];
    [buffer deleteCharactersInRange:NSMakeRange(0, NSMaxRange(r))];
    return string;
}


//---------------------------------------------------------------------------------------
//	helper methods
//---------------------------------------------------------------------------------------

- (BOOL)_fillBuffer
{
    NSData   *newData;
    NSString *newString;
    
    if(fileHandle == nil)
        return NO;
    NS_DURING
        newData = [fileHandle readDataToEndOfFile];
    NS_HANDLER
        // Retry if we got a Stale NFS file handle exception
        if(([[localException name] isEqualToString:NSFileHandleOperationException] ==  NO) ||
           ([[localException reason] rangeOfString:@"Stale"].length == 0))
            [localException raise];
        [self close];
        [self open];
        NSLog(@"## nfs problem, file is now %@.", (fileHandle != nil) ? @"open" : @"closed");
        newData = [fileHandle readDataToEndOfFile];
    NS_ENDHANDLER
    if([newData length] == 0)
        return NO;
    newString = [[NSString allocWithZone:[self zone]] initWithData:newData encoding:NSISOLatin1StringEncoding];
    [buffer appendString:newString];
    [newString release];
    return YES;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
