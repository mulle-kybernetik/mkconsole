//---------------------------------------------------------------------------------------
//  PreferencesController.m created by erik on Sat Feb 01 2003
//  @(#)$Id: PreferencesController.m,v 1.12 2004-02-15 18:55:05 erik Exp $
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
#import "NSColor+Extensions.h"
#import "AppController.h"
#import "WindowManager.h"
#import "MKConsoleWindowController.h"
#import "PreferencesController.h"


@interface PreferencesController(PrivateAPI)
- (WindowManager *)_getWindowManager;
- (MKConsoleWindowController *)_getFirstConsoleWindowController;
- (void)_showSettings:(NSDictionary *)settings;
- (NSDictionary *)_getSettings;
@end


//---------------------------------------------------------------------------------------
    @implementation PreferencesController
//---------------------------------------------------------------------------------------

static PreferencesController *sharedInstance = nil;


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)sharedInstance
{
    if(sharedInstance == nil)
        sharedInstance = [[PreferencesController alloc] init];
    return sharedInstance;
}


//---------------------------------------------------------------------------------------
//	WINDOW MANAGEMENT
//---------------------------------------------------------------------------------------

- (IBAction)showWindow:(id)sender
{
    if(panel == nil)
        {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
        NSAssert(panel != nil, @"Problem with Preferences.nib");
        [self _showSettings:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Windows"] objectAtIndex:0]];
        [[self _getFirstConsoleWindowController] enterSetUpModeWithListener:self];
        }
    [panel makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
    [[self _getFirstConsoleWindowController] leaveSetUpMode];
    panel = nil;
}


- (void)awakeFromNib
{
    NSArray			*familyList;
    NSEnumerator	*familyEnum;
    NSString		*family;

    if(panel == nil)
        return;
    
    [fontFamilyPopup removeAllItems];
    familyList = [[[NSFontManager sharedFontManager] availableFontFamilies] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    familyEnum = [familyList objectEnumerator];
    while((family = [familyEnum nextObject]) != nil)
        {
        if(([family hasPrefix:@"."] == NO) && ([family hasPrefix:@"#"] == NO))
            [fontFamilyPopup addItemWithTitle:family];
        }

    [fileTableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}


//---------------------------------------------------------------------------------------
//	ACCESSING THE LOG WINDOW
//---------------------------------------------------------------------------------------

- (WindowManager *)_getWindowManager
{
    return [[[NSApplication sharedApplication] delegate] windowManager];
}


- (MKConsoleWindowController *)_getFirstConsoleWindowController
{
    NSArray *windowControllerList;
    
    windowControllerList = [[self _getWindowManager] windowControllerList];
    return [windowControllerList count] > 0 ? [windowControllerList objectAtIndex:0] : nil;
}


//---------------------------------------------------------------------------------------
//	READING/WRITING DEFAULTS
//---------------------------------------------------------------------------------------

- (void)_showSettings:(NSDictionary *)settings
{
    NSRect		frame;
    NSString	*fontname;

    frame = NSRectFromString([settings objectForKey:@"Frame"]);
    [frameXField setFloatValue:frame.origin.x];
    [frameYField setFloatValue:frame.origin.y];
    [frameWField setFloatValue:frame.size.width];
    [frameHField setFloatValue:frame.size.height];
    [textColorWell setColor:[NSColor colorWithCalibratedStringRep:[settings objectForKey:@"TextColor"]]];
    [backgroundColorWell setColor:[NSColor colorWithCalibratedStringRep:[settings objectForKey:@"BackgroundColor"]]];
    [floatCheckBox setState:[[settings objectForKey:@"Float"] isEqualToString:@"Yes"]];
    [exposeStickCheckBox setState:[[settings objectForKey:@"Sticky"] isEqualToString:@"Yes"]];

    filenames = [[settings objectForKey:@"Files"] mutableCopy];
    [fileTableView reloadData];
    fontname = [settings objectForKey:@"FontName"];
    [fontFamilyPopup selectItemWithTitle:[[NSFont fontWithName:fontname size:12] familyName]];
    [fontSizePopup selectItemWithTitle:[settings objectForKey:@"FontSize"]];
    [boldCheckBox setState:[[NSFontManager sharedFontManager] fontNamed:fontname hasTraits:NSBoldFontMask]];
    [italicCheckBox setState:[[NSFontManager sharedFontManager] fontNamed:fontname hasTraits:NSItalicFontMask]];
}


- (NSDictionary *)_getSettings
{
    NSMutableDictionary *settings;
    NSRect				frame;
    NSFont				*font;

    settings = [NSMutableDictionary dictionary];
    frame.origin.x = [frameXField floatValue];
    frame.origin.y = [frameYField floatValue];
    frame.size.width = [frameWField floatValue];
    frame.size.height = [frameHField floatValue];
    [settings setObject:NSStringFromRect(frame) forKey:@"Frame"];
    [settings setObject:[[textColorWell color] stringRep] forKey:@"TextColor"];
    [settings setObject:[[backgroundColorWell color] stringRep] forKey:@"BackgroundColor"];
    [settings setObject:([floatCheckBox state] == NSOnState) ? @"Yes" : @"No" forKey:@"Float"];
    [settings setObject:([exposeStickCheckBox state] == NSOnState) ? @"Yes" : @"No" forKey:@"Sticky"];
    [settings setObject:filenames forKey:@"Files"];
    font = [[NSFontManager sharedFontManager] fontWithFamily:[fontFamilyPopup titleOfSelectedItem] traits:0 weight:5 size:[[fontSizePopup titleOfSelectedItem] floatValue]];
    if([boldCheckBox state] == NSOnState)
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
    if([italicCheckBox state] == NSOnState)
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSItalicFontMask];
    NSLog(@"%s font = %@", __PRETTY_FUNCTION__, font);
    [settings setObject:[font fontName] forKey:@"FontName"];
    [settings setObject:[[NSNumber numberWithFloat:[font pointSize]] stringValue] forKey:@"FontSize"] ;

    return settings;
}


//---------------------------------------------------------------------------------------
//	TABLEVIEW DATASOURCE
//---------------------------------------------------------------------------------------

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [filenames count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [filenames objectAtIndex:rowIndex];
}


- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    [tableView setDropRow:((row == -1) ? [filenames count] : row) dropOperation:NSTableViewDropAbove];
    return NSDragOperationGeneric;
}


- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSArray			*draggedFilenames;
    NSEnumerator	*filenameEnum;
    NSString		*filename;
    int				previousRow;

    draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    filenameEnum = [draggedFilenames reverseObjectEnumerator];
    while((filename = [filenameEnum nextObject]) != nil)
        {
        if((previousRow = [filenames indexOfObject:filename]) != NSNotFound)
            {
            if(row > previousRow)
                row -= 1;
            [filenames removeObjectAtIndex:previousRow];
            }
        [filenames insertObject:filename atIndex:row];
        }
    [tableView reloadData];
    return YES;
}


- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
    NSMutableArray	*filenamesToDrag;
    NSEnumerator	*rowEnum;
    NSNumber		*rowIdx;

    filenamesToDrag = [NSMutableArray array];
    rowEnum = [rows objectEnumerator];
    while((rowIdx = [rowEnum nextObject]) != nil)
        [filenamesToDrag addObject:[filenames objectAtIndex:[rowIdx intValue]]];
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
    [pboard setPropertyList:filenamesToDrag forType:NSFilenamesPboardType];
    return YES;
}


- (BOOL)tableView:(NSTableView *)tableView handleKeyDownEvent:(NSEvent *)theEvent
{
    unichar	c = [[theEvent characters] characterAtIndex:0];
    if((c != NSDeleteFunctionKey) && (c != 127))
       return NO;
    [self removeSelectedFiles:self];
    return YES;
}


//---------------------------------------------------------------------------------------
//	MENU VALIDATION
//---------------------------------------------------------------------------------------

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    SEL action = [anItem action];

    if(action == @selector(revealSelectedFilesInFinder:) ||
       action == @selector(removeSelectedFiles:))
        return [fileTableView numberOfSelectedRows] > 0;

    return YES;
}


//---------------------------------------------------------------------------------------
//	WINDOW NOTIFICATIONS
//---------------------------------------------------------------------------------------

- (void)windowDidMove:(NSNotification *)notification
{
    if([notification object] == panel)
        return;
    [frameXField setFloatValue:[[notification object] frame].origin.x];
    [frameYField setFloatValue:[[notification object] frame].origin.y];
}


- (void)windowDidResize:(NSNotification *)notification
{
    if([notification object] == panel)
        return;
    [frameYField setFloatValue:[[notification object] frame].origin.y];
    [frameWField setFloatValue:[[notification object] frame].size.width];
    [frameHField setFloatValue:[[notification object] frame].size.height];
}


//---------------------------------------------------------------------------------------
//	ACTIONS
//---------------------------------------------------------------------------------------

- (IBAction)revealSelectedFilesInFinder:(id)sender
{
    int	row;
    
    if((row = [fileTableView selectedRow]) == -1)
        return NSBeep();
    [[NSWorkspace sharedWorkspace] selectFile:[filenames objectAtIndex:row] inFileViewerRootedAtPath:@"/"];
}


- (IBAction)removeSelectedFiles:(id)sender
{
    int	row;

    if((row = [fileTableView selectedRow]) == -1)
        return NSBeep();
    [filenames removeObjectAtIndex:row];
    [fileTableView reloadData];
}


- (IBAction)applyChanges:(id)sender
{
    NSMutableArray		*windowListDefault;
    NSMutableDictionary	*windowSettings;

    windowListDefault = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Windows"] mutableCopy];
    windowSettings = [[windowListDefault objectAtIndex:0] mutableCopy];
    [windowSettings addEntriesFromDictionary:[self _getSettings]];
    [windowListDefault replaceObjectAtIndex:0 withObject:windowSettings];
    [[NSUserDefaults standardUserDefaults] setObject:windowListDefault forKey:@"Windows"];
    [[NSUserDefaults standardUserDefaults] synchronize]; // in case wm is out-of proc
    [[self _getWindowManager] rebuildWindowControllers];
    [[self _getFirstConsoleWindowController] enterSetUpModeWithListener:self];
    [self _showSettings:windowSettings];
}


- (IBAction)discardChanges:(id)sender
{
    [[self _getWindowManager] rebuildWindowControllers];
    [panel close];
}


- (IBAction)acceptChanges:(id)sender
{

    [self applyChanges:self];
    [panel close];
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
