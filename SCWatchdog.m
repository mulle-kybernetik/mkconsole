//---------------------------------------------------------------------------------------
//  SCWatchdog.m created by znek on Fri Jul 30 2004
//  @(#)$Id: SCWatchdog.m,v 1.1 2007-08-01 08:20:02 znek Exp $
//
//  Copyright (c) 2004 by Mulle Kybernetik. All rights reserved.
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

#include "SCWatchdog.h"
#import <SystemConfiguration/SystemConfiguration.h>

struct SCWatcherExtraInfoStructure {
  id  object;
  SEL selector;
};

void SysConfCallBackFunction(SCDynamicStoreRef store,
                             CFArrayRef changedKeys, void *info)
{
  struct SCWatcherExtraInfoStructure *extra;

  extra = (struct SCWatcherExtraInfoStructure *)info;
  [extra->object performSelector:extra->selector
                 withObject:(NSArray *)changedKeys];
}

@interface SCWatchdog (Private)
- (void)setup;
@end

@implementation SCWatchdog

NSString *SCWatchdogKeysDidChangeNotification  = @"SCWatchdogKeysDidChange";
NSString *SCWatchdogChangedKeysKey             = @"SCWatchdogChangedKeys";

- (id)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  struct SCWatcherExtraInfoStructure *info;
  SCDynamicStoreContext ctx = { 0, NULL, NULL, NULL, NULL };
  SCDynamicStoreRef     comRef;
  CFRunLoopSourceRef    scRunLoopSrc;
  CFRunLoopRef          ourCFRunLoop;
  Boolean               status;
  NSMutableArray        *keys;
  
  info = malloc(sizeof(struct SCWatcherExtraInfoStructure));
  if (info == NULL) {
    NSLog(@"Setup ExtraInfo Failure");
    return;
  }

  info->object   = self;
  info->selector = @selector(keysDidChange:);
  ctx.info = (void *)info;

  comRef = SCDynamicStoreCreate(NULL,
                                (CFStringRef)@"SCWatchdog",
                                SysConfCallBackFunction,
                                &ctx);

  if (comRef == NULL) {
    NSLog(@"Setup DSCM Failure");
    return;
  }

  keys = [NSMutableArray arrayWithCapacity:1];
  [keys addObject:(NSString *)SCDynamicStoreKeyCreate(NULL, 
                                     (CFStringRef)@"State:/Network/Global/IPv4")];
  
  status = SCDynamicStoreSetNotificationKeys(comRef, (CFArrayRef)keys, NULL);
  if (status == FALSE) {
    CFRelease(comRef);
    NSLog(@"!! Setup StoreNotification Failure");
    return;
  }

  scRunLoopSrc = SCDynamicStoreCreateRunLoopSource(NULL, comRef, (CFIndex)0);
  if (scRunLoopSrc == NULL) {
    CFRelease(comRef);
    NSLog(@"!! Setup RunLoop Failure");
    return;
  }

  ourCFRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
  CFRunLoopAddSource(ourCFRunLoop,
                     scRunLoopSrc,
                     kCFRunLoopDefaultMode);
}

/* SC notifications */

- (void)keysDidChange:(NSArray *)_changedKeys {
  NSNotificationCenter *nc;
  NSDictionary         *ui;

  ui = [NSDictionary dictionaryWithObjectsAndKeys:_changedKeys,
                                                  SCWatchdogChangedKeysKey,
                                                  nil];
  nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:SCWatchdogKeysDidChangeNotification
      object:self
      userInfo:ui];
}


@end
