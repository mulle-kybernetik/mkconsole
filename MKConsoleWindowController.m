//---------------------------------------------------------------------------------------
//  MKConsoleWindowController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindowController.m,v 1.6 2003-11-15 17:37:29 erik Exp $
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
#import "MKLogfileReader.h"
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

- (id)initWithSettings:(NSDictionary *)settings;
{
    [super init];

    filenames = [[settings objectForKey:@"Files"] retain];
    windowFrame = NSRectFromString([settings objectForKey:@"Frame"]);
    textAttributes = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:[NSFont fontWithName:[settings objectForKey:@"FontName"] size:[[settings objectForKey:@"FontSize"] floatValue]], NSFontAttributeName, [NSColor colorWithCalibratedStringRep:[settings objectForKey:@"TextColor"]], NSForegroundColorAttributeName, nil];
    
    [NSBundle loadNibNamed:@"MKConsoleWindow" owner:self];
    NSAssert(window != nil, @"Problem with MKConsoleWindow.nib");
    [window setBackgroundColor:[NSColor colorWithCalibratedStringRep:[settings objectForKey:@"BackgroundColor"]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenParametersChanged:) name:NSApplicationDidChangeScreenParametersNotification object:nil];

    return self;
}


- (void)dealloc
{
    if(timer != nil)
        [self stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [filenames release];
    [textAttributes release];
    [window release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	window handling
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    [window setFrame:windowFrame display:YES];
    [[[outputArea superview] superview] setFrame:[[window contentView] frame]];
    [window orderFront:self];
}


- (void)_screenParametersChanged:(NSNotification *)n
{
    [window setFrame:windowFrame display:YES];
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

    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(timer != nil)
        [NSException raise:NSInternalInconsistencyException format:@"%s already started", __PRETTY_FUNCTION__];

    cycle = 0;
    readerList = [[NSMutableArray allocWithZone:[self zone]] init];
    filenameEnum = [filenames objectEnumerator];
    while((filename = [filenameEnum nextObject]) != nil)
        {
        reader = [[[MKLogfileReader allocWithZone:[self zone]] initWithFilename:filename] autorelease];
        if([reader open])
            [readerList addObject:reader];
        else
            NSRunAlertPanel(nil, @"Failed to open logfile at: %@", @"Cancel", nil, nil, filename);
        }

    [self _tryRead:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] integerForKey:@"PollInterval"] target:self selector:@selector(_tryRead:) userInfo:nil repeats:YES];
    NSLog(@"%s ok", __PRETTY_FUNCTION__);
}


- (void)stop
{
    NSEnumerator	*readerEnum;
    MKLogfileReader	*reader;

    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(timer == nil)
        [NSException raise:NSInternalInconsistencyException format:@"%s not started", __PRETTY_FUNCTION__];
    
    [timer invalidate];
    timer = nil;

    readerEnum = [readerList objectEnumerator];
    while((reader = [readerEnum nextObject]) != nil)
        [reader close];
    [readerList release];
    readerList = nil;
    NSLog(@"%s ok", __PRETTY_FUNCTION__);
}


//---------------------------------------------------------------------------------------
//	read
//---------------------------------------------------------------------------------------

- (void)_tryRead:(NSTimer *)sender
{
    NSTextStorage 	 *textStorage;
    NSEnumerator	 *readerEnum;
    MKLogfileReader	 *reader;
    NSString		 *message;

    cycle = (cycle + 1) % [[[NSUserDefaults standardUserDefaults] objectForKey:@"ReopenFactor"] intValue];
    if(cycle == 0)
        {
        readerEnum = [readerList objectEnumerator];
        while((reader = [readerEnum nextObject]) != nil)
            [reader reopen];
        }
    
    textStorage = [outputArea textStorage];
    [textStorage beginEditing];
    readerEnum = [readerList objectEnumerator];
    while((reader = [readerEnum nextObject]) != nil)
        {
        while((message = [reader nextMessage]) != nil)
            {
            unsigned int location = [textStorage length];
            [textStorage replaceCharactersInRange:NSMakeRange(location, 0) withString:message];
            [textStorage setAttributes:textAttributes range:NSMakeRange(location, [textStorage length] - location)];
            }
        }
    if([textStorage length] > 50*1024)
        [textStorage deleteCharactersInRange:NSMakeRange(0, [textStorage length] - 50*1024)];
    [textStorage endEditing];
    [outputArea scrollRangeToVisible:NSMakeRange([textStorage length], 1)];
}


//---------------------------------------------------------------------------------------
//	interactive setup
//---------------------------------------------------------------------------------------

- (void)enterSetUpModeWithListener:(id)anObject
{
    [window setShowsDecorations:YES];
    setupListener = anObject;
    [[NSNotificationCenter defaultCenter] addObserver:setupListener selector:@selector(windowDidMove:) name:NSWindowDidMoveNotification object:window];
    [[NSNotificationCenter defaultCenter] addObserver:setupListener selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:window];
}


- (void)leaveSetUpMode
{
    [window setShowsDecorations:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:setupListener name:NSWindowDidMoveNotification object:window];
    [[NSNotificationCenter defaultCenter] removeObserver:setupListener name:NSWindowDidResizeNotification object:window];
    setupListener = NO;
}


//---------------------------------------------------------------------------------------
//	clear
//---------------------------------------------------------------------------------------

- (IBAction)clear:(id)sender
{
    NSTextStorage *textStorage;

    textStorage = [outputArea textStorage];
    [textStorage beginEditing];
    [textStorage deleteCharactersInRange:NSMakeRange(0, [textStorage length])];
    [textStorage endEditing];
    [outputArea scrollRangeToVisible:NSMakeRange(0, 1)];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
