//---------------------------------------------------------------------------------------
//  AppController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: AppController.m,v 1.7 2007-08-01 08:20:02 znek Exp $
//
//  Copyright (c) 2002,2007,2009 by Mulle Kybernetik. All rights reserved.
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
#import "SCWatchdog.h"
#import "PreferencesController.h"
#import "AppController.h"


//---------------------------------------------------------------------------------------
    @implementation AppController
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
    sysconfWatchdog = [[SCWatchdog alloc] init];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
	[sysconfWatchdog release];
	[windowManager release];
}


- (void)openPreferences:(id)sender
{
    [[PreferencesController sharedInstance] showWindow:sender];
}


- (void)gotoHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.mulle-kybernetik.com/software/MkConsole/"]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
