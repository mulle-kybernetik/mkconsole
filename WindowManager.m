//---------------------------------------------------------------------------------------
//  WindowManager.m created by erik on Mon Nov 17 2003
//  @(#)$Id: WindowManager.m,v 1.1 2004-01-23 22:12:01 erik Exp $
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

#import "MKConsoleWindowController.h"
#import "WindowManager.h"


//---------------------------------------------------------------------------------------
    @implementation WindowManager
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    windowControllerList = [[NSMutableArray alloc] init];
    return self;
}


- (void)dealloc
{
    [windowControllerList release];
    [super dealloc];
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
        
    [self destroyWindowControllers];

    [[NSUserDefaults standardUserDefaults] synchronize];

    windowSettingsEnum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Windows"] objectEnumerator];
    while((windowSettings = [windowSettingsEnum nextObject]) != nil)
        {
        windowController = [[[MKConsoleWindowController alloc] initWithSettings:windowSettings] autorelease];
        [windowControllerList addObject:windowController];
        }
    [windowControllerList makeObjectsPerformSelector:@selector(start)];
}    


- (void)destroyWindowControllers
{
    [windowControllerList makeObjectsPerformSelector:@selector(stop)];
    [windowControllerList removeAllObjects];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
