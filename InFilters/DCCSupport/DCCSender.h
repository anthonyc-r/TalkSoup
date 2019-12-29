/***************************************************************************
                                DCCSender.h
                          -------------------
    begin                : Wed Jan  7 21:13:07 CST 2004
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

@class DCCSender;

#ifndef DCC_SENDER_H
#define DCC_SENDER_H

#import <Foundation/NSObject.h>
#import "DCCTransfer.h"

@class DCCSendObject, NSFileHandle, NSString, NSString;
@class NSTimer, NSDictionary, NSHost;

@interface DCCSender : DCCTransfer
{
  DCCSendObject *sender;
  NSString *receiver;
}

- (DCCSender *)initWithFilename: (NSString *)path 
    withConnection: aConnection to: (NSString *)receiver withDelegate: aDel;


- (NSDictionary *)info;

- (NSString *)percentDone;

- cpsTimer: (NSTimer *)aTimer;

- (NSString *)receiver;

- (void)abortConnection;
@end
#endif
