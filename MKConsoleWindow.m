//---------------------------------------------------------------------------------------
//  MKConsoleWindow.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindow.m,v 1.1.1.1 2002-12-02 23:57:12 erik Exp $
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
#import "MKConsoleWindow.h"


//---------------------------------------------------------------------------------------
    @implementation MKConsoleWindow
//---------------------------------------------------------------------------------------

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:flag];
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


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
