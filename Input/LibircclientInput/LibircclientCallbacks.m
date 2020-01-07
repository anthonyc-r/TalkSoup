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

@interface NSObject (private)
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2;
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2 andObject: (void*)object3;
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2 andObject: (void*)object3 andObject: (void*)object4;
@end
@implementation NSObject (private)
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2 andObject: (void*)object3
{
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [self methodSignatureForSelector: aSelector]];
  [inv setSelector: aSelector];
  [inv setTarget: self];
  [inv setArgument: (void*)&(object1) atIndex: 2];
  [inv setArgument: (void*)&(object2) atIndex: 3];
  [inv setArgument: (void*)&(object3) atIndex: 4];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
}
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2
{
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [self methodSignatureForSelector: aSelector]];
  [inv setSelector: aSelector];
  [inv setTarget: self];
  [inv setArgument: (void*)&(object1) atIndex: 2];
  [inv setArgument: (void*)&(object2) atIndex: 3];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
}
- (void)performSelectorOnMainThread: (SEL)aSelector withObject: (void*)object1 andObject: (void*)object2 andObject: (void*)object3 andObject: (void*)object4;
{
  NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
    [self methodSignatureForSelector: aSelector]];
  [inv setSelector: aSelector];
  [inv setTarget: self];
  [inv setArgument: (void*)&(object1) atIndex: 2];
  [inv setArgument: (void*)&(object2) atIndex: 3];
  [inv setArgument: (void*)&(object3) atIndex: 4];
  [inv setArgument: (void*)&(object4) atIndex: 5];
  [inv performSelectorOnMainThread: @selector(invoke) withObject: nil
    waitUntilDone: YES];
}
@end

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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(noticeReceived:to:from:) withObject: (id)notice andObject:
    (id)params[0] andObject: (id)origin];
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
  [object_for_session(session) performSelectorOnMainThread:
    @selector(topicReceived:onChannel:from:) withObject: (id)topic
    andObject: (id)params[0] andObject: (id)origin];
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
  [object_for_session(session) performSelectorOnMainThread:
    @selector(channelReceived:onChannel:from:) withObject: (id)message
    andObject: (id)params[0] andObject: (id)origin];
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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(channelNoticeReceived:onChannel:from:) withObject: (id)notice
    andObject: (id)params[0] andObject: (id)from];
  [pool release];
}

void event_numeric(irc_session_t *session, unsigned int event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event numeric!!");
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(numericReceived:from:withParams:count:) withObject: 
    [NSNumber numberWithInt: event] andObject:(id)origin andObject: 
    params andObject: [NSNumber numberWithInt: count]];
  [pool release];
}

void event_join(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_join");
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(joinReceived:from:) withObject: (id)params[0] andObject:
    (id)origin];
  [pool release];
}

void event_ctcp_req(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_join");
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(ctcpReqReceived:from:) withObject: (id)params[0] andObject:
    (id)origin];
  [pool release];
}

void event_ctcp_rep(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_join");
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(ctcpRepReceived:from:) withObject: (id)params[0] andObject:
    (id)origin];
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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(modeReceived:on:from:args:) withObject: (id)params[1]
    andObject: (id)params[0] andObject: (id)origin andObject: (id)args];
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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(partReceivedOnChannel:from:withReason:) withObject:
    (id)params[0] andObject: (id)origin andObject: (id)reason];
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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(quitReceived:from:) withObject: (id)reason andObject:
    (id)origin];
  [pool release];
}

void event_nick(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"event_nick");
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(nickReceived:from:) withObject: (id)params[0] andObject:
    (id)origin];
  [pool release];
}

void event_umode(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event_umode handing to event_mode");
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
  [object_for_session(session) performSelectorOnMainThread: 
    @selector(kickReceived:onChannel:byKicker:withReason:) withObject:
    (id)kickTarget andObject: (id)params[0] andObject: (id)origin andObject:
    (id)reason];
  [pool release];
}


void event_prvmsg(irc_session_t *session, const char *event, const char *origin, const char **params, unsigned int count)
{
  NSLog(@"event_prvmsg - passing to event_channel");
  event_channel(session, event, origin, params, count);
}
