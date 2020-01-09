/***************************************************************************
                                LibircClientConnection.m
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
#import "LibircclientConnection.h"
#import "LibircclientCallbacks.h"

@implementation LibircclientConnection

+ (void)initialize
{
  init_libircclient_callbacks();
}

- (LibircclientConnection *)initWithSession: (irc_session_t*)session nickname:
   (NSString *)aNick withUserName: (NSString *)user
   withRealName: (NSString *)real withPassword: (NSString *)aPass
   withIdentification: (NSString *)ident onPort: (int)aPort
   withControl: plugin;
{
  NSLog(@"connection initwith nickame");
  if ((self = [super init]))
  {
    set_object_for_session(self, session);
    ircSession = session;
    identification = RETAIN(ident);
    port = aPort;
    control = plugin;
    
    nick = aNick;
    RETAIN(nick);
    password = aPass;
    RETAIN(password);
    realName = real;
    RETAIN(realName);
    userName = user;
    RETAIN(user);
    lowercasingSelector = @selector(lowercaseIRCString);
  }
  return self;
}

/*
- (void)dealloc
{
    [SESSIONS removeObjectForKey: [NSNumber numberWithUnsignedInt:
      (uintptr_t)ircSession]];
    RELEASE(nick);
    RELEASE(password);
    RELEASE(userName);
    RELEASE(realName);
    [super dealloc];
}*/

- (void)startNetworkLoop
{
  irc_run(ircSession);
  int err = irc_errno(ircSession);
  NSLog(@"error in run loop num %s", irc_strerror(err));
  RELEASE(errorMessage);
  errorMessage = RETAIN([NSString stringWithCString: irc_strerror(err)]);
  [_TS_ lostConnection: self withNickname: S2AS(nick) sender: control];
  isConnected = NO;
}

- (NSString *)errorMessage 
{
  return errorMessage;
}

- (NSString *)identification 
{
  return identification;
}

- (int)port 
{
  return port;
}

- (NSHost *)remoteHost 
{
  return nil;
}

- (NSHost *)localHost {
  return nil;
}

- (irc_session_t*)ircSession
{
  return ircSession;
}

- (LibircclientConnection *)connectingStarted: (NSObject *)aConnection 
{
  return self;
}

- (LibircclientConnection *)connectingFailed: (NSString *)error 
{
  return nil;
}

- (id) connectionEstablished: (id)aTransport;
{
  return self;
}

- (void)connectionLost
{
}

- (id)setLowercasingSelector: (SEL)aSelector
{
  lowercasingSelector = aSelector;
  return self;
}

- (SEL)lowercasingSelector
{
  return lowercasingSelector;
}

- (NSComparisonResult)caseInsensitiveCompare: (NSString *)aString1
   to: (NSString *)aString2
{
  return ([(NSString *)[aString1 performSelector: lowercasingSelector] compare: 
    [aString2 performSelector: lowercasingSelector]]);
}

- (id)setNick: (NSString *)aNickname
{
  RELEASE(nick);
  nick = aNickname;
  RETAIN(nick);
  return self;
}

- (NSString *)nick
{
  return nick;
}

- (id)setUserName: (NSString *)aUser
{
  RELEASE(userName);
  userName = aUser;
  RETAIN(userName);
  return self;
}
- (NSString *)userName
{
  return userName;
}

- (id)setRealName: (NSString *)aRealName
{
  RELEASE(realName);
  realName = aRealName;
  RETAIN(realName);
  return self;
}

- (NSString *)realName
{
  return realName;
}

- (id)setPassword: (NSString *)aPass
{
  RETAIN(aPass);
  RELEASE(password);
  password = aPass;
  return self;
}

- (NSString *)password
{
  return password;
}

- (NSString *)errorString
{
  return errorMessage;
}

- (BOOL)connected
{
  return isConnected;
}

- (id)setEncoding: (NSStringEncoding)aEncoding
{
  return self;
}

- (id)setEncoding: (NSStringEncoding)aEncoding forTarget: (NSString *)aTarget
{
  return self;
}

- (NSStringEncoding)encoding
{
  return defaultEncoding;
}

- (NSStringEncoding)encodingForTarget: (NSString *)aTarget
{
  return defaultEncoding;
}

- (void)removeEncodingForTarget: (NSString *)aTarget
{
}

- (NSArray *)targetsWithEncodings
{
  return [NSArray array];//NSAllMapTableKeys(targetToEncoding);
}

// IRC Actions

- (LibircclientConnection *)joinChannel: (NSAttributedString *)channel 
   withPassword: (NSAttributedString *)aPassword 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPluging
{
  NSLog(@"join channel");
  [_TS_ joinChannel: channel withPassword: aPassword onConnection: self
    withNickname: aNick sender: control];
  if(irc_cmd_join(ircSession, [[channel string] UTF8String], 0))
  {
    NSLog(@"Error joining channel");
  }
  return self;
}

- (id)sendCTCPReply: (NSAttributedString *)aCTCP 
  withArgument: (NSAttributedString *)args to: (NSAttributedString *)aPerson
  onConnection: aConnection withNickname: (NSAttributedString *)aNick 
  sender: aPlugin
{
  NSString *reply = [NSString stringWithFormat: @"%@ %@", [aCTCP string],
    [args string]];
  NSLog(@"sendCTCPReply-long: %@", reply);
  [_TS_ sendCTCPReply: aCTCP withArgument: args to: aPerson onConnection: self
    withNickname: aNick sender: control];
  BOOL failed = irc_cmd_ctcp_reply(ircSession, [[aNick string] UTF8String],
    [reply UTF8String]);
  if (failed)
  {
    NSLog(@"error replying to ctcp");
  }
  return self;
}

- (id)partChannel: (NSAttributedString *)channel 
   withMessage: (NSAttributedString *)aMessage onConnection: aConnection
   withNickname: (NSAttributedString *)aNick sender: aPlugin
{
  NSLog(@"partChannel-long");
  [_TS_ partChannel: channel withMessage: aMessage onConnection: self
    withNickname: aNick sender: control];
  if (irc_cmd_part(ircSession, [[channel string] UTF8String]))
  {
    NSLog(@"error parting channel");
  }
  return self;
}

- (id)sendMessage: (NSAttributedString *)message to: (NSAttributedString *)receiver onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin
{
  NSLog(@"sendMessage-long");
  [_TS_ sendMessage: message to: receiver onConnection: self withNickname: 
    aNick sender: control];
  BOOL failed = irc_cmd_msg(ircSession, [[receiver string] UTF8String],
    [[message string] UTF8String]);
  if (failed)
  {
    NSLog(@"error sending message");
  } 
  return self;
}

- (id)listChannel: (NSAttributedString *)aChannel onServer: (NSAttributedString *)aServer onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin
{
  const char *channel = [[aChannel string] UTF8String]; 
  if (irc_cmd_list(ircSession, channel))
  {
    NSLog(@"Failed to get channel list");
  }
  return self;
}

// aMode and anObject seem to be the other way around to what you'd expect.
- (id)setMode: (NSAttributedString *)aMode on: (NSAttributedString *)anObject 
   withParams: (NSArray *)list onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
  NSString *target = [aMode string];
  NSMutableString *mode = [[anObject string] mutableCopy];
  for (int i = 0; i < [list count]; i++)
  {
    [mode appendFormat: @" %@", [[list objectAtIndex: i] string]];
  }
  BOOL error = irc_cmd_channel_mode(ircSession, [target UTF8String], 
    [mode UTF8String]);
  if (error)
  {
    NSLog(@"Failed to set mode");
  }
  return self;
}

@end

// MARK: - Misc requirements
@implementation NSString (IRCAddition)

- (NSString *)lowercaseIRCString
{
  //NSLog(@"lowercaseIRCString self=%@", self);
  NSMutableString *aString = [NSMutableString 
      stringWithString: [self lowercaseString]];
  NSRange aRange = {0, [aString length]};

  [aString replaceOccurrencesOfString: @"[" withString: @"{" options: 0
    range: aRange];
  [aString replaceOccurrencesOfString: @"]" withString: @"}" options: 0
    range: aRange];
  [aString replaceOccurrencesOfString: @"\\" withString: @"|" options: 0
    range: aRange];
  [aString replaceOccurrencesOfString: @"~" withString: @"^" options: 0
    range: aRange];
  return [aString lowercaseString];
}

- (NSString *)lowercaseStrictRFC1459IRCString
{
  //NSLog(@"lowercaseStrictRFC1459IRCString self=%@", self);
  NSMutableString *aString = [NSMutableString 
    stringWithString: [self lowercaseString]];
  NSRange aRange = {0, [aString length]};

  [aString replaceOccurrencesOfString: @"[" withString: @"{" options: 0
    range: aRange];
  [aString replaceOccurrencesOfString: @"]" withString: @"}" options: 0
    range: aRange];
  [aString replaceOccurrencesOfString: @"\\" withString: @"|" options: 0
    range: aRange];
	
  return [aString lowercaseString];
}
@end
