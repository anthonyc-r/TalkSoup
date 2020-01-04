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
#import <libircclient.h>
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
    initWithSession: irc_session nickname: @"testyolo420swag" 
    withUserName: user withRealName: realName
    withPassword: password withIdentification: ident onPort: aPort
    withControl: self];
  AUTORELEASE(con);
  NSString *sslHost = [[NSString alloc] initWithFormat: @"%@",
    [aHost address]]; 
  BOOL connectionBad = irc_connect(irc_session, [sslHost UTF8String],
    aPort, 0, [nickname UTF8String], [user UTF8String],
    [realName UTF8String]);
  if (connectionBad) 
  {
    NSLog(@"irc_connect failed %s", irc_strerror(irc_errno(irc_session)));
    return self;
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

@end