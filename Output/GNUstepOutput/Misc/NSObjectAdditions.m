/***************************************************************************
                                NSObjectAdditions.m
                          -------------------
    begin                : Fri Apr 11 15:10:32 CDT 2003
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

#import "Misc/NSObjectAdditions.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSPathUtilities.h>

#ifdef __APPLE__
#include <objc/objc-class.h>
#endif

@implementation NSObject (Introspection)
+ (NSArray *)methodsDefinedForClass
{
#ifdef __APPLE__
	struct objc_method_list *list;
	void *iterator;
#else
	Method *methods;
#endif
	Class class;
	unsigned int z;
	unsigned int numMethods;
	SEL sel;
	NSMutableArray *array = [[NSMutableArray new] autorelease];
	
	class = [self class];

#ifdef __APPLE__	
	iterator = 0;
	while ((list = class_nextMethodList(class, &iterator)))
	{
	        numMethods = list->method_count;
#else
	methods = class_copyMethodList(class, &numMethods);
	{
#endif

		for (z = 0; z < numMethods; z++)
		{
#ifdef __APPLE__
			sel = list->method_list[z].method_name;
			[array addObject: [[[NSString alloc] initWithUTF8String:
			  (char *)sel] autorelease]];
#else
			sel = method_getName(methods[z]);
			[array addObject: NSStringFromSelector(sel)];
#endif
		}
	}
#ifndef __APPLE__
	free(methods);
#endif

	return [NSArray arrayWithArray: array];
}
@end

