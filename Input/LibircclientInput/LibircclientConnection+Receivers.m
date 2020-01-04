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
  for (int i = 0; i < count; i++)
  {
    [paramArray addObject: S2AS([NSString stringWithCString: params[i]])];
  }
  [_TS_ numericCommandReceived: S2AS(command) withParams: paramArray
    from: S2AS(sender) onConnection: self withNickname: S2AS(nick)
    sender: control];
  
  return self;
}
@end
