/***************************************************************************
                                main.m
                          -------------------
    begin                : Fri Dec 29 10:51:41 UTC 2019
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
#import "main.h"
#import "Recievers.h"

#define S2AS(_x) ( (_x) ? (NSAttributedString *)[[[NSAttributedString alloc] initWithString: (_x)] autorelease] : (NSAttributedString *)nil )
#define CS2S(_x) [NSString stringWithCString: _x]

static NSMutableDictionary *SESSIONS;

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
    NSLog(@"message: %s", params[1]);
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
  NSLog(@"event channel notice");
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

@implementation LibircclientInput

+ (void)initialize
{
  SESSIONS = [NSMutableDictionary new];
}

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
    initWithSession: irc_session nickname: nickname 
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

@implementation LibircclientConnection

- (LibircclientConnection *)initWithSession: (irc_session_t*)session nickname:
   (NSString *)aNick withUserName: (NSString *)user
   withRealName: (NSString *)real withPassword: (NSString *)aPass
   withIdentification: (NSString *)ident onPort: (int)aPort
   withControl: plugin;
{
  NSLog(@"connection initwith nickame");
  if ((self = [super init]))
  {
    [SESSIONS setObject: self forKey: [NSNumber numberWithUnsignedInt:
      (uintptr_t)session]];
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

- (void)dealloc
{
    [SESSIONS removeObjectForKey: [NSNumber numberWithUnsignedInt:
      (uintptr_t)ircSession]];
    RELEASE(nick);
    RELEASE(password);
    RELEASE(userName);
    RELEASE(realName);
    [super dealloc];
}

- (BOOL)respondsToSelector: (SEL)aSelector
{
  NSLog(@"respondsToSelector: %@",  NSStringFromSelector(aSelector));
  return [super respondsToSelector: aSelector];
}

- (void)startNetworkLoop
{
  irc_run(ircSession);
  int err = irc_errno(ircSession);
  NSLog(@"error in run loop num %s", irc_strerror(err));
}

- (NSString *)errorMessage 
{
  NSLog(@"err msg");
  return @"";
}

- (NSString *)identification 
{
  NSLog(@"ident=%@", identification);
  return identification;
}

- (int)port 
{
  NSLog(@"port");
  return 0;
}

- (NSHost *)remoteHost 
{
  NSLog(@"remote host");
  return nil;
}

- (NSHost *)localHost {
  NSLog(@"local host");
  return nil;
}

- (LibircclientConnection *)connectingStarted: (NSObject *)aConnection 
{
  NSLog(@"connectingStarted");
  return self;
}

- (LibircclientConnection *)connectingFailed: (NSString *)error 
{
  NSLog(@"con fail");
  return nil;
}

- (id) connectionEstablished: (id)aTransport;
{
  NSLog(@"connection established");
  
  return self;
}

- (LibircclientConnection *)joinChannel: (NSAttributedString *)channel 
   withPassword: (NSAttributedString *)aPassword 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPluging
{
  NSLog(@"join channel");
  return self;
}

// MARK: - outfilter protocol

- (void)connectionLost
{

}
- (id)setLowercasingSelector: (SEL)aSelector
{
  //NSLog(@"setLowercasingSelector");
  lowercasingSelector = aSelector;
  return self;
}
- (SEL)lowercasingSelector
{
  //NSLog(@"lowercasingSelector");
  return lowercasingSelector;
}
- (NSComparisonResult)caseInsensitiveCompare: (NSString *)aString1
   to: (NSString *)aString2
{
  //NSLog(@"caseInsensitiveCompare");
  return ([(NSString *)[aString1 performSelector: lowercasingSelector] compare: 
    [aString2 performSelector: lowercasingSelector]]);
}
- (id)setNick: (NSString *)aNickname
{
  //NSLog(@"setNick");
  RELEASE(nick);
  nick = aNickname;
  RETAIN(nick);
  return self;
}
- (NSString *)nick
{
  //NSLog(@"nick=%@", nick);
  return nick;
}
- (id)setUserName: (NSString *)aUser
{
  NSLog(@"setUserName");
  RELEASE(userName);
  userName = aUser;
  RETAIN(userName);
  return self;
}
- (NSString *)userName
{
  NSLog(@"userName");
  return userName;
}
- (id)setRealName: (NSString *)aRealName
{
  NSLog(@"setRealName");
  RELEASE(realName);
  realName = aRealName;
  RETAIN(realName);
  return self;
}
- (NSString *)realName
{
  NSLog(@"realName");
  return realName;
}
- (id)setPassword: (NSString *)aPass
{
  NSLog(@"setPassword");
  return self;
}
- (NSString *)password
{
  NSLog(@"password");
  return @"";// password;
}
- (NSString *)errorString
{
  NSLog(@"errorString");
  return @"";//errorString;
}

- (BOOL)connected
{
  NSLog(@"connected");
  return YES;//connected;
}
- (id)setEncoding: (NSStringEncoding)aEncoding
{
/*
	defaultEncoding = aEncoding;
	*/

  NSLog(@"setEncoding");
  return self;
}
- (id)setEncoding: (NSStringEncoding)aEncoding forTarget: (NSString *)aTarget
{
/*
	NSString *lower = [aTarget performSelector: lowercasingSelector];

	if (!lower) return self;

	NSMapInsert(targetToEncoding, lower, (void *)aEncoding);
	[targetToOriginalTarget setObject: aTarget forKey: lower];
*/
  NSLog(@"setEncoding");
  return self;
}
- (NSStringEncoding)encoding
{
  NSLog(@"encoding");
  return defaultEncoding;
}
- (NSStringEncoding)encodingForTarget: (NSString *)aTarget
{
  NSLog(@"encodingForTarget");
  return defaultEncoding;
	/*
	NSString *lower = [aTarget performSelector: lowercasingSelector];

	if (!lower) return defaultEncoding;

	return (NSStringEncoding)NSMapGet(targetToEncoding, lower);
*/
}
- (void)removeEncodingForTarget: (NSString *)aTarget
{
	/*
	NSString *lower = [aTarget performSelector: lowercasingSelector];

	if (!lower) return;

	NSMapRemove(targetToEncoding, lower);
	[targetToOriginalTarget removeObjectForKey: lower];
*/
  NSLog(@"removeEncodingForTarget");
}
- (NSArray *)targetsWithEncodings
{
  NSLog(@"targetsWithEncodings");
  return [NSArray array];//NSAllMapTableKeys(targetToEncoding);
}
- (id)changeNick: (NSString *)aNick
{
  NSLog(@"changeNick");
  return self;
}
- (id)quitWithMessage: (NSString *)aMessage
{
  NSLog(@"quitWithMessage");
  return self;
}
- (id)partChannel: (NSString *)aChannel withMessage: (NSString *)aMessage
{
  NSLog(@"partChannel");
  return self;
}
- (id)joinChannel: (NSString *)aChannel withPassword: (NSString *)aPassword
{
  NSLog(@"joinChannel");
  return self;
}
- (id)sendCTCPReply: (NSString *)aCTCP withArgument: (NSString *)args
   to: (NSString *)aPerson
{
  NSLog(@"sendCTCPReply");
  return self;
}
- (id)sendCTCPRequest: (NSString *)aCTCP withArgument: (NSString *)args
   to: (NSString *)aPerson
{
  NSLog(@"sendCTCPRequest");
  return self;
}
- (id)sendMessage: (NSString *)aMessage to: (NSString *)aReceiver
{
  NSLog(@"sendMessage");
  return self;
}
- (id)sendNotice: (NSString *)aNotice to: (NSString *)aReceiver
{
  NSLog(@"sendNotice");
  return self;
}
- (id)sendAction: (NSString *)anAction to: (NSString *)aReceiver
{
  NSLog(@"sendAction");
  return self;
}
- (id)becomeOperatorWithName: (NSString *)aName withPassword: (NSString *)aPassword
{
  NSLog(@"becomeOperatorWithName");
  return self;
}
- (id)requestNamesOnChannel: (NSString *)aChannel
{
  NSLog(@"requestNamesOnChannel");
  return self;
}
- (id)requestMOTDOnServer: (NSString *)aServer
{
  NSLog(@"requestMOTDOnServer");
  return self;
}
- (id)requestSizeInformationFromServer: (NSString *)aServer 
    andForwardTo: (NSString *)anotherServer
{
  NSLog(@"requestSizeInformationFromServer");
  return self;
}	
- (id)requestVersionOfServer: (NSString *)aServer
{
  NSLog(@"requestVersionOfServer");
  return self;
}
- (id)requestServerStats: (NSString *)aServer for: (NSString *)query
{
  NSLog(@"requestServerStats");
  return self;
}
- (id)requestServerLink: (NSString *)aLink from: (NSString *)aServer
{
  NSLog(@"requestServerLink");
  return self;
}
- (id)requestTimeOnServer: (NSString *)aServer
{
  NSLog(@"requestTimeOnServer");
  return self;
}
- (id)requestServerToConnect: (NSString *)aServer to: (NSString *)connectServer
                  onPort: (NSString *)aPort
{
  NSLog(@"requestServerToConnect");
  return self;
}
- (id)requestTraceOnServer: (NSString *)aServer
{
  NSLog(@"requestTraceOnServer");
  return self;
}
- (id)requestAdministratorOnServer: (NSString *)aServer
{
  NSLog(@"requestAdministratorOnServer");
  return self;
}
- (id)requestInfoOnServer: (NSString *)aServer
{
  NSLog(@"requestInfoOnServer");
  return self;
}
- (id)requestServerRehash
{
  NSLog(@"requestServerRehash");
  return self;
}
- (id)requestServerShutdown
{
  NSLog(@"requestServerShutdown");
  return self;
}
- (id)requestServerRestart
{
  NSLog(@"requestServerRestart");
  return self;
}
- (id)requestUserInfoOnServer: (NSString *)aServer
{
  NSLog(@"requestUserInfoOnServer");
  return self;
}
- (id)areUsersOn: (NSString *)userList
{
  NSLog(@"areUsersOn");
  return self;
}
- (id)sendWallops: (NSString *)aMessage
{
  NSLog(@"sendWallops");
  return self;
}
- (id)listWho: (NSString *)aMask onlyOperators: (BOOL)operators
{
  NSLog(@"listWho");
  return self;
}
- (id)whois: (NSString *)aPerson onServer: (NSString *)aServer
{
  NSLog(@"whois");
  return self;
}
- (id)whowas: (NSString *)aPerson onServer: (NSString *)aServer
      withNumberEntries: (NSString *)aNumber
{
  NSLog(@"whowas");
  return self;
}
- (id)kill: (NSString *)aPerson withComment: (NSString *)aComment
{
  NSLog(@"kill");
  return self;
}
- (id)setTopicForChannel: (NSString *)aChannel to: (NSString *)aTopic
{
  NSLog(@"setTopicForChannel");
  return self;
}
- (id)setMode: (NSString *)aMode on: (NSString *)anObject 
                     withParams: (NSArray *)aList
{
  NSLog(@"setMode");
  return self;
}
- (id)listChannel: (NSString *)aChannel onServer: (NSString *)aServer
{
  NSLog(@"listChannel");
  return self;
}
- (id)invite: (NSString *)aPerson to: (NSString *)aChannel
{
  NSLog(@"invite");
  return self;
}
- (id)kick: (NSString *)aPerson offOf: (NSString *)aChannel for: (NSString *)aReason
{
  NSLog(@"kick");
  return self;
}
- (id)setAwayWithMessage: (NSString *)aMessage
{
  NSLog(@"setAwayWithMessage");
  return self;
}
- (id)sendPingWithArgument: (NSString *)aString
{
  NSLog(@"sendPingWithArgument");
  return self;
}
- (id)sendPongWithArgument: (NSString *)aString
{
  NSLog(@"sendPongWithArgument");
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
