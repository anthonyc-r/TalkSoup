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

- (BOOL)respondsToSelector: (SEL)aSelector
{
  //NSLog(@"respondsToSelector: %@",  NSStringFromSelector(aSelector));
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
  return nil;
}

- (NSString *)identification 
{
  NSLog(@"ident=%@", identification);
  return identification;
}

- (int)port 
{
  NSLog(@"port");
  return port;
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
