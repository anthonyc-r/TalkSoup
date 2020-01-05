/***************************************************************************
                                main.m
                          -------------------
    begin                : Fri Dec 29 10:51:41 UTC 2019
    copyright            : (C) 2019 Anthony Conh-Richardby
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
#import <Foundation/Foundation.h>
#import <libircclient.h>
#import "LibircclientConnection.h"
#import "LibircclientConnection+Receivers.h"

@interface LibircclientConnection (Receivers)
- (id)connectionReceived;
- (id)noticeReceived: (const char*)aMessage to: (const char*)to from: (const char*)sender;
- (id)numericReceived: (int)event from: (const char*)aSender withParams: (const char**)params count: (int)count;
- (id)topicReceived: (const char*)aTopic onChannel: (const char*)aChannel from: (const char*)aSender;
- (id)channelReceived: (const char*)aChannel from: (const char*)aSender message: (const char*)aMessage;
- (id)joinReceived: (const char*)aChannel from: (const char*)aSender;
- (id)ctcpReqReceived: (const char*)aRequest from: (const char*)aSender;
- (id)modeReceived: (const char*)aMode on: (const char*)aChannel from: (const char*)aSender args: (const char*)someArgs;
@end
