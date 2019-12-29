/***************************************************************************
                                TalkSoup.h
                          -------------------
    begin                : Fri Jan 17 11:04:36 CST 2003
    copyright            : (C) 2005 by Andrew Ruder
                           (C) 2013-2015 The GNUstep Application Project
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


@class TalkSoup, TalkSoupDummyProtocolClass, NSString, NSArray;

/* object: the preference string 
 *
 * dictionary:
 *   @"Bundle" the bundle object 
 *   @"Old" the old value
 *   @"New" the new value
 *   @"Owner" the owner of the preference change
 */
extern NSString *DefaultsChangedNotification;

// Defaults stuff
extern NSString *IRCDefaultsNick;
extern NSString *IRCDefaultsRealName;
extern NSString *IRCDefaultsUserName;
extern NSString *IRCDefaultsPassword;

// Attributed string stuff

#ifdef S2AS
#undef S2AS
#undef S2AS_s
#endif

/* string to attributed string macros for generic and for static strings (known not to be nil */
#define S2AS(_x) ( (_x) ? (NSAttributedString *)[[[NSAttributedString alloc] initWithString: (_x)] autorelease] : (NSAttributedString *)nil )
#define S2AS_s(_x) ( [[[NSAttributedString alloc] initWithString: (_x)] autorelease] )

// Key
extern NSString *IRCColor;
extern NSString *IRCBackgroundColor;
// Values
extern NSString *IRCColorWhite;
extern NSString *IRCColorBlack;
extern NSString *IRCColorBlue;
extern NSString *IRCColorGreen;
extern NSString *IRCColorRed;
extern NSString *IRCColorMaroon;
extern NSString *IRCColorMagenta;
extern NSString *IRCColorOrange;
extern NSString *IRCColorYellow;
extern NSString *IRCColorLightGreen;
extern NSString *IRCColorTeal;
extern NSString *IRCColorLightCyan;
extern NSString *IRCColorLightBlue;
extern NSString *IRCColorLightMagenta;
extern NSString *IRCColorGrey;
extern NSString *IRCColorLightGrey;
extern NSString *IRCColorCustom;

// Keys
extern NSString *IRCBold;
extern NSString *IRCBoldValue;
extern NSString *IRCUnderline;
extern NSString *IRCUnderlineValue;
extern NSString *IRCReverse;
extern NSString *IRCReverseValue;

#ifndef TALKSOUP_H
#define TALKSOUP_H

#import <Foundation/NSObject.h>
#import <Foundation/NSMapTable.h>

#import "TalkSoupProtocols.h"
#import "TalkSoupMisc.h"

#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSUInteger
#define NSUInteger unsigned int
#endif
#ifndef NSInteger
#define NSInteger int
#endif
#endif


@class NSInvocation, NSString, NSMutableDictionary, NSMutableArray;

extern id _TS_;
extern id _TSDummy_;

@interface TalkSoup : NSObject
	{
		NSMutableDictionary *inputNames;
		NSString *activatedInput;
		id input;

		NSMutableDictionary *outputNames;
		NSString *activatedOutput;
		id output;
		
		NSMutableDictionary *inNames;
		NSMutableArray *activatedInFilters;
		NSMutableDictionary *inObjects;
		
		NSMutableDictionary *outNames;
		NSMutableArray *activatedOutFilters;
		NSMutableDictionary *outObjects;
				
		NSMutableDictionary *commandList;
	}
+ (TalkSoup *)sharedInstance;

- (void)refreshPluginList;
- (void)savePluginList;

- (NSInvocation *)invocationForCommand: (NSString *)aCommand;
- addCommand: (NSString *)aCommand withInvocation: (NSInvocation *)invoc;
- removeCommand: (NSString *)aCommand;
- (NSArray *)allCommands;

- (NSString *)input;
- (NSString *)output;
- (NSDictionary *)allInputs;
- (NSDictionary *)allOutputs;
- setInput: (NSString *)aInput;
- setOutput: (NSString *)aOutput;

- (NSArray *)activatedInFilters;
- (NSArray *)activatedOutFilters;
- (NSDictionary *)allInFilters;
- (NSDictionary *)allOutFilters;

- activateInFilter: (NSString *)aFilt;
- activateOutFilter: (NSString *)aFilt;
- deactivateInFilter: (NSString *)aFilt;
- deactivateOutFilter: (NSString *)aFilt;
- setActivatedInFilters: (NSArray *)filters;
- setActivatedOutFilters: (NSArray *)filters;

- (id)pluginForOutput;
- (id)pluginForOutFilter: (NSString *)aFilt;
- (id)pluginForInFilter: (NSString *)aFilt;
- (id)pluginForInput;
@end
  
#import "Encodings.h"

#endif
