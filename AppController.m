//---------------------------------------------------------------------------------------
//  AppController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: AppController.m,v 1.5 2003-11-15 17:37:29 erik Exp $
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
#import "MKConsoleWindowController.h"
#import "PreferencesController.h"
#import "AppController.h"


//---------------------------------------------------------------------------------------
    @implementation AppController
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    [NSColor setIgnoresAlpha:NO];
    windowControllerList = [[NSMutableArray alloc] init];
    return self;
}


- (NSArray *)windowControllerList
{
    return windowControllerList;
}


- (void)rebuildWindowControllers
{
    MKConsoleWindowController	*windowController;
    NSEnumerator				*windowSettingsEnum;
    NSDictionary				*windowSettings;

    [windowControllerList makeObjectsPerformSelector:@selector(stop)];
    [windowControllerList removeAllObjects];

    windowSettingsEnum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Windows"] objectEnumerator];
    while((windowSettings = [windowSettingsEnum nextObject]) != nil)
        {
        windowController = [[[MKConsoleWindowController alloc] initWithSettings:windowSettings] autorelease];
        [windowControllerList addObject:windowController];
        }
    [windowControllerList makeObjectsPerformSelector:@selector(start)];
}    


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self rebuildWindowControllers];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    [windowControllerList makeObjectsPerformSelector:@selector(stop)];
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
