//---------------------------------------------------------------------------------------
//  PreferencesController.m created by erik on Sat Feb 01 2003
//  @(#)$Id: PreferencesController.m,v 1.6 2003-02-22 23:57:30 erik Exp $
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
#import "PreferencesController.h"


@interface PreferencesController(PrivateAPI)
- (void)rebuildFontPopup;
- (void)showSettings:(NSDictionary *)settings;
- (NSDictionary *)getSettings;
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
        sharedInstance = [[[PreferencesController alloc] init] autorelease];
    return sharedInstance;
}


//---------------------------------------------------------------------------------------
//	DEALLOC
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    [super dealloc];
    sharedInstance = nil;
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
        [self retain];
        [self showSettings:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Windows"] objectAtIndex:0]];
        }
    [panel makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
    panel = nil;
    [self autorelease];
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
//	READING/WRITING DEFAULTS
//---------------------------------------------------------------------------------------

- (void)showSettings:(NSDictionary *)settings
{
    NSRect		frame;
    NSString	*fontname;

    frame = NSRectFromString([settings objectForKey:@"Frame"]);
    [frameXField setFloatValue:frame.origin.x];
    [frameYField setFloatValue:frame.origin.y];
    [frameWField setFloatValue:frame.size.width];
    [frameHField setFloatValue:frame.size.height];
    [textColorWell setColor:[NSColor colorWithCalibratedStringRep:[settings objectForKey:@"TextColor"]]];
    filenames = [[settings objectForKey:@"Files"] mutableCopy];
    [fileTableView reloadData];
    fontname = [settings objectForKey:@"FontName"];
    [fontFamilyPopup selectItemWithTitle:[[NSFont fontWithName:fontname size:12] familyName]];
    [fontSizePopup selectItemWithTitle:[settings objectForKey:@"FontSize"]];
    [boldCheckBox setState:[[NSFontManager sharedFontManager] fontNamed:fontname hasTraits:NSBoldFontMask]];
    [italicCheckBox setState:[[NSFontManager sharedFontManager] fontNamed:fontname hasTraits:NSItalicFontMask]];
}


- (NSDictionary *)getSettings
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
    [windowSettings addEntriesFromDictionary:[self getSettings]];
    [windowListDefault replaceObjectAtIndex:0 withObject:windowSettings];
    [[NSUserDefaults standardUserDefaults] setObject:windowListDefault forKey:@"Windows"];
    [[[NSApplication sharedApplication] delegate] rebuildWindowControllers];
    [self showSettings:windowSettings];
}


- (IBAction)discardChanges:(id)sender
{
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
