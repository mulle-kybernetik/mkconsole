//---------------------------------------------------------------------------------------
//  MKConsoleWindowController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindowController.m,v 1.1.1.1 2002-12-02 23:57:12 erik Exp $
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
#import <EDCommon/EDCommon.h>
#import "MKLogfileReader.h"
#import "MKLogbook.h"
#import "MKConsoleWindow.h"
#import "MKConsoleWindowController.h"

@interface MKConsoleWindowController(PrivateAPI)
- (void)_tryRead:(NSTimer *)sender;
- (void)_screenParametersChanged:(NSNotification *)n;
@end


//---------------------------------------------------------------------------------------
    @implementation MKConsoleWindowController
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	init/dealloc
//---------------------------------------------------------------------------------------

- (id)initWithLogbook:(MKLogbook *)aLogbook
{
    [super init];

    logbook = [aLogbook retain];

    [NSBundle loadNibNamed:@"MKConsoleWindow" owner:self];
    NSAssert(window != nil, @"Problem with MKConsoleWindow.nib");
    [DNC addObserver:self selector:@selector(_screenParametersChanged:) name:NSApplicationDidChangeScreenParametersNotification object:nil];

    return self;
}


- (void)dealloc
{
    if(timer != nil)
        [self stop];
    [DNC removeObserver:self];
    [logbook release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	window handling
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    [window setFrame:[logbook windowFrame] display:YES];
    [[[outputArea superview] superview] setFrame:[[window contentView] frame]];
    [window orderFront:self];
}


- (void)_screenParametersChanged:(NSNotification *)n
{
    [window setFrame:[logbook windowFrame] display:YES];
    [[[outputArea superview] superview] setFrame:[[window contentView] frame]];
}


//---------------------------------------------------------------------------------------
//	start/stop
//---------------------------------------------------------------------------------------

- (void)start
{
    NSEnumerator	*filenameEnum;
    NSString		*filename;
    MKLogfileReader	*reader;

    if(timer != nil)
        [NSException raise:NSInternalInconsistencyException format:@"%s already started", __PRETTY_FUNCTION__];

    readerList = [[NSMutableArray allocWithZone:[self zone]] init];
    filenameEnum = [[logbook filenames] objectEnumerator];
    while((filename = [filenameEnum nextObject]) != nil)
        {
        reader = [[[MKLogfileReader allocWithZone:[self zone]] initWithFilename:filename] autorelease];
        [reader open];
        [readerList addObject:reader];
        }

    [self _tryRead:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:[DEFAULTS integerForKey:@"PollInterval"] target:self selector:@selector(_tryRead:) userInfo:nil repeats:YES];
}


- (void)stop
{
    NSEnumerator	*readerEnum;
    MKLogfileReader	*reader;

    if(timer == nil)
        [NSException raise:NSInternalInconsistencyException format:@"%s not started", __PRETTY_FUNCTION__];
    
    [timer invalidate];
    timer = nil;

    readerEnum = [readerList objectEnumerator];
    while((reader = [readerEnum nextObject]) != nil)
        [reader close];
    [readerList release];
    readerList = nil;
}


//---------------------------------------------------------------------------------------
//	read
//---------------------------------------------------------------------------------------

- (void)_tryRead:(NSTimer *)sender
{
    NSTextStorage		*textStorage;
    NSEnumerator		*readerEnum;
    MKLogfileReader		*reader;
    NSString			*message;

    textStorage = [outputArea textStorage];
    [textStorage beginEditing];
    readerEnum = [readerList objectEnumerator];
    while((reader = [readerEnum nextObject]) != nil)
        {
        while((message = [reader nextMessage]) != nil)
            [textStorage appendString:message withAttributes:[logbook textAttributes]];
        }
    if([textStorage length] > 50*1024)
        [textStorage deleteCharactersInRange:NSMakeRange(0, [textStorage length] - 50*1024)];
    [textStorage endEditing];
    [outputArea scrollRangeToVisible:NSMakeRange([textStorage length], 1)];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
