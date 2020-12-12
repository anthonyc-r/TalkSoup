/***************************************************************************
                              Colorizer.m
                          -------------------
    begin                : Sat May 10 18:58:30 CDT 2003
    copyright            : (C) 2005 by Andrew Ruder
                         : (C) 2015 The GNUstep Application Project
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

#import "Colorizer.h"
#import <TalkSoupBundles/TalkSoup.h>

#import <Foundation/NSAttributedString.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

#include <ctype.h>

static inline BOOL scan_two_char_int(NSScanner *beg, int *aInt)
{
	// FIXME this needs to be highly optimized
	int y;
	id string;
	id two;
	NSRange sub;
	id scan;
	
	string = [beg string];
	if (!string) return NO;

	sub.location = [beg scanLocation];
	sub.length = 2;
	
	if (sub.location == [string length]) return NO;

	if (sub.location == ([string length] - 1)) sub.length = 1;

	two = [string substringWithRange: sub];

	scan = [NSScanner scannerWithString: two];
	[scan setCharactersToBeSkipped: [NSCharacterSet 
	  characterSetWithCharactersInString: @""]];
	
	if (!isdigit([two characterAtIndex: 0])) return NO;
	if (![scan scanInt: &y]) return NO;

	[beg setScanLocation: sub.location + [scan scanLocation]];

	if (aInt) *aInt = y;

	return YES;
}

static NSCharacterSet *comma = nil;
static NSCharacterSet *control = nil;
static NSCharacterSet *color_control = nil;
static NSCharacterSet *bold_control = nil;
static NSCharacterSet *underline_control = nil;
static NSCharacterSet *clear_control = nil;
static NSCharacterSet *reverse_control = nil;
static NSString *colors[16] = { 0 };
	
static void initialize_stuff(void)
{
	NSAutoreleasePool *arp = [NSAutoreleasePool new];
	
	comma = [[NSCharacterSet characterSetWithCharactersInString: @","] retain];
	color_control = 
	  [[NSCharacterSet characterSetWithCharactersInString: @"C"] retain];
	bold_control =
	  [[NSCharacterSet characterSetWithCharactersInString: @"B"] retain];
	underline_control = 
	  [[NSCharacterSet characterSetWithCharactersInString: @"U"] retain];
	clear_control =
	  [[NSCharacterSet characterSetWithCharactersInString: @"O"] retain];
	reverse_control = 
	  [[NSCharacterSet characterSetWithCharactersInString: @"R"] retain];	
	control =
	  [[NSCharacterSet characterSetWithCharactersInString: 
	   @"%"] retain];
	
	colors[0] = [IRCColorWhite retain];
	colors[1] = [IRCColorBlack retain];
	colors[2] = [IRCColorBlue retain];
	colors[3] = [IRCColorGreen retain];
	colors[4] = [IRCColorRed retain];
	colors[5] = [IRCColorMaroon retain];
	colors[6] = [IRCColorMagenta retain];
	colors[7] = [IRCColorOrange retain];
	colors[8] = [IRCColorYellow retain];
	colors[9] = [IRCColorLightGreen retain];
	colors[10] = [IRCColorTeal retain];
	colors[11] = [IRCColorLightCyan retain];
	colors[12] = [IRCColorLightBlue retain];
	colors[13] = [IRCColorLightMagenta retain];
	colors[14] = [IRCColorGrey retain];
	colors[15] = [IRCColorLightGrey retain];
	
	[arp release];
}

static inline BOOL scan_one_char_from_set(NSScanner *beg, NSCharacterSet *aSet, NSString **y)
{
	unichar x;
	int pos;
	
	if ([beg isAtEnd]) return NO;
	
	pos = [beg scanLocation];
	
	x = [[beg string] characterAtIndex: pos];
	
	if (![aSet characterIsMember: x]) return NO;

	if (y) *y = [NSString stringWithCharacters: &x length: 1];
	
	[beg setScanLocation: pos + 1];
	
	return YES;
}

static inline NSAttributedString *as2cas(NSAttributedString *astr)
{
	NSScanner *scan;
	id aString;
	int x;
	NSMutableAttributedString *string = 
	  [[NSMutableAttributedString new] autorelease];
	NSMutableDictionary *dict = [[NSMutableDictionary new] autorelease];
	id str = [astr string];
	int location;

	if (!str)
	{
		return nil;
	}
	
	if (!comma)
	{
		initialize_stuff();
	}
	
	scan = [NSScanner scannerWithString: str];
	[scan setCharactersToBeSkipped: [NSCharacterSet 
	  characterSetWithCharactersInString: @""]];
	
	while ([scan isAtEnd] == NO)
	{
		location = [scan scanLocation];
		if ([scan scanUpToCharactersFromSet: control intoString: &aString])
		{
			NSRange aRange;
			aRange = NSMakeRange(location, [aString length]);
			
			aString = [astr attributedSubstringFromRange: aRange];
			
			aRange.location = [string length];
			[string appendAttributedString: aString];
			[string addAttributes: [NSDictionary dictionaryWithDictionary: dict]
			  range: aRange];
		}
		
		if ([scan isAtEnd] == YES) break;		
		[scan setScanLocation: [scan scanLocation] + 1];
		if ([scan isAtEnd] == YES)
		{
			[string appendAttributedString:
			  [[[NSAttributedString alloc] initWithString: @"%"
			  attributes: [NSDictionary dictionaryWithDictionary: dict]] autorelease]];

			break;
		}
		
		if (scan_one_char_from_set(scan, control, 0))
		{
			[string appendAttributedString: 
			  [[[NSAttributedString alloc] initWithString: @"%"
			  attributes: [NSDictionary dictionaryWithDictionary: dict]] autorelease]];
		}
		else if (scan_one_char_from_set(scan, bold_control, 0))
		{
			if (![dict objectForKey: IRCBold])
			{
				[dict setObject: IRCBoldValue
				  forKey: IRCBold];
			}
			else
			{
				[dict removeObjectForKey: IRCBold];
			}
		}
		else if (scan_one_char_from_set(scan, underline_control, 0))
		{
			if (![dict objectForKey: IRCUnderline])
			{
				[dict setObject: IRCUnderlineValue
				  forKey: IRCUnderline];
			}
			else
			{
				[dict removeObjectForKey: IRCUnderline];
			}
		}
		else if (scan_one_char_from_set(scan, clear_control, 0))
		{
			[dict removeAllObjects];
		}
		else if (scan_one_char_from_set(scan, reverse_control, 0))
		{
			if (![dict objectForKey: IRCReverse])
			{
				[dict setObject: IRCReverseValue
				  forKey: IRCReverse];
			}
			else
			{
				[dict removeObjectForKey: IRCReverse];
			}
		}
		else if (scan_one_char_from_set(scan, color_control, 0))
		{
			if (scan_two_char_int(scan, &x))
			{
				x = x % 16;
				[dict setObject: colors[x] forKey: 
				  IRCColor];
	
				if (scan_one_char_from_set(scan, comma, 0))
				{
					if (scan_two_char_int(scan, &x))
					{
						x = x % 16;
						[dict setObject: colors[x] forKey:
						  IRCBackgroundColor];
					}
				}	
			}
			else if (scan_one_char_from_set(scan, comma, 0))
			{
				if (scan_two_char_int(scan, &x))
				{
					x = x % 16;
					[dict setObject: colors[x] forKey:
					  IRCBackgroundColor];
				}
			}
			else
			{
				[dict removeObjectForKey: IRCBackgroundColor];
				[dict removeObjectForKey: IRCColor];
			}
		}
		else
		{
			[string appendAttributedString:
			  [[[NSAttributedString alloc] initWithString: @"%"
			  attributes: [NSDictionary dictionaryWithDictionary: dict]] autorelease]];
		}
	}
	
	return string;
}		

@implementation Colorizer
- (NSAttributedString *)pluginDescription
{
	return BuildAttributedString([NSNull null], IRCBold, IRCBoldValue,
	 _l(@"Author: "), @"Andrew Ruder\n\n",
	 [NSNull null], IRCBold, IRCBoldValue,
	 _l(@"Description: "), _l(@"Adds color into outgoing messages. "
	 @"The syntax is %C#[,#] for colors.  The first # specifies "
	 @"the foreground color and the second # specifies the "
	 @"optional second color.  The colors are in the range of "
	 @"0-15\n"),
	 _l(@"Bold is %B, underline is %U, and %R is reverse.  Repeating "
	 @"any one of these a second time will result in the turning "
	 @"off of that attribute.  Use %O to clear all colors and "
	 @"attributes."),
	 @"\n\n",
	 _l(@"Copyright (C) 2005 by Andrew Ruder"),
	 nil);
}
- quitWithMessage: (NSAttributedString *)aMessage onConnection: aConnection
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ quitWithMessage: as2cas(aMessage) onConnection: aConnection
	  withNickname: aNick sender: self];
	return self;
}
- partChannel: (NSAttributedString *)channel 
   withMessage: (NSAttributedString *)aMessage 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
	sender: aPlugin
{
	[_TS_ partChannel: channel withMessage: as2cas(aMessage)
	  onConnection: aConnection withNickname: aNick
	  sender: self];
	return self;
}
- sendCTCPReply: (NSAttributedString *)aCTCP 
   withArgument: (NSAttributedString *)args
   to: (NSAttributedString *)aPerson 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ sendCTCPReply: aCTCP withArgument: as2cas(args)
	 to: aPerson onConnection: aConnection withNickname: aNick
	 sender: self];
	return self;
}
- sendCTCPRequest: (NSAttributedString *)aCTCP 
   withArgument: (NSAttributedString *)args
   to: (NSAttributedString *)aPerson onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
	sender: aPlugin
{
	[_TS_ sendCTCPRequest: aCTCP
	  withArgument: as2cas(args) to: aPerson
	  onConnection: aConnection
	  withNickname: aNick
	  sender: self];
	return self;
} 
- sendMessage: (NSAttributedString *)message to: (NSAttributedString *)receiver 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick    
	sender: aPlugin
{
	[_TS_ sendMessage: as2cas(message) to: receiver
	  onConnection: aConnection withNickname: aNick
	  sender: self];
	return self;
}
- sendNotice: (NSAttributedString *)message to: (NSAttributedString *)receiver 
   onConnection: aConnection
   withNickname: (NSAttributedString *)aNick 
	sender: aPlugin
{
	[_TS_ sendNotice: as2cas(message) to: receiver
	 onConnection: aConnection withNickname: aNick
	 sender: self];
	return self;
}
- sendAction: (NSAttributedString *)anAction to: (NSAttributedString *)receiver 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
	sender: aPlugin
{
	[_TS_ sendAction: as2cas(anAction) to: receiver
	 onConnection: aConnection
	 withNickname: aNick
	 sender: self];
	return self;
}
- sendWallops: (NSAttributedString *)message onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ sendWallops: as2cas(message) onConnection: aConnection
	  withNickname: aNick sender: self];
	return self;
}
- setTopicForChannel: (NSAttributedString *)aChannel 
   to: (NSAttributedString *)aTopic 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ setTopicForChannel: aChannel to: as2cas(aTopic) onConnection: aConnection
	  withNickname: aNick sender: self];
	return self;
}
- kick: (NSAttributedString *)aPerson offOf: (NSAttributedString *)aChannel 
   for: (NSAttributedString *)reason 
   onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ kick: aPerson offOf: aChannel for: as2cas(reason) onConnection: aConnection
	  withNickname: aNick sender: self];
	return self;
}
- setAwayWithMessage: (NSAttributedString *)message onConnection: aConnection 
   withNickname: (NSAttributedString *)aNick 
   sender: aPlugin
{
	[_TS_ setAwayWithMessage: as2cas(message) onConnection: aConnection
	  withNickname: aNick sender: self];
	return self;
}
@end


