//---------------------------------------------------------------------------------------
//  EDApplication.m created by erik on Sun 19-Jul-1998
//  @(#)$Id: EDApplication.m,v 1.1 2003-02-19 20:45:09 erik Exp $
//
//  Copyright (c) 1998 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "EDApplication.h"

@interface EDApplication(PrivateAPI)
+ (void)reportException:(NSException *)theException;
- (void)registerFactoryDefaults;
@end

void EDUncaughtExceptionHandler(NSException *exception);

#define LS_TOPLEVEL_EXCEPTION(APPNAME, EXNAME, EXREASON) \
[NSString stringWithFormat:NSLocalizedString(@"An unexpected error has occured which may cause %@ to malfunction. You may want to save copies of your open documents and quit %@.\n\n%@: %@", "Text for the alert panel to report uncaught exceptions."), APPNAME, APPNAME, EXNAME, EXREASON]

#define LS_OK \
NSLocalizedString(@"Such is life", "For buttons unexpected error panel.")


//---------------------------------------------------------------------------------------
    @implementation EDApplication
//---------------------------------------------------------------------------------------

/*" This class provides no callable methods (they are in the NSApplication category in this framework) but setting the main application class is  to EDApplication makes factory defaults automatic and will also ensure that some feedback is provided to the user if an exception comes through uncaught. (Not that the user can't do anything about it but they can be warned to save their work and quit the application.) It also sets the uncaught exception handler so that it can be retrieved and used it if necessary.

Setting of the factory defaults uses the #registerFactoryDefaults method and happens just before #applicationWillFinishLaunching is called."*/


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- init
{
    [super init];
    NSSetUncaughtExceptionHandler(EDUncaughtExceptionHandler);
    return self;
}


- (void)finishLaunching
{
    [self registerFactoryDefaults];
    [super finishLaunching];
}


- (void)reportException:(NSException *)theException
{
    [[self class] reportException:theException];
}


+ (void)reportException:(NSException *)theException
{
    NSLog(@"%@: %@", [theException name], [theException reason]);
    NSRunAlertPanel(nil, LS_TOPLEVEL_EXCEPTION([[NSProcessInfo processInfo] processName], [theException name], [theException reason]), LS_OK, nil, nil);
}


//---------------------------------------------------------------------------------------
//	HELPER
//---------------------------------------------------------------------------------------

- (void)registerFactoryDefaults
{
    NSString		*resourcePath;
    NSDictionary	*factorySettings;

    resourcePath = [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"];
    NSAssert(resourcePath != nil, @"missing resource; cannot find FactoryDefaults");
    NS_DURING
        factorySettings = [[NSString stringWithContentsOfFile:resourcePath] propertyList];
    NS_HANDLER
        NSLog(@"error reading factory settings from %@:\n%@", resourcePath, localException);
        factorySettings = nil;
    NS_ENDHANDLER
    if([factorySettings isKindOfClass:[NSDictionary class]] == NO)
        [NSException raise:NSGenericException format:@"Damaged resource; FactoryDefaults does not contain a valid dictionary representation. Check Console for further information."];
    [[NSUserDefaults standardUserDefaults] registerDefaults:factorySettings];
}

//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------
//	EXCEPTION HANDLER
//---------------------------------------------------------------------------------------

void EDUncaughtExceptionHandler(NSException *exception)
{
    [EDApplication reportException:exception];
}

