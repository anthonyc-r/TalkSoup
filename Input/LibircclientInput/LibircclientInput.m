/***************************************************************************
                                LibircclientInput.m
                          -------------------
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

#import <TalkSoupBundles/TalkSoup.h>
#import <Foundation/Foundation.h>
#import <llibircclient.h>
#import "LibircclientInput.h"
#import "LibircclientConnection.h"
#import "LibircclientCallbacks.h"
#import "LibircclientConnection+Receivers.h"


@implementation LibircclientInput


- (id)init
{
  if ((self = [super init]))
  {
    connections = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  NSLog(@"dealloc input");
  [connections release];
  [super dealloc];
}

- (LibircclientInput *)initiateConnectionToHost: (NSHost *)aHost onPort: (int)aPort
   withTimeout: (int)seconds withNickname: (NSString *)nickname 
   withUserName: (NSString *)user withRealName: (NSString *)realName 
   withPassword: (NSString *)password withIdentification: (NSString *)ident 
{
  NSLog(@"initiate con to host");
  irc_callbacks_t callbacks;
  memset(&callbacks, 0, sizeof(callbacks));
  callbacks.event_connect = event_connect;
  callbacks.event_numeric = event_numeric;
  callbacks.event_notice = event_notice;
  callbacks.event_topic = event_topic;
  callbacks.event_channel_notice = event_channel_notice;
  callbacks.event_channel = event_channel;
  callbacks.event_join = event_join;
  callbacks.event_ctcp_req = event_ctcp_req;
  callbacks.event_ctcp_rep = event_ctcp_rep;
  callbacks.event_mode = event_mode;
  callbacks.event_umode = event_umode;
  callbacks.event_part = event_part;
  callbacks.event_quit = event_quit;
  callbacks.event_nick = event_nick;
  callbacks.event_kick = event_kick;
  callbacks.event_privmsg = event_prvmsg;
  irc_session_t *irc_session = irc_create_session(&callbacks);
  if (!irc_session) 
  {
    NSLog(@"irc_Create_session failed, returning nil.");
    return self;
  }
  irc_option_set(irc_session, LIBIRC_OPTION_STRIPNICKS);
  irc_option_set(irc_session, LIBIRC_OPTION_SSL_NO_VERIFY);
  NSLog(@"irc_create_session succeeded");
  LibircclientConnection *con = [[LibircclientConnection alloc] 
    initWithSession: irc_session nickname: nickname 
    withUserName: user withRealName: realName
    withPassword: password withIdentification: ident onPort: aPort
    withControl: self];
  AUTORELEASE(con);
  NSString *addr = [aHost address];
  BOOL connectionBad = irc_connect(irc_session, [addr UTF8String], aPort,
    [password UTF8String], [nickname UTF8String], [user UTF8String], [realName UTF8String]);
  if (connectionBad) 
  {
    NSLog(@"irc_connect failed: %s", 
      irc_strerror(irc_errno(irc_session)));
  }
  NSLog(@"connect ok to host %@", aHost);
  [connections addObject: con];
  [con connectionReceived];
  return self;
}

- (NSArray *)connections 
{
  NSLog(@"connections");
  return connections;
}

- (void)closeConnection: (id)connection
{
  [[connection retain] autorelease];
  if ([connections containsObject: connection])
  {
    [_TS_ lostConnection: connection withNickname: S2AS([connection nick])
      sender: self];
    [connections removeObject: connection];
    irc_disconnect([connection ircSession]);
  }
  else
  {
    NSLog(@"Attempt to close connection we're not aware of");
  }
}

@end
