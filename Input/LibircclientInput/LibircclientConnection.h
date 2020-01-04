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

- (LibircclientConnection *)connectingFailed: (NSString *)error;

- (LibircclientConnection *)connectingStarted: (NSObject *)aConnection;

- (id) connectionEstablished: (id)aTransport;
@end

