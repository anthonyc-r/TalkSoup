/***************************************************************************
                                LibircclientConnection+Receivers.m
                          -------------------
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

#define S2AS(_x) ( (_x) ? (NSAttributedString *)[[[NSAttributedString alloc] initWithString: (_x)] autorelease] : (NSAttributedString *)nil )
#define CS2S(_x) [NSString stringWithCString: _x]

@implementation LibircclientConnection (Receivers)

- (id)connectionReceived
{
  NSLog(@"Connection received");
  [_TS_ newConnection: self withNickname: S2AS(nick) sender: control];
    // TODO: - Cancel this on dealloc.
  [self performSelectorInBackground: @selector(startNetworkLoop) 
    withObject: nil];
  return self;
}

- (id)noticeReceived: (const char*)aMessage to: (const char*)to from: (const char*)sender;
{
  NSString *message = CS2S(aMessage);
  NSString *toName = CS2S(to);
  NSString *fromName = CS2S(sender);
  [_TS_ noticeReceived: S2AS(message) to: S2AS(toName) from: S2AS(fromName)
    onConnection: self withNickname: S2AS(nick) sender: control];
  return self;
}


- (id)numericReceived: (int)event from: (const char*)aSender withParams: (const char**)params count: (int)count;
{
  NSString *command = [[NSNumber numberWithInt: event] description];
  NSString *sender = [NSString stringWithCString: aSender];
  NSMutableArray *paramArray = [NSMutableArray array];
  for (int i = 1; i < count; i++)
  {
    [paramArray addObject: S2AS([NSString stringWithCString: params[i]])];
  }
  [_TS_ numericCommandReceived: S2AS(command) withParams: paramArray
    from: S2AS(sender) onConnection: self withNickname: S2AS(nick)
    sender: control];
  
  return self;
}

- (id)topicReceived: (const char*)aTopic onChannel: (const char*)aChannel from: (const char*)aSender
{
  NSString *topic = [NSString stringWithCString: aTopic];
  NSString *sender = [NSString stringWithCString: aSender];
  NSString *channel = [NSString stringWithCString: aChannel];
  if ([topic length] < 1)
  {
    topic = nil;
  }
  [_TS_ topicChangedTo: S2AS(topic) in: S2AS(channel) from: S2AS(sender) 
    onConnection: self withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)channelReceived: (const char*)aMessage onChannel: (const char*)aChannel from: (const char*)aSender
{
  NSString *message = [NSString stringWithCString: aMessage];
  NSString *channel = [NSString stringWithCString: aChannel];
  NSString *sender = [NSString stringWithCString: aSender];
  [_TS_ messageReceived: S2AS(message) to: S2AS(channel) from: S2AS(sender)
    onConnection: self withNickname: S2AS(nick) sender: control];

  return self;
}

- (id)channelNoticeReceived: (const char*)aNotice onChannel: (const char*)channel from: (const char*)aSender
{
  NSString *message = CS2S(aNotice);
  NSString *toName = CS2S(channel);
  NSString *fromName = CS2S(aSender);
  [_TS_ noticeReceived: S2AS(message) to: S2AS(toName) from: S2AS(fromName)
    onConnection: self withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)joinReceived: (const char*)aChannel from: (const char*)aSender
{
  NSString *channel = [NSString stringWithCString: aChannel];
  NSString *sender = [NSString stringWithCString: aSender];
  [_TS_ channelJoined: S2AS(channel) from: S2AS(sender) onConnection: self
    withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)ctcpReqReceived: (const char*)aRequest from: (const char*)aSender
{
  NSString *request = [NSString stringWithCString: aRequest];
  NSString *sender = [NSString stringWithCString: aSender];
  NSString *argument = nil;
  NSString *receiver = nick;
  NSLog(@"ctcpreq: %@", request);
  [_TS_ CTCPRequestReceived: S2AS(request) withArgument: S2AS(argument)
    to: S2AS(receiver) from: S2AS(sender) onConnection: self 
    withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)modeReceived: (const char*)aMode on: (const char*)aChannel from: (const char*)aSender args: (const char*)someArgs
{
  NSString *mode = [NSString stringWithCString: aMode];
  NSString *channel = [NSString stringWithCString: aChannel];
  NSString *sender = [NSString stringWithCString: aSender];
  NSString *argStr = [NSString stringWithCString: someArgs];
  NSMutableArray *args = [NSMutableArray array];
  if ([argStr length] > 0)
  {
    [args addObject: S2AS(argStr)];
  }
  [_TS_ modeChanged: S2AS(mode) on: S2AS(channel) withParams: 
    args from: S2AS(sender) onConnection: self
    withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)partReceivedOnChannel: (const char*)aChannel from: (const char*)aSender withReason: (const char*)aReason
{
  NSString *channel = [NSString stringWithCString: aChannel];
  NSString *sender = [NSString stringWithCString: aSender];
  NSString *reason = [NSString stringWithCString: aReason];
  [_TS_ channelParted: S2AS(channel) withMessage: S2AS(reason) from:
    S2AS(sender) onConnection: self withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)quitReceived: (const char*)aMessage from: (const char*)aSender
{
  NSString *message = [NSString stringWithCString: aMessage];
  NSString *sender = [NSString stringWithCString: aSender];
  [_TS_ quitIRCWithMessage: S2AS(message) from: S2AS(sender) onConnection: self
    withNickname: S2AS(nick) sender: control];
  return self;
}

- (id)nickReceived: (const char*)aNewNick from: (const char*)anOriginalNick
{
  NSString *newNick = [NSString stringWithCString: aNewNick];
  NSString *originalNick = [NSString stringWithCString: anOriginalNick];
  [_TS_ nickChangedTo: S2AS(newNick) from: S2AS(originalNick) onConnection:
    self withNickname: S2AS(nick) sender: control];
  return self;
}


- (id)kickReceived: (const char*)aTarget onChannel: (const char*)aChannel byKicker: (const char*)aKicker withReason: (const char*)aReason
{
  NSString *target = [NSString stringWithCString: aTarget];
  NSString *channel = [NSString stringWithCString: aChannel];
  NSString *kicker = [NSString stringWithCString: aKicker];
  NSString *reason = [NSString stringWithCString: aReason];
  if ([reason length] < 1)
  {
    reason = nil;
  }
  if ([target length] < 1)
  {
    target = nil;
  }
  [_TS_ userKicked: S2AS(target) outOf: S2AS(channel) for: S2AS(reason) from:
    S2AS(kicker) onConnection: self withNickname: S2AS(nick) sender: control];
  return self;
}

@end
