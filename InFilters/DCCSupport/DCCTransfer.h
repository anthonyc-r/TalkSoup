/***************************************************************************
                                DCCTransfer.h
                          -------------------
    begin                : 25 Feb 2015
    copyright            : (C) 2015 by Riccardo Mottola
                         :             The GNUstep Application Team
    email                : rm@gnu.org
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#import <Foundation/NSObject.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSTimer.h>
#include <stdint.h>

@class DCCObject;

@interface DCCTransfer : NSObject
{
  NSFileHandle *file;
  NSString *path;
  NSString *status;
  id connection;
  id delegate;
  NSTimer *cpsTimer;
  int cps;
  uint32_t oldTransferredBytes;
}

- (NSString *)status;

- (id)localHost;
- (id)remoteHost;

- (int)cps;

- (NSString *)path;


@end
