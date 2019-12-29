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
#import <Foundation/NSObject.h>
#import <libircclient.h>

@interface LibircclientInput : NSObject
	{
		irc_session_t *irc_session;
		NSMutableArray *connections;
	}

- (LibircclientInput *)initiateConnectionToHost: (NSHost *)aHost onPort: (int)aPort
   withTimeout: (int)seconds withNickname: (NSString *)nickname 
   withUserName: (NSString *)user withRealName: (NSString *)realName 
   withPassword: (NSString *)password withIdentification: (NSString *)ident;

- (NSArray *)connections;
@end

@interface LibircclientConnection : NSObject
	{
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

- (LibircclientConnection *)initWithNickname: (NSString *)aNick withUserName: (NSString *)user
   withRealName: (NSString *)real withPassword: (NSString *)aPass
   withIdentification: (NSString *)ident onPort: (int)aPort
   withControl: plugin;

- (LibircclientConnection *)connectingFailed: (NSString *)error;

- (LibircclientConnection *)connectingStarted: (NSObject *)aConnection;

- (NSString *)errorMessage;

- (NSString *)identification;

- (int)port;

- (NSHost *)remoteHost;

- (NSHost *)localHost;
@end


