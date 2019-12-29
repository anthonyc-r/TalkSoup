/***************************************************************************
                                DCCGetter.h
                          -------------------
    begin                : Wed Jan  7 21:08:21 CST 2004
    copyright            : (C) 2005 by Andrew Ruder
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

@class DCCGetter;

#ifndef DCC_GETTER_H
#define DCC_GETTER_H

#import <Foundation/NSObject.h>
#import "DCCTransfer.h"

@class DCCObject, NSFileHandle, NSString, NSTimer;
@class NSDictionary, NSHost;

@interface DCCGetter : DCCTransfer
	{
		DCCObject *getter;
	}

- (DCCGetter *)initWithInfo: (NSDictionary *)aDict withFileName: (NSString *)aPath 
    withConnection: aConnection withDelegate: aDel;

- (NSDictionary *)info;

- (NSString *)percentDone;

- cpsTimer: (NSTimer *)aTimer;

- (void)abortConnection;
@end

#endif
