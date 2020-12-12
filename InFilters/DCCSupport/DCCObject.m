/***************************************************************************
                                DCCObject.m
                          -------------------
    begin                : Wed Jul  2 15:23:24 CDT 2003
    copyright            : (C) 2005 by Andrew Ruder
                         : (C) 2013-2015 The GNUstep Application Project
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

#import "DCCObject.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSData.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

NSString *DCCStatusTransferring = @"DCCStatusTransferring";
NSString *DCCStatusError = @"DCCStatusError";
NSString *DCCStatusDone = @"DCCStatusDone";
NSString *DCCStatusConnecting = @"DCCStatusConnecting";
NSString *DCCStatusAborted = @"DCCStatusAborted";
NSString *DCCStatusTimeout = @"DCCStatusTimeout";

NSString *DCCInfoFileName = @"DCCInfoFileName";
NSString *DCCInfoFileSize = @"DCCInfoFileSize";
NSString *DCCInfoPort = @"DCCInfoPort";
NSString *DCCInfoHost = @"DCCInfoHost";
NSString *DCCInfoNick = @"DCCInfoNick";

NSString *BuildDCCSendRequest(NSDictionary *info)
{
	struct in_addr inp;
	NSMutableString *file = [NSMutableString stringWithString: 
	       [info objectForKey: DCCInfoFileName]];
	NSNumber *size = [info objectForKey: DCCInfoFileSize];
	NSNumber *port = [info objectForKey: DCCInfoPort];
	NSHost *address = [info objectForKey: DCCInfoHost];
	
	if (!address) return nil;
	
	[file replaceOccurrencesOfString: @" " withString: @"_" options: 0
	  range: NSMakeRange(0, [file length])];
	
	inet_aton([[address address] cString], &inp);
	
	return [NSString stringWithFormat: @"SEND %@ %lu %hu %lu",
                         file, (unsigned long)ntohl(inp.s_addr),
                         [port unsignedShortValue],
                         [size unsignedLongValue]];
}

@implementation DCCObject
- (DCCObject *)initWithDelegate: aDelegate withInfo: (NSDictionary *)aInfo
    withUserInfo: (NSDictionary *)aUserInfo
{
	if (!(self = [super init])) return nil;
	
	delegate = aDelegate;
	info = [aInfo retain];
	userInfo = [aUserInfo retain];

	[delegate DCCInitiated: self];
	
	status = [DCCStatusConnecting retain];
	[delegate DCCStatusChanged: status forObject: self];

	return self;
}
- (void)dealloc
{
	[status release];
	[info release];
	[userInfo release];
	delegate = nil;
	[super dealloc];
}
- (uint32_t)transferredBytes
{
	return transferredBytes;
}
- (void)abortConnection
{	
	[status release];
	status = [DCCStatusAborted retain];
	[delegate DCCStatusChanged: status forObject: self];

	if (transport)
	{
		[[NetApplication sharedInstance] disconnectObject: self];
	}
}
- connectionEstablished: (id <NetTransport>)aTransport
{
	transport = [aTransport retain];
	[[NetApplication sharedInstance] connectObject: self];
	
	[status release];
	status = [DCCStatusTransferring retain];
	[delegate DCCStatusChanged: status forObject: self];
	
	return self;
}
- (void)connectionLost
{
	[transport close];
	[transport release];
	[delegate DCCDone: self];
}
- dataReceived: (NSData *)data
{
	return self;
}
- transport
{
	return transport;
}
- (NSDictionary *)info
{
	return info;
}
- (NSString *)status
{
	return status;
}
- (NSDictionary *)userInfo
{
	return userInfo;
}
@end

@implementation DCCReceiveObject
- initWithReceiveOfFile: (NSDictionary *)aInfo 
           withDelegate: aDelegate
		   withTimeout: (int)seconds
		   withUserInfo: (NSDictionary *)aUserInfo
{
	if (!(self = (DCCReceiveObject *)[super initWithDelegate: aDelegate 
	  withInfo: aInfo withUserInfo: aUserInfo])) return nil;
	
	connection = [[[TCPSystem sharedInstance] 
	  connectNetObjectInBackground: self
	  toHost: [aInfo objectForKey: DCCInfoHost]
	  onPort: [[aInfo objectForKey: DCCInfoPort] unsignedShortValue]
	  withTimeout: seconds] retain];
	
	return self;
}
- (void)abortConnection
{
	[super abortConnection];
	if (connection)
	{
		[connection release];
		connection = nil;
		[self connectionLost];
	}
}	
- dataReceived: (NSData *)data
{
	uint32_t len;
	
	transferredBytes += [data length];

	len = htonl(transferredBytes);	
	
	[transport writeData: [NSData dataWithBytes: &len length: sizeof(len)]];

	[delegate DCCReceivedData: (NSData *)data forObject: self];

	return self;
}

- connectionEstablished: (id <NetTransport>)aTransport
{
	[connection release];
	[super connectionEstablished: aTransport];
	
	return self;
}

- (void)connectionLost
{
	if ([status isEqualToString: DCCStatusTransferring])
	{
		if ((int)transferredBytes < [[info objectForKey: DCCInfoFileSize] intValue])
		{
			[status release];
			status = [DCCStatusError retain];
		}
		else
		{
			[status release];
			status = [DCCStatusDone retain];
		}
		[delegate DCCStatusChanged: status forObject: self];
	}
	
	[super connectionLost];
}
- connectingFailed: (NSString *)anError
{
	if ([anError isEqualToString: NetclassesErrorTimeout])
	{
		[status release];
		status = [DCCStatusTimeout retain];
	}
	else
	{
		[status release];
		status = [DCCStatusError retain];
	}
	
	[delegate DCCStatusChanged: status forObject: self];
	
	[connection release];
	connection = nil;
	[self connectionLost];
	
	return self;
}
- connectingStarted: (TCPConnecting *)aConnection
{
	return self;
}
@end

static id connection_holder = nil;

@interface DCCConnectionHolder : NSObject < NetObject >
- (void)connectionLost;
- connectionEstablished: (id <NetTransport>)aTransport;
- dataReceived: (NSData *)data;
- transport;
@end

@implementation DCCConnectionHolder
- (void)connectionLost
{
}
- connectionEstablished: (id <NetTransport>)aTransport
{
	connection_holder = [aTransport retain];
	return self;
}
- dataReceived: (NSData *)data
{
	return self;
}
- transport
{
	return nil;
}
@end

@interface DCCSendObject (InternalSendObject)
- portTimeout;
- checkAndWrite;
@end

@interface DCCSendObjectPort : TCPPort
	{
		id delegate;
	}
- initOnPort: (int)aPort withDelegate: aDelegate;
@end

@implementation DCCSendObjectPort
- initOnPort: (int)aPort withDelegate: aDelegate
{
	if (!(self = [super initOnPort: aPort])) return nil;
	delegate = aDelegate;
	return self;
}
- newConnection
{
	[super newConnection];
	[delegate connectionEstablished: connection_holder];
	[connection_holder release];
	return self;
}
- timeoutReceived: (NSTimer *)aTimer
{
	[delegate portTimeout];
	return self;
}
@end

@implementation DCCSendObject (InternalSendObject)
- portTimeout
{
	if (port)
	{
		[[NetApplication sharedInstance] disconnectObject: port];
		[timeout invalidate];
		[timeout release];
		timeout = nil;
		[port release];
		port = nil;
		[status release];
		status = [DCCStatusTimeout retain];
		[delegate DCCStatusChanged: status forObject: self];
		[self connectionLost];
	}
	return self;
}
- checkAndWrite
{
	int length = [dataToWrite length];
	
	if (confirmedBytes != transferredBytes) // They must acknowledge everything
	{
		return self;
	}

	if (length > (int)blockSize)
	{
		char *buffer = [dataToWrite mutableBytes];

		[transport writeData: [NSData dataWithBytes: buffer length: blockSize]];
		transferredBytes += blockSize;
		memmove(buffer, buffer + blockSize, length - blockSize);
		[dataToWrite setLength: length - blockSize];
	}
	else if (length == (int)blockSize)
	{
		[transport writeData: dataToWrite];
		[dataToWrite setLength: 0];
		transferredBytes += blockSize;
	}
	else 
	{
		if (noMoreData)
		{
			if (length == 0) // No data to send and no more is coming
			{
				[[NetApplication sharedInstance] disconnectObject: self];
				return self;
			}
			[transport writeData: dataToWrite];
			[dataToWrite setLength: 0];
			transferredBytes += length;
		}
		else
		{
			[delegate DCCNeedsMoreData: self];
		}
	}
	return self;
}
@end
	
@implementation DCCSendObject
- initWithSendOfFile: (NSString *)name
   withSize: (NSNumber *)size
   withDelegate: aDelegate
   withTimeout: (int)seconds withBlockSize: (uint32_t)numBytes
   withUserInfo: (NSDictionary *)aUserInfo
   withPort: (int)low to: (int)high
{
	id address;
	id portNum;

	if (!(self = (DCCSendObject *)[super initWithDelegate: aDelegate
	  withInfo: [[NSDictionary new] autorelease] 
	  withUserInfo: aUserInfo])) return nil;
	
	if (seconds < 0)
	{
		[self dealloc];
		return nil;
	}
	
	if ([name length] == 0)
	{
		[self dealloc];
		return nil;
	}

	if ([size unsignedLongValue] == 0)
	{
		[self dealloc];
		return nil;
	}
	
	if (low < 0 || high < 0)
	{
		port = [[[DCCSendObjectPort alloc] initOnPort: 0 withDelegate: self]
	 	  setNetObject: [DCCConnectionHolder class]];
	}
	else
	{
		if (low > 65535) low = 65535;
		if (high > 65535) high = 65535;

		if (low > high)
		{
			int temp;
			temp = high;
			high = low;
			low = temp;
		}
		if (low == high)
		{
			port = [[[DCCSendObjectPort alloc] initOnPort: low withDelegate: self]
			  setNetObject: [DCCConnectionHolder class]];
		}
		else
		{
			do
			{
				port = [[[DCCSendObjectPort alloc] initOnPort: low withDelegate: self]
				  setNetObject: [DCCConnectionHolder class]];
				if (port) break;
				low++;
			} while (low <= high);
		}
	}
	
	if (!port)
	{
		[self dealloc];
		return nil;
	}

	if (numBytes <= 0)
	{
		[self dealloc];
		return nil;
	}
	
	if (seconds > 0)
	{
		timeout = [[NSTimer scheduledTimerWithTimeInterval:
		 (NSTimeInterval)seconds target: port 
		 selector: @selector(timeoutReceived:)
		 userInfo: nil repeats: NO] retain];
	}
	
	blockSize = numBytes;
	
	receivedData = [[NSMutableData alloc] initWithCapacity: 12];

	dataToWrite = [[NSMutableData alloc] initWithCapacity: blockSize * 2];

	address = [aDelegate localHost]; 
	
	portNum = [NSNumber numberWithUnsignedShort: [port port]];
	
	[info release];
	info = [[NSDictionary alloc] initWithObjectsAndKeys: 
	  name, DCCInfoFileName,
	  size, DCCInfoFileSize,
	  portNum, DCCInfoPort,
	  address, DCCInfoHost,
	  nil];
	
	return self;
}
- initWithSendOfFile: (NSString *)name
    withSize: (NSNumber *)size
    withDelegate: aDelegate
    withTimeout: (int)seconds withBlockSize: (uint32_t)numBytes
    withUserInfo: (NSDictionary *)aUserInfo
{
	return [self initWithSendOfFile: name
	 withSize: size withDelegate: aDelegate
	 withTimeout: seconds withBlockSize: numBytes
	 withUserInfo: aUserInfo withPort: -1 to: -1];
}
- (void)dealloc
{
	if (port)
	{
		[[NetApplication sharedInstance] disconnectObject: port];
		DESTROY(port);
		[timeout invalidate];
		DESTROY(timeout);
	}
	DESTROY(receivedData);
	DESTROY(dataToWrite);
	[super dealloc];
}
- (void)abortConnection
{
	[super abortConnection];
	if (port)
	{
		[[NetApplication sharedInstance] disconnectObject: port];
		DESTROY(port);
		if (timeout)
		{
			[timeout invalidate];
			DESTROY(timeout);
		}
		[self connectionLost];
	}
}		
- connectionEstablished: (id <NetTransport>)aTransport
{
	[super connectionEstablished: aTransport];
	
	[[NetApplication sharedInstance] disconnectObject: port];
	DESTROY(port);
	
	if (timeout)
	{
		[timeout invalidate];
		DESTROY(timeout);
	}
	
	[self checkAndWrite];

	return self;
}
- dataReceived: (NSData *)data
{
	char *buffer;
	char *index;
	char *bufferEnd;
	
	[receivedData appendData: data];

	index = buffer = [receivedData mutableBytes];
	
	bufferEnd = buffer + [receivedData length];

	while((index + 3) < bufferEnd)
	{
		confirmedBytes = ntohl(*((unsigned long int *)index));
				
		index += 4;
	}

	memmove(buffer, index, bufferEnd - index);
	
	[receivedData setLength: bufferEnd - index];
	
	if (confirmedBytes > transferredBytes)
	{
		[[NetApplication sharedInstance] disconnectObject: self];
	}
	
	[self checkAndWrite];
	
	return self;
}
- (void)connectionLost
{
	if ([status isEqualToString: DCCStatusTransferring])
	{
		if ((int)confirmedBytes != [[info objectForKey: DCCInfoFileSize] intValue])
		{
			[status release];
			status = [DCCStatusError retain];
		}
		else
		{
			[status release];
			status = [DCCStatusDone retain];
		}
		[delegate DCCStatusChanged: status forObject: self];
	}
	
	[super connectionLost];
}
- writeData: (NSData *)someData
{
	if (noMoreData)
	{
		[self checkAndWrite];
		return self;
	}
	if (!someData)
	{
		noMoreData = YES;
	}
	else
	{
		[dataToWrite appendData: someData];
	}
	[self checkAndWrite];
	return self;
}
- (uint32_t)blockSize
{
	return blockSize;
}
@end

