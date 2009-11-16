//---------------------------------------------------------------------------------------
//  MKConsoleWindowController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindowController.m,v 1.13 2007-08-01 08:20:02 znek Exp $
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
#import "NSScreen+Extensions.h"
#import "MKLogfileReader.h"
#import "MKConsoleWindow.h"
#import "MKConsoleWindowController.h"
#import "SCWatchdog.h"

@interface MKConsoleWindowController(PrivateAPI)
- (void)setWindowFrameCleverly;
- (void)_tryRead:(NSTimer *)sender;
- (void)_appendMessages:(NSArray *)messages;
- (void)_reopenReaders;
- (void)_screenParametersChanged:(NSNotification *)n;
- (void)_computerWokeUp:(NSNotification *)n;
@end


//---------------------------------------------------------------------------------------
    @implementation MKConsoleWindowController
//---------------------------------------------------------------------------------------

static BOOL noAlertOnOpenFailure = NO;

+ (void)initialize 
{
	noAlertOnOpenFailure = [[NSUserDefaults standardUserDefaults] boolForKey:@"NoAlertOnOpenFailure"];
}


//---------------------------------------------------------------------------------------
//	init/dealloc
//---------------------------------------------------------------------------------------

- (id)initWithSettings:(NSDictionary *)settings 
{
  NSNotificationCenter *nc;
  
  [super init];
  
  filenames      = [[settings objectForKey:@"Files"] retain];
  windowFrame    = NSRectFromString([settings objectForKey:@"Frame"]);
  textAttributes = [[NSDictionary allocWithZone:[self zone]]
                                  initWithObjectsAndKeys:[NSFont fontWithName:[settings objectForKey:@"FontName"] size:[[settings objectForKey:@"FontSize"] floatValue]], NSFontAttributeName, [NSColor colorWithCalibratedStringRep:[settings objectForKey:@"TextColor"]], NSForegroundColorAttributeName, nil];
  
  [NSBundle loadNibNamed:@"MKConsoleWindow" owner:self];
  NSAssert(window != nil, @"Problem with MKConsoleWindow.nib");

  [window setBackgroundColor:[NSColor colorWithCalibratedStringRep:[settings objectForKey:@"BackgroundColor"]]];
  if([[settings objectForKey:@"Float"] isEqualToString:@"Yes"])
	  [window setLevel:CGWindowLevelForKey(kCGDesktopIconWindowLevelKey) + 1];
  else
	  [window setLevel:CGWindowLevelForKey(kCGDesktopWindowLevelKey)];
  [window setSticky:[[settings objectForKey:@"Sticky"] isEqualToString:@"Yes"]];

  nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
      selector:@selector(_screenParametersChanged:)
      name:NSApplicationDidChangeScreenParametersNotification
      object:nil];
	[nc addObserver:self
      selector:@selector(_computerWokeUp:)
      name:NSWorkspaceDidWakeNotification
      object:nil];
	[nc addObserver:self
      selector:@selector(_computerWokeUp:)
      name:SCWatchdogKeysDidChangeNotification
      object:nil];
  
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

- (void)setWindowFrameCleverly 
{
	[window setFrame:windowFrame display:YES];

	if (![window screen]) 
	{
		/* previous NSScreen was detached in the meantime
		 * we workaround this situation by resetting the window's origin to some
		 * point that makes more sense.
		 */

		NSRect wf = windowFrame;
		wf.origin = [[NSScreen preferredScreen] visibleFrame].origin;
		[window setFrame:wf display:YES];
	}
}

- (void)awakeFromNib
{
    [self setWindowFrameCleverly];
    [[[outputArea superview] superview] setFrame:[[window contentView] frame]];
    [window orderFront:self];
}


- (void)_screenParametersChanged:(NSNotification *)n
{
    [self setWindowFrameCleverly];
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
            {
            [readerList addObject:reader];
            }
        else
            {
            if (noAlertOnOpenFailure)
              NSLog(@"Failed to open logfile at: %@", filename);
            else
              NSRunAlertPanel(nil, @"Failed to open logfile at: %@", @"Cancel", nil, nil, filename);
            }
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


- (void)_reopenReaders
{
	NSEnumerator	*readerEnum;
	MKLogfileReader	*reader;
	
	readerEnum = [readerList objectEnumerator];
	while((reader = [readerEnum nextObject]) != nil)
		{
		if([reader reopen] == NO)
			NSLog(@"%s failed for %@", __PRETTY_FUNCTION__, [reader filename]);
		}
}


- (void)_computerWokeUp:(NSNotification *)n
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self performSelector:@selector(_reopenReaders) withObject:nil afterDelay:5.0f];
}


//---------------------------------------------------------------------------------------
//	read
//---------------------------------------------------------------------------------------

- (void)_tryRead:(NSTimer *)sender
{
	NSMutableArray	 *messageList;
    NSString		 *message;
    NSEnumerator	*readerEnum;
    MKLogfileReader	*reader;	

    cycle = (cycle + 1) % [[[NSUserDefaults standardUserDefaults] objectForKey:@"ReopenFactor"] intValue];
    if(cycle == 0)
		[self _reopenReaders];
    
	messageList = [NSMutableArray array];
    readerEnum = [readerList objectEnumerator];
    while((reader = [readerEnum nextObject]) != nil)
        {
        while((message = [reader nextMessage]) != nil)
            [messageList addObject:message];
        }
	[self _appendMessages:messageList];
}


//---------------------------------------------------------------------------------------
//	read
//---------------------------------------------------------------------------------------

- (void)_appendMessages:(NSArray *)messages
{
    NSTextStorage 	 *textStorage;
    NSEnumerator	 *messageEnum;
    NSString		 *message;

	textStorage = [outputArea textStorage];
    [textStorage beginEditing];
    messageEnum = [messages objectEnumerator];
    while((message = [messageEnum nextObject]) != nil)
		{
        unsigned int location = [textStorage length];
        [textStorage replaceCharactersInRange:NSMakeRange(location, 0) withString:message];
        [textStorage setAttributes:textAttributes range:NSMakeRange(location, [textStorage length] - location)];
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
    setupListener = [anObject retain];
    [[NSNotificationCenter defaultCenter] addObserver:setupListener selector:@selector(windowDidMove:) name:NSWindowDidMoveNotification object:window];
    [[NSNotificationCenter defaultCenter] addObserver:setupListener selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:window];
}


- (void)leaveSetUpMode
{
    [window setShowsDecorations:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:setupListener name:NSWindowDidMoveNotification object:window];
    [[NSNotificationCenter defaultCenter] removeObserver:setupListener name:NSWindowDidResizeNotification object:window];
    [setupListener release];
    setupListener = nil;
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

