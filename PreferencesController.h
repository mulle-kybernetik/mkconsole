//---------------------------------------------------------------------------------------
//  PreferencesController.h created by erik on Sat Feb 01 2003
//  @(#)$Id: PreferencesController.h,v 1.1 2003-02-02 20:59:37 erik Exp $
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


@interface PreferencesController : NSObject
{
    NSMutableArray			*filenames;
    IBOutlet NSPanel		*panel;
    IBOutlet NSFormCell		*frameXField;
    IBOutlet NSFormCell		*frameYField;
    IBOutlet NSFormCell		*frameWField;
    IBOutlet NSFormCell		*frameHField;
    IBOutlet NSColorWell	*textColorWell;
    IBOutlet NSTableView	*fileTableView;
}

+ (id)sharedInstance;

- (IBAction)showWindow:(id)sender;

- (IBAction)revealSelectedFilesInFinder:(id)sender;
- (IBAction)removeSelectedFiles:(id)sender;

- (IBAction)applyChanges:(id)sender;
- (IBAction)discardChanges:(id)sender;
- (IBAction)acceptChanges:(id)sender;

@end