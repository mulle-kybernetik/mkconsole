//---------------------------------------------------------------------------------------
//  MKLogbook.m created by erik on Sat Jun 29 2002
//  @(#)$Id: MKLogbook.m,v 1.1.1.1 2002-12-02 23:57:12 erik Exp $
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
#import "NSColor+Extensions.h"
#import "MKLogbook.h"


//---------------------------------------------------------------------------------------
    @implementation MKLogbook
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	init/dealloc
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];

    windowFrame = NSMakeRect(0, 0, 1024, 381);
    filenames = [[NSMutableArray alloc] init];
    textAttributes = [[NSMutableDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:[NSFont userFixedPitchFontOfSize:10], NSFontAttributeName, [NSColor colorForControlTint:NSDefaultControlTint], NSForegroundColorAttributeName, nil];
    return self;
}


- (id)initWithDictionary:(NSDictionary *)settings
{
    [super init];

    filenames = [NSMutableArray arrayWithArray:[settings objectForKey:@"Files"]];
    windowFrame = NSRectFromString([settings objectForKey:@"Frame"]);
    textAttributes = [[NSMutableDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:[NSFont fontWithName:[settings objectForKey:@"FontName"] size:[[settings objectForKey:@"FontSize"] floatValue]], NSFontAttributeName, [NSColor colorWithCalibratedStringRep:[settings objectForKey:@"TextColor"]], NSForegroundColorAttributeName, nil];

    return self;
}


- (void)dealloc
{
    [textAttributes release];
    [filenames release];
    [super dealloc];

}


//---------------------------------------------------------------------------------------
//	accessor methods
//---------------------------------------------------------------------------------------

- (void)resetChangeTracker
{
    hasChanges = NO;
}

- (BOOL)hasChanges
{
    return hasChanges;
}



- (void)setWindowFrame:(NSRect)aRect
{
    windowFrame = aRect;
    hasChanges = YES;
}

- (NSRect)windowFrame;
{
    return windowFrame;
}


- (void)addToFilenames:(NSString *)aFilename
{
    [filenames addObject:aFilename];
    hasChanges = YES;
}

- (void)removeFromFilenames:(NSString *)aFilename
{
    [filenames removeObject:aFilename];
    hasChanges = YES;
}

- (NSArray *)filenames
{
    return filenames;
}


- (void)setFont:(NSFont *)aFont
{
    [textAttributes setObject:aFont forKey:NSFontAttributeName];
    hasChanges = YES;
}

- (NSFont *)font
{
    return [textAttributes objectForKey:NSFontAttributeName];
}


- (void)setTextColor:(NSColor *)aColor
{
    [textAttributes setObject:aColor forKey:NSForegroundColorAttributeName];
    hasChanges = YES;
}

- (NSColor *)textColor
{
    return [textAttributes objectForKey:NSForegroundColorAttributeName];
}


- (NSDictionary *)textAttributes
{
    return textAttributes;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
