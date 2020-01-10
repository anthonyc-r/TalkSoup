/***************************************************************************
                                LibircClientConnection.h
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

#import <Foundation/Foundation.h>
#import <libircclient.h>

@interface LibircclientConnection : NSObject
{
  irc_session_t *ircSession;
  NSString *identification;
  NSString *errorMessage;
  BOOL isConnected;
  int port;
  id control;
  NSStringEncoding defaultEncoding;
  NSString *nick;
  NSString *userName;
  NSString *realName;
  NSString *password;
  SEL lowercasingSelector;
}

- (LibircclientConnection *)initWithSession: (irc_session_t*)session nickname:
   (NSString *)aNick withUserName: (NSString *)user
   withRealName: (NSString *)real withPassword: (NSString *)aPass
   withIdentification: (NSString *)ident onPort: (int)aPort
   withControl: plugin;

- (NSString *)errorMessage;

- (NSString *)identification;

- (int)port;

- (NSHost *)remoteHost;

- (NSHost *)localHost;

- (irc_session_t*)ircSession;

- (LibircclientConnection *)connectingFailed: (NSString *)error;

- (LibircclientConnection *)connectingStarted: (NSObject *)aConnection;
- (id) connectionEstablished: (id)aTransport;

// IRC Actions

- (LibircclientConnection *)joinChannel: (NSAttributedString *)channel 
   withPassword: (NSAttributedString *)aPassword 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPluging;
   
- (id)partChannel: (NSAttributedString *)channel 
   withMessage: (NSAttributedString *)aMessage onConnection: aConnection
   withNickname: (NSAttributedString *)aNick sender: aPlugin;
   
- (id)sendCTCPReply: (NSAttributedString *)aCTCP 
  withArgument: (NSAttributedString *)args to: (NSAttributedString *)aPerson
  onConnection: aConnection withNickname: (NSAttributedString *)aNick 
  sender: aPlugin;
  
- (id)sendMessage: (NSAttributedString *)message to: (NSAttributedString *)receiver onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin;

- (id)listChannel: (NSAttributedString *)aChannel onServer: (NSAttributedString *)aServer onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin;
  
- (id)setMode: (NSAttributedString *)aMode on: (NSAttributedString *)anObject withParams: (NSArray *)list onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin;

- (id)sendAction: (NSAttributedString *)anAction to: (NSAttributedString *)receiver onConnection: aConnection withNickname: (NSAttributedString *)aNick sender: aPlugin;

@end

