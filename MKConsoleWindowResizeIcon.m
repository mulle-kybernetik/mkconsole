//
//  MKConsoleWindowResizeIcon.m
//  MkConsole
//
//  Created by znek on Mon Mar 03 2003.
//  $Id: MKConsoleWindowResizeIcon.m,v 1.1 2003-03-08 21:59:27 erik Exp $
//
//  Copyright (c) 2003 by Mulle Kybernetik. All rights reserved.
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

#include "MKConsoleWindowResizeIcon.h"


@implementation MKConsoleWindowResizeIcon

- (void)drawRect:(NSRect)aRect
{
    NSColor *backgroundColor;

    backgroundColor = [[self window] backgroundColor];
    backgroundColor = [backgroundColor shadowWithLevel:0.3];
    [backgroundColor set];
    NSRectFill(aRect);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint origin;
    NSSize size;

    origin = [[self window] frame].origin;
    size = [[self window] frame].size;

    [[self window] setFrame:NSMakeRect(origin.x, origin.y - [theEvent deltaY] , size.width + [theEvent deltaX], size.height + [theEvent deltaY]) display:YES];
}

@end
