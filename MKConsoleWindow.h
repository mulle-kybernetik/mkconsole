//---------------------------------------------------------------------------------------
//  MKConsoleWindow.h created by erik on Sat Jun 29 2002
//  @(#)$Id: MKConsoleWindow.h,v 1.4 2004-02-15 18:55:05 erik Exp $
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

#import <AppKit/AppKit.h>

@class MKConsoleWindowDragBar;
@class MKConsoleWindowResizeIcon;


@interface MKConsoleWindow : NSWindow
{
    MKConsoleWindowDragBar		*dragBar;
    MKConsoleWindowResizeIcon	*resizeIcon;
    IBOutlet NSTextView			*outputArea;
}

- (void)setClickThrough:(BOOL)clickThrough;
- (void)setSticky:(BOOL)flag;
- (void)setShowsDecorations:(BOOL)flag;

@end
