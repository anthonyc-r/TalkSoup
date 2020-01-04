/***************************************************************************
                                main.m
                          -------------------
    begin                : Sat Jan 04 10:51:41 UTC 2020
    copyright            : (C) 2019 Anthony Conh-Richardby
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 
#import <Foundation/Foundation.h> 
#include "libircclient.h"
#import "LibircclientCallbacks.h"
#import "LibircclientConnection.h"
#import "LibircclientConnection+Receivers.h"
 
#define S2AS(_x) ( (_x) ? (NSAttributedString *)[[[NSAttributedString alloc] initWithString: (_x)] autorelease] : (NSAttributedString *)nil )
#define CS2S(_x) [NSString stringWithCString: _x]

static NSMutableDictionary *SESSIONS;

void init_libircclient_callbacks()
{
  SESSIONS = [NSMutableDictionary new];
}

LibircclientConnection *object_for_session(irc_session_t *session)
{
  id object = [SESSIONS objectForKey: [NSNumber numberWithUnsignedInt:
    (uintptr_t)session]];
  if (object == nil)
  {
    NSLog(@"Couldn't find object for irc_session");
  }
  return object;
}

void set_object_for_session(id object, irc_session_t *session)
{
    [SESSIONS setObject: object forKey: [NSNumber numberWithUnsignedInt:
      (uintptr_t)session]];
}

void event_connect(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event connect!!!");
  //[object_for_session(session) performSelectorOnMainThread: 
  //  @selector(connectionReceived) withObject: nil waitUntilDone: NO];
}

void event_notice(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event event_notice!!! from: %s", origin);
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if (count > 1) 
  {
    SEL selector = @selector(noticeReceived:to:from:);
    id target = object_for_session(session);
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
      [target methodSignatureForSelector: selector]];
    [inv setSelector: selector];
    [inv setTarget: target];
    [inv setArgument: (void*)&(params[1]) atIndex: 2];
    [inv setArgument: (void*)&(params[0]) atIndex: 3];
    [inv setArgument: (void*)&(origin) atIndex: 4];
    [inv performSelectorOnMainThread: @selector(invoke) withObject: nil waitUntilDone: 
      YES];
  }
  [pool release];
}

void event_topic(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event event_topic!!!");
}

void event_channel_notice(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event channel noticee");
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  SEL selector = @selector(noticeReceived:to:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  if (count > 1) 
  {
    [inv setArgument: (void*)&(params[1]) atIndex: 2];
  } 
  else
  {
    [inv setArgument: NULL atIndex: 0];

  }
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil waitUntilDone: YES];
  [pool release];
}

void event_channel(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event event_channel!!!");
}

void event_numeric(irc_session_t *session, unsigned int event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event numeric!!");
  SEL selector = @selector(numericReceived:from:withParams:count:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(event) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv setArgument: (void*)&(params) atIndex: 4];
  [inv setArgument: (void*)&(count) atIndex: 5];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil waitUntilDone: 
    YES];
  [pool release];
}
