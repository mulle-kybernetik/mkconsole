//---------------------------------------------------------------------------------------
//  ElementController.m created by erik on Mon Nov 17 2003
//  @(#)$Id: ElementController.m,v 1.1 2004-01-23 22:12:01 erik Exp $
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

#import <Cocoa/Cocoa.h>
#import "WindowManager.h"
#import "ElementController.h"


//---------------------------------------------------------------------------------------
    @implementation ElementController
//---------------------------------------------------------------------------------------

- (WindowManager *)windowManager
{
    return windowManager;
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [NSColor setIgnoresAlpha:NO];
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    windowManager = [[WindowManager alloc] init];
    [windowManager rebuildWindowControllers];

    listenConnection = [[NSConnection defaultConnection] retain];
    [listenConnection registerName:@"MkConsole"];
    [listenConnection setRootObject:windowManager];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    [listenConnection setRootObject:nil];
    [listenConnection release];

    [windowManager destroyWindowControllers];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
