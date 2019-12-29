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

#import "DCCTransfer.h"
#import "DCCObject.h"

@implementation DCCTransfer

- (void)dealloc
{
  [cpsTimer invalidate];
  [cpsTimer release];
  cpsTimer = nil;
  
  [path release];
  [file release];
  [connection release];
  [status release];
  
  [super dealloc];
}

- (NSString *)status
{
  return status;
}

- (id)localHost
{
  return [connection localHost];
}

- (id)remoteHost
{
  return [connection remoteHost];
}

- (int)cps
{
  return cps;
}

- (NSString *)path
{
  return path;
}


@end
