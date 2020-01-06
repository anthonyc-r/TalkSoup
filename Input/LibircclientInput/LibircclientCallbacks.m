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
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event event_notice from: %s", origin);
  char const *notice = "";
  if (count > 1)
  {
    notice = params[1];
  }
  SEL selector = @selector(noticeReceived:to:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(notice) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_topic(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event event_topic!!!");
  const char *topic = "";
  if (count > 1)
  {
    topic = params[1];
  }
  SEL selector = @selector(topicReceived:onChannel:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(topic) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_channel(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event event_channel!!!");
  const char *message = "";
  if (count > 1)
  {
    message = params[1];
  }
  SEL selector = @selector(channelReceived:onChannel:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(message) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_channel_notice(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_channel_notice!!!");
  const char *notice = "";
  const char *from = "";
  if (count > 1)
  {
    notice = params[1];
  }
  if (origin != NULL)
  {
    from = origin;
  }
  SEL selector = @selector(channelNoticeReceived:onChannel:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(notice) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(from) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
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
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_join(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_join");
  SEL selector = @selector(joinReceived:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[0]) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_ctcp_req(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_join");
  SEL selector = @selector(ctcpReqReceived:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[0]) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_mode(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_mode");
  const char *args = "";
  if (count > 2)
  {
    args = params[2];
  }
  SEL selector = @selector(modeReceived:on:from:args:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[1]) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  [inv setArgument: (void*)&(args) atIndex: 5];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_part(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_part");
  const char *reason = "quit";
  if (count > 1)
  {
    reason = params[1];
  }
  SEL selector = @selector(partReceivedOnChannel:from:withReason:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[0]) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv setArgument: (void*)&(reason) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_quit(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_quit");
  const char *reason = "quit";
  if (count > 0)
  {
    reason = params[0];
  }
  SEL selector = @selector(quitReceived:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(reason) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_nick(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_nick");
  SEL selector = @selector(nickReceived:from:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(params[0]) atIndex: 2];
  [inv setArgument: (void*)&(origin) atIndex: 3];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}

void event_umode(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event_umode handig to event_mode");
  event_mode(session, event, origin, params, count);
}

void event_kick(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_kick");
  const char *reason = "";
  const char *kickTarget = "";
  if (count > 1)
  {
    kickTarget = params[1];
  }
  if (count > 2)
  {
    reason = params[2];
  }
  SEL selector = @selector(kickReceived:onChannel:byKicker:withReason:);
  id target = object_for_session(session);
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [target methodSignatureForSelector: selector]];
  [inv setSelector: selector];
  [inv setTarget: target];
  [inv setArgument: (void*)&(kickTarget) atIndex: 2];
  [inv setArgument: (void*)&(params[0]) atIndex: 3];
  [inv setArgument: (void*)&(origin) atIndex: 4];
  [inv setArgument: (void*)&(reason) atIndex: 5];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
  [pool release];
}


void event_prvmsg(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event_prvmsg - passing to event_channel");
  event_channel(session, event, origin, params, count);
}
