/***************************************************************************
                                ServerListController.h
                          -------------------
    begin                : Wed Apr 30 14:31:01 CDT 2003
    copyright            : (C) 2005 by Andrew Ruder
                         : (C) 2013 The GNUstep Application Project
    email                : aeruder@ksu.edu
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

@class ServerListController;

@class NSString;

extern NSString *ServerListInfoWindowFrame;
extern NSString *ServerListInfoEncoding;
extern NSString *ServerListInfoServer;
extern NSString *ServerListInfoPort;
extern NSString *ServerListInfoName;
extern NSString *ServerListInfoEntries;
extern NSString *ServerListInfoCommands;
extern NSString *ServerListInfoAutoConnect;
extern NSString *ServerListInfoSSL;

#ifndef SERVER_LIST_CONTROLLER_H
#define SERVER_LIST_CONTROLLER_H

#import <Foundation/NSObject.h>

#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSUInteger
#define NSUInteger unsigned int
#endif
#ifndef NSInteger
#define NSInteger int
#endif
#endif

@class NSButton, NSBrowser, NSWindow, NSTableColumn, NSScrollView, NSArray;
@class NSDictionary, NSMutableArray;

@interface ServerListController : NSObject
	{
		NSButton *connectButton;
		NSButton *addGroupButton;
		NSButton *removeButton;
		NSButton *addEntryButton;
		NSButton *editButton;
		NSButton *forceButton;
		NSBrowser *browser;
		NSScrollView *scrollView;
		NSWindow *window;
		NSTableColumn *serverColumn;
		NSMutableArray *cached;
		id editor;
		int wasEditing;
	}
+ (BOOL)saveServerListPreferences: (NSArray *)aPrefs;
+ (NSMutableArray *)serverListPreferences;
+ (BOOL)startAutoconnectServers;
+ (void)setServer: (NSDictionary *)x inGroup: (NSInteger)group row: (NSInteger)row;
+ (NSDictionary *)serverInGroup: (NSInteger)group row: (NSInteger)row;

- (BOOL)saveServerListPreferences: (NSArray *)aPrefs;
- (NSMutableArray *)serverListPreferences;
- (BOOL)serverFound: (NSDictionary *)x inGroup: (NSInteger *)group row: (NSInteger *)row;

- (void)editHit: (NSButton *)sender;
- (void)addEntryHit: (NSButton *)sender;
- (void)removeHit: (NSButton *)sender;
- (void)connectHit: (NSButton *)sender;
- (void)addGroupHit: (NSButton *)sender;
- (void)forceHit: (NSButton *)sender;

- (NSBrowser *)browser;
- (NSWindow *)window;
@end

#endif
