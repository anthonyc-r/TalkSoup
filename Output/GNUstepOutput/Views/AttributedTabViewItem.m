/***************************************************************************
                              AttributedTabViewItem.m
                          -------------------
    begin                : Thu Dec  5 00:25:40 CST 2002
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

#import "Views/AttributedTabViewItem.h"

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSStringDrawing.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSTabView.h>
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSGeometry.h>

@implementation AttributedTabViewItem
- (void)dealloc
{
	[attributedLabel release];
	[super dealloc];
}
- (void)drawLabel: (BOOL)shouldTruncateLabel inRect: (NSRect)tabRect
{
	id string;
	
	string = [[self label] retain];

	[self setLabel: @""];
	[super drawLabel: shouldTruncateLabel inRect: tabRect];
	[self setLabel: string]; 	

	[string release];
	
	[attributedLabel drawInRect: tabRect];	
}
- setLabelColor: (NSColor *)aColor
{
	if (!aColor)
	{
		[attributedLabel removeAttribute: NSForegroundColorAttributeName
		  range: NSMakeRange(0, [attributedLabel length])];
		[[self tabView] setNeedsDisplay: YES];
		return self;
	}
	
	[attributedLabel addAttribute: NSForegroundColorAttributeName value:
	  aColor range: NSMakeRange(0, [attributedLabel length])];
	
	[[self tabView] setNeedsDisplay: YES];

	return self;
}	
- setAttributedLabel: (NSAttributedString *)aString
{
	if (!aString) return self;
	
	[attributedLabel release];
	attributedLabel = [[NSMutableAttributedString alloc] initWithAttributedString:
	  aString];

	[attributedLabel addAttribute: NSFontAttributeName value:
	  [[self tabView] font] 
	  range: NSMakeRange(0, [attributedLabel length])];
	  
	[self setLabel: [attributedLabel string]];

	[[self tabView] setNeedsDisplay: YES];

	return self;
}
- (NSAttributedString *)attributedLabel
{
	return [[[NSAttributedString alloc] initWithAttributedString: 
	  attributedLabel] autorelease];
}
@end

