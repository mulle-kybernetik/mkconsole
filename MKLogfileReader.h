//---------------------------------------------------------------------------------------
//  MKLogfileReader.h created by erik on Sat Jun 29 2002
//  @(#)$Id: MKLogfileReader.h,v 1.4 2003-11-15 17:37:29 erik Exp $
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


@interface MKLogfileReader : NSObject
{
    NSString		*filename;
    NSFileHandle	*fileHandle;
    NSCalendarDate  *fileCreationDate;
    NSMutableString	*buffer;
}

- (id)initWithFilename:(NSString *)aFilename;

- (NSString *)filename;

- (BOOL)open;
- (void)close;
- (BOOL)reopen;

- (NSString *)nextMessage;

@end
