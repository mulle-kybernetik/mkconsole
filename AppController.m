//---------------------------------------------------------------------------------------
//  AppController.m created by erik on Sat Jun 29 2002
//  @(#)$Id: AppController.m,v 1.1.1.1 2002-12-02 23:57:12 erik Exp $
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
#import <EDCommon/EDCommon.h>
#import "MKLogbook.h"
#import "MKConsoleWindowController.h"
#import "AppController.h"


//---------------------------------------------------------------------------------------
    @implementation AppController
//---------------------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    MKLogbook					*logbook;
    MKConsoleWindowController	*windowController;
    NSEnumerator				*windowSettingsEnum;
    NSDictionary				*windowSettings;

    windowControllerList = [[NSMutableArray alloc] init];
    windowSettingsEnum = [[DEFAULTS objectForKey:@"Windows"] objectEnumerator];
    while((windowSettings = [windowSettingsEnum nextObject]) != nil)
        {
        logbook = [[[MKLogbook alloc] initWithDictionary:windowSettings] autorelease];
        windowController = [[[MKConsoleWindowController alloc] initWithLogbook:logbook] autorelease];
        [windowControllerList addObject:windowController];
        }

    [windowControllerList makeObjectsPerformSelector:@selector(start)];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    [windowControllerList makeObjectsPerformSelector:@selector(stop)];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
