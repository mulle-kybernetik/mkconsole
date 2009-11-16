//---------------------------------------------------------------------------------------
//  StatusItemMenuController.m created by erik on Mon Nov 16 2009
//  @(#)$Id: PreferencesController.h,v 1.6 2004-02-15 18:55:05 erik Exp $
//
//  Copyright (c) 2009 by Mulle Kybernetik. All rights reserved.
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

#import "StatusItemMenuController.h"


@implementation StatusItemMenuController

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];	
	[statusItem setImage:[NSImage imageNamed:@"mkconsole_m"]];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
}

@end
