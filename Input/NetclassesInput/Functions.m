/***************************************************************************
                                Functions.m
                          -------------------
    begin                : Mon Apr 28 02:10:41 CDT 2003
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

#import <TalkSoupBundles/TalkSoup.h>

#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDebug.h>

#include <ctype.h>

static inline BOOL scan_two_char_int(NSScanner *beg, int *aInt)
{
	int y;
	NSString *string;
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
	NSAutoreleasePool *apr = [NSAutoreleasePool new];
	
	comma = [[NSCharacterSet characterSetWithCharactersInString: @","] retain];
	color_control = 
	  [[NSCharacterSet characterSetWithCharactersInString: @"\003"] retain];
	bold_control =
	  [[NSCharacterSet characterSetWithCharactersInString: @"\002"] retain];
	underline_control = 
	  [[NSCharacterSet characterSetWithCharactersInString: @"\037"] retain];
	clear_control =
	  [[NSCharacterSet characterSetWithCharactersInString: @"\017"] retain];
	reverse_control =
	  [[NSCharacterSet characterSetWithCharactersInString: @"\026"] retain];
	control =
	  [[NSCharacterSet characterSetWithCharactersInString: 
	   @"\003\002\037\017\026"] retain];
	
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
	
	[apr release];
}

inline NSAttributedString *NetClasses_AttributedStringFromString(NSString *str)
{
	NSScanner *scan;
	NSString *aString;
	int x;
	NSMutableAttributedString *string = 
	  [[NSMutableAttributedString new] autorelease];
	NSMutableDictionary *dict = [[NSMutableDictionary new] autorelease];
	
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
		if ([scan scanUpToCharactersFromSet: control intoString: &aString])
		{
			[string appendAttributedString: 
			  [[[NSAttributedString alloc] initWithString: aString
			  attributes: [NSDictionary dictionaryWithDictionary: dict]] autorelease]];
		}
		
		if ([scan isAtEnd] == YES) break;
		
		if (scan_one_char_from_set(scan, bold_control, 0))
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
					NSLog(@"Found a background with foreground...");
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
			NSLog(@"Current dict: %@", dict);
		}	
	}
	
	return string;
}		

static inline NSString *lookup_color(NSString *aString)
{
	int x;
	
	for (x = 0; x < 16; x++)
	{
		if ([colors[x] isEqualToString: aString])
		{
			return [NSString stringWithFormat: @"%02d", x];
		}
	}
	
	return @"";
}

inline NSString *NetClasses_StringFromAttributedString(NSAttributedString *atr)
{
	NSRange cur = {0, 0};
	NSRange work;
	NSDictionary *b;
	NSDictionary *so = [[NSDictionary new] autorelease];
	NSString *begF;
	NSString *begB;
	NSString *nowF = @"";
	NSString *nowB = @"";
	NSMutableString *aString = [NSMutableString new];
	unsigned int len = [atr length];
	
	cur.length = len;
	
	while (cur.length > 0)
	{
		b = [atr attributesAtIndex: cur.location 
		     longestEffectiveRange: &work inRange: cur];
		
		begB = [b objectForKey: IRCBold];
		begF = [so objectForKey: IRCBold];
		if ((!begB || !begF) && (begF || begB))
		{
			[aString appendString: @"\002"];
		}
		begB = [b objectForKey: IRCUnderline];
		begF = [so objectForKey: IRCUnderline];
		if ((!begB || !begF) && (begF || begB))
		{
			[aString appendString: @"\037"];
		}
		begB = [b objectForKey: IRCReverse];
		begF = [so objectForKey: IRCReverse];
		if ((!begB || !begF) && (begF || begB))
		{
			[aString appendString: @"\026"];
		}
		
		begF = nowF;
		begB = nowB;
		nowF = [b objectForKey: IRCColor];
		nowB = [b objectForKey: IRCBackgroundColor];
		
		if (!nowF) nowF = @"";
		if (!nowB) nowB = @"";
		
		if (![nowF isEqualToString: begF] && ![nowB isEqualToString: begB])
		{
			[aString appendString: @"\003"];
			if ([nowB length] > 0 && [nowF length] > 0)
			{
				[aString appendString: [NSString stringWithFormat: @"%@,%@",
				 lookup_color(nowF), lookup_color(nowB)]];
			}
			else if ([nowB length] > 0)
			{
				[aString appendString: [NSString stringWithFormat: @"\003,%@",
				  lookup_color(nowB)]];
			}
			else if ([nowF length] > 0)
			{
				[aString appendString: lookup_color(nowF)];
			}
		}
		else if (![nowF isEqualToString: begF])
		{
			[aString appendString: @"\003"];
			[aString appendString: lookup_color(nowF)];
		}
		else if (![nowB isEqualToString: begB])
		{
			[aString appendString: @"\003"];
			if ([nowB length] > 0)
			{
				[aString appendString: [NSString stringWithFormat: @",%@",
				  lookup_color(nowB)]];
			}
			else if ([nowF length] > 0)
			{
				[aString appendString: [NSString stringWithFormat: @"\003%@",
				  lookup_color(nowF)]];
			}
		}
		
		[aString appendString: [[atr string] substringWithRange: work]];
		cur.location = work.location + work.length;
		
		if (len <= (int)cur.location) break;	
		cur.length = len - cur.location; 
		
		so = b;
	}
	
	return [aString autorelease];
}

