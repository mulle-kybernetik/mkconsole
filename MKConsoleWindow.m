//---------------------------------------------------------------------------------------
//  MKConsoleWindow.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindow.m,v 1.4 2003-11-16 18:33:29 erik Exp $
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
#import <Carbon/Carbon.h>
#import "MKConsoleWindow.h"
#import "MKConsoleWindowDragBar.h"
#import "MKConsoleWindowResizeIcon.h"


//---------------------------------------------------------------------------------------
    @implementation MKConsoleWindow
//---------------------------------------------------------------------------------------

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    NSAssert1(self != nil, @"%s Failed to create window instance", __PRETTY_FUNCTION__);
    return self;
}


- (void)awakeFromNib
{
    NSClipView		*clipView;
    NSScrollView 	*scrollView;

    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];
    [self setHasShadow:NO];
    [self setCanHide:NO];
    [self setAlphaValue:1.0];
    [self setIgnoresMouseEvents:YES];
    [self setLevel:CGWindowLevelForKey(kCGDesktopIconWindowLevelKey)];
    
    clipView = (NSClipView *)[outputArea superview];
    [clipView setDrawsBackground:NO];
    [clipView setCopiesOnScroll:NO];
    scrollView = (NSScrollView *)[clipView superview];
    [scrollView setDrawsBackground:NO];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setHasVerticalScroller:NO];
    [outputArea setDrawsBackground:NO];
}


- (void)setBackgroundColor:(NSColor *)color
{
    [super setBackgroundColor:color];
    [dragBar setNeedsDisplay:YES];
    [resizeIcon setNeedsDisplay:YES];
}


- (void)setShowsDecorations:(BOOL)flag
{
    if(flag)
        {
        NSRect	cvFrame, decFrame;

        if(dragBar != nil)
            return;
        [[self contentView] setAutoresizesSubviews:YES];
        cvFrame = [[self contentView] frame];
        decFrame = NSMakeRect(0, NSMaxY(cvFrame) - 12, NSWidth(cvFrame), 12);
        dragBar = [[[MKConsoleWindowDragBar allocWithZone:[self zone]] initWithFrame:decFrame] autorelease];
        [dragBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
        [[self contentView] addSubview:dragBar];
        decFrame = NSMakeRect(NSMaxX(cvFrame) - 12, 0, 12, 12);
        resizeIcon = [[[MKConsoleWindowResizeIcon allocWithZone:[self zone]] initWithFrame:decFrame] autorelease];
        [resizeIcon setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin];
        [[self contentView] addSubview:resizeIcon];
        [self setIgnoresMouseEvents:NO];
        }
    else
        {
        if(dragBar == nil)
            return;
        [dragBar removeFromSuperview];
        dragBar = nil;
        [resizeIcon removeFromSuperview];
        resizeIcon = nil;
        [self setIgnoresMouseEvents:YES];
        }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
