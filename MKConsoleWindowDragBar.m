//
//  MKConsoleWindowDragBar.m
//  MkConsole
//
//  Created by znek on Mon Mar 03 2003.
//  $Id: MKConsoleWindowDragBar.m,v 1.2 2003-03-09 22:04:58 erik Exp $
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

#import "MKConsoleWindowDragBar.h"


@implementation MKConsoleWindowDragBar

- (void)drawRect:(NSRect)aRect
{
    NSColor *backgroundColor;

    backgroundColor = [[self window] backgroundColor];
    backgroundColor = [backgroundColor shadowWithLevel:0.3];
    [backgroundColor set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint oldOrigin, newOrigin;

    oldOrigin = [[self window] frame].origin;
    newOrigin = NSMakePoint(oldOrigin.x + [theEvent deltaX], oldOrigin.y - [theEvent deltaY]);

    [[self window] setFrameOrigin:newOrigin];
}

@end
