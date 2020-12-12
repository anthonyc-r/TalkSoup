/***************************************************************************
                                ServerListController.m
                          -------------------
    begin                : Wed Apr 30 14:30:59 CDT 2003
    copyright            : (C) 2005 by Andrew Ruder
                         : (C) 2013-2015 The GNUstep Applicaiton Project
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

#import "Controllers/ServerListController.h"
#import "Controllers/GroupEditorController.h"
#import "Controllers/ServerEditorController.h"
#import "Controllers/ServerListConnectionController.h"
#import "Controllers/ContentControllers/ContentController.h"
#import "GNUstepOutput.h"

#import <Foundation/NSNotification.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSBundle.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSClipView.h>
#import <AppKit/NSScroller.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObject.h>
#import <AppKit/NSCell.h>

NSString *ServerListInfoEncoding = @"Encoding";
NSString *ServerListInfoWindowFrame = @"WindowFrame";
NSString *ServerListInfoCommands = @"Commands";
NSString *ServerListInfoServer = @"Server";
NSString *ServerListInfoPort = @"Port";
NSString *ServerListInfoName = @"Name";
NSString *ServerListInfoEntries = @"Entries";
NSString *ServerListInfoAutoConnect = @"AutoConnect";
NSString *ServerListFavorites = @"Favorites";

#define APP_SUPPORT @"/ApplicationSupport/"
#ifndef GNUSTEP
#undef APP_SUPPORT
#define APP_SUPPORT @"/Application Support/"
#endif

#define RSRC_DIR @"/Resources/"
#ifndef GNUSTEP
#undef RSRC_DIR 
#define RSRC_DIR @"/Contents/Resources/"
#endif

static NSMutableArray *add_favorites(NSMutableArray *anArray)
{
	NSEnumerator *iter;
	id object;

	iter = [anArray objectEnumerator];
	while ((object = [iter nextObject])) 
	{
		if ([[object objectForKey: ServerListInfoName] 
		  isEqualToString: _l(ServerListFavorites)])
		{
			return anArray;
		}
	}

	object = [[NSMutableDictionary new] autorelease];
	[object setObject: _l(ServerListFavorites) forKey: ServerListInfoName];
	[object setObject: [[NSMutableArray new] autorelease] forKey: ServerListInfoEntries];
	[anArray addObject: object];

	return anArray;
}	

static id mutable_object(id object)
{
	if ( [object isKindOfClass: [NSString class]] && 
	    ![object isKindOfClass: [NSMutableString class]])
	{
		return [NSMutableString stringWithString: object];
	} 
	else if ( [object isKindOfClass: [NSDictionary class]] )
	{
		id dict = [NSMutableDictionary dictionaryWithCapacity: [object count]];
		id iter;
		id iterobj;

		iter = [object keyEnumerator];
		while ((iterobj = [iter nextObject]))
		{
			[dict setObject: mutable_object([object objectForKey: iterobj])
			  forKey: iterobj];
		}

		return dict;
	}
	else if ( [ object isKindOfClass: [NSArray class]] )
	{
		id arr = [NSMutableArray arrayWithCapacity: [object count]];
		id iter;
		id iterobj;

		iter = [object objectEnumerator];
		while ((iterobj = [iter nextObject]))
		{
			[arr addObject: mutable_object(iterobj)];
		}

		return arr;
	}
	
	return object;
}

static NSComparisonResult sort_server_dictionary(id first, id second, void *x)
{
	if ([[first objectForKey: ServerListInfoName] 
	  isEqualToString: _l(ServerListFavorites)])
		return NSOrderedAscending;
		
	if ([[second objectForKey: ServerListInfoName] 
	  isEqualToString: _l(ServerListFavorites)])
		return NSOrderedDescending;
		
	return [[first objectForKey: ServerListInfoName] caseInsensitiveCompare:
	  [second objectForKey: ServerListInfoName]];
}

/* Giant hack alert!  This reloads a column then attempts
 * to pretty much restore it's position.
 */
static void reload_column(NSBrowser *browse, NSInteger col)
{
	id matrix;
	NSPoint myPos;
	NSRect visRect;
	NSInteger row1, row2;
	NSInteger col1, col2;
	NSInteger row3, rows;

	if (!browse) return;

	matrix = [browse matrixInColumn: col];

	if (!matrix)
	{
		[browse reloadColumn: col];
		return;
	}

	visRect = [matrix visibleRect];
	myPos = visRect.origin;
	[matrix getRow: &row1 column: &col1 forPoint: myPos];

	myPos = visRect.origin;
	myPos.y += visRect.size.height;
	[matrix getRow: &row2 column: &col2 forPoint: myPos];

	row3 = [browse selectedRowInColumn: col];

	[browse reloadColumn: col];
	matrix = [browse matrixInColumn: col];
	rows = [matrix numberOfRows];
	if (row2 > rows) row2 = rows;
	if (row3 > rows) row3 = rows;
	if (row1 > rows) row1 = rows;

	[browse selectRow: row2 inColumn: col];
	[browse selectRow: row1 inColumn: col];
	if (row3 <= row2 && row3 >= row1)
		[browse selectRow: row3 inColumn: col];
}

@implementation ServerListController
+ (BOOL)saveServerListPreferences: (NSArray *)aPrefs
{
	NSArray *x;
	NSFileManager *fm;
	NSEnumerator *iter;
	id object;
	BOOL isDir;
	NSString *subdir;

	if (!aPrefs) return NO;

	x = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
	  NSUserDomainMask, YES);

	fm = [NSFileManager defaultManager];

	iter = [x objectEnumerator];

	subdir = APP_SUPPORT @"TalkSoup";

	while ((object = [iter nextObject]))
	{
		NSString *fullPath = [object stringByAppendingString: subdir];

		/* Recursively create the directory if it does not exist */
		if (![fm fileExistsAtPath: fullPath isDirectory: &isDir])
		{
			NSArray *level;
			id object2;
			NSEnumerator *iter;
			NSMutableString *sofar = [[NSMutableString new] autorelease]; 
			NSString *test;

			level = [subdir pathComponents];
			iter = [level objectEnumerator];
			[iter nextObject];
			while ((object2 = [iter nextObject])) 
			{
				[sofar appendString: @"/"];
				[sofar appendString: object2];
				test = [object stringByAppendingString: sofar];
				if ([fm fileExistsAtPath: test isDirectory: &isDir])
				{
					if (isDir) continue;
					break;
				}	
				if (![fm createDirectoryAtPath: test attributes: nil]) 
					break;
			}
		}
			
		if ([fm fileExistsAtPath: fullPath isDirectory: &isDir] && isDir)
		{
			id dict = [[NSMutableDictionary new] autorelease];
			object = [fullPath stringByAppendingString: @"/ServerList.plist"];

			[dict setObject: aPrefs forKey: @"Servers"];
			
			if ([dict writeToFile: object atomically: YES])
			{
				return YES;
			}
		}
	}

	return NO;
}
+ (NSMutableArray *)serverListPreferences
{
	NSArray *x;
	NSFileManager *fm;
	NSEnumerator *iter;
	id object;
	BOOL isDir;
	NSMutableArray *subdirs;

	fm = [NSFileManager defaultManager];

	subdirs = [[NSMutableArray new] autorelease];

	x = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
	  NSAllDomainsMask, YES);
	iter = [x objectEnumerator];

	while ((object = [iter nextObject]))
	{
		object = [object stringByAppendingString: APP_SUPPORT @"TalkSoup"];
		[subdirs addObject: object];
	}
	[subdirs addObject: 
	  [[NSBundle bundleForClass: [GNUstepOutput class]] resourcePath]];

	iter = [subdirs objectEnumerator];
	while ((object = [iter nextObject]))
	{
		object = [object stringByAppendingString: @"/ServerList.plist"];

		if ([fm fileExistsAtPath: object isDirectory: &isDir] && !isDir)
		{
			id dict = [NSDictionary dictionaryWithContentsOfFile: object];
			id obj;
			
			if (dict && (obj = [dict objectForKey: @"Servers"])
			 && [obj isKindOfClass: [NSArray class]])
			{
				return add_favorites(mutable_object(obj));
			}
		}
	}

	return add_favorites([[NSMutableArray new] autorelease]);
}
+ (BOOL)startAutoconnectServers
{
	id tmp = [ServerListController serverListPreferences];
	NSEnumerator *iter;
	NSEnumerator *iter2;
	BOOL hadOne = NO;
	id o1, o2;
	int g = 0, r; 

	iter = [tmp objectEnumerator];
	while ((o1 = [iter nextObject]))
	{
		iter2 = [[o1 objectForKey: ServerListInfoEntries] objectEnumerator];
		r = 0;
		while ((o2 = [iter2 nextObject]))
		{
			if ([[o2 objectForKey: ServerListInfoAutoConnect]
			  isEqualToString: @"YES"])
			{
				[[[ServerListConnectionController alloc]
				 initWithServerListDictionary: o2 inGroup: g atRow: r
				 withContentController: nil] autorelease];
				hadOne = YES;
			}	
			r++;
		}
		g++;
	}

	return hadOne;
}
+ (void)setServer: (NSDictionary *)x inGroup: (NSInteger)group row: (NSInteger)row
{
	id tmp = [ServerListController serverListPreferences]; 
	id array;
	
	if (group >= (NSInteger)[tmp count] || group < 0) return;
	
	array = [[tmp objectAtIndex: group]
	  objectForKey: ServerListInfoEntries];
	  
	if (row >= (NSInteger)[tmp count] || row < 0) return;
	
	[array replaceObjectAtIndex: row withObject: x];

	[ServerListController saveServerListPreferences: tmp];
}
+ (NSDictionary *)serverInGroup: (NSInteger)group row: (NSInteger)row
{
	id tmp = [self serverListPreferences];
	
	if (group >= (NSInteger)[tmp count] || group < 0) return nil;
	
	tmp = [[tmp objectAtIndex: group] 
	  objectForKey: ServerListInfoEntries];
	
	if (row >= (NSInteger)[tmp count] || row < 0) return nil;
	
	return [tmp objectAtIndex: row];
}
- (BOOL)saveServerListPreferences: (NSArray *)aPrefs
{
	[cached autorelease];
	cached = nil;

	return [ServerListController saveServerListPreferences: aPrefs];
}
- (NSMutableArray *)serverListPreferences
{
	if (!cached) 
	{
		cached = [[ServerListController serverListPreferences] retain];
		[cached sortUsingFunction: sort_server_dictionary context: 0]; 
	}

	return cached;
}
- (BOOL)serverFound: (NSDictionary *)x inGroup: (NSInteger *)group row: (NSInteger *)row
{
	id tmp = [self serverListPreferences];
	NSEnumerator *iter;
	NSEnumerator *iter2;
	id o1, o2;
	NSInteger g = 0, r;
	
	iter = [tmp objectEnumerator];
	while ((o1 = [iter nextObject]))
	{
		iter2 = [[o1 objectForKey: ServerListInfoEntries] objectEnumerator];
		r = 0;
		while ((o2 = [iter2 nextObject]))
		{
			if ([o2 isEqual: x])
			{
				if (group) *group = g;
				if (row) *row = r;
				return YES;
			}
			r++;
		}
		g++;
	}
	
	return NO;
}
- (void)awakeFromNib
{
	[browser setMaxVisibleColumns: 2];
	[browser setHasHorizontalScroller: NO];
	[browser setAllowsMultipleSelection: NO];
	[browser setAllowsEmptySelection: NO];
	[browser setAllowsBranchSelection: NO];
	
	[browser setDoubleAction: @selector(connectHit:)];
	[browser setDelegate: self];
	[browser setTarget: self];
	[window setDelegate: self];
	[window makeKeyAndOrderFront: nil];
	
	[browser reloadColumn: 0];
	[window makeFirstResponder: browser];
	
	[self retain];
	wasEditing = -1;
}
- (void)dealloc
{
	[window retain];
	[[editor window] close];
	
	[super dealloc];
}
- (void)editorDone: (id)sender
{
	NSString  *string;
	
	if (!editor) return;
	
	string = [[[[editor entryField] stringValue] retain] autorelease];
	
	if ([string length] == 0)
	{
		[[editor extraField] setStringValue:
		  _l(@"Specify entry name")];
		[[editor window] makeFirstResponder: [editor entryField]]; 
		return;
	}
	
	if ([editor isKindOfClass: [GroupEditorController class]])
	{
		NSMutableArray *x;
		id newOne;
		x = [self serverListPreferences];
		
		if (wasEditing != -1 && wasEditing < (int)[x count])
		{
			newOne = [x objectAtIndex: wasEditing];
			[newOne setObject: string forKey: ServerListInfoName];
			
			[x replaceObjectAtIndex: wasEditing withObject: newOne];
		}
		else
		{
			newOne = [NSDictionary dictionaryWithObjectsAndKeys:
			  string, ServerListInfoName,
			  [[NSArray new] autorelease], ServerListInfoEntries,
			  nil];

			[x addObject: newOne]; 
		}
	
		[self saveServerListPreferences: x];
	
		reload_column(browser, 0);
		
		[[editor window] close];
		[window makeKeyAndOrderFront: nil];
	}
	else if ([editor isKindOfClass: [ServerEditorController class]])
	{
		NSString *server = [[editor serverField] stringValue];
		NSString *commands = [[editor commandsText] string];
		NSString *nick = [[editor nickField] stringValue];
		NSString *user = [[editor userField] stringValue];
		NSString *real = [[editor realField] stringValue];
		NSString *password = [[editor passwordField] stringValue];
		NSString *port = [[editor portField] stringValue];
		int first = [browser selectedRowInColumn: 0];
		id autoconnect;
		
		NSMutableArray *array;
		id newOne;
		id prefs = [self serverListPreferences];
		
		if ([server length] == 0)
		{
			[[editor extraField] setStringValue: 
			  _l(@"Specify the server")];
			[[editor window] makeFirstResponder: [editor serverField]];
			return;
		}
		
		if ([port length] == 0)
		{
			port = @"6667";
		}
		
		if (first >= (int)[prefs count] || first < 0)
		{			
			return;
		}
		
		if ([[editor connectButton] state] == NSOnState)
		{
			autoconnect = @"YES";
		}
		else
		{
			autoconnect = @"NO";
		}
		
		array = [[prefs objectAtIndex: first] objectForKey: ServerListInfoEntries];
				
		if (wasEditing != -1 && wasEditing < (int)[array count])
		{
			newOne = [array objectAtIndex: wasEditing];
			[newOne setObject: server forKey: ServerListInfoServer];
			[newOne setObject: commands forKey: ServerListInfoCommands];
			[newOne setObject: nick forKey: IRCDefaultsNick];
			[newOne setObject: real forKey: IRCDefaultsRealName];
			[newOne setObject: password forKey: IRCDefaultsPassword];
			[newOne setObject: user forKey: IRCDefaultsUserName];
			[newOne setObject: port forKey: ServerListInfoPort];
			[newOne setObject: string forKey: ServerListInfoName];
			[newOne setObject: autoconnect forKey: ServerListInfoAutoConnect];
			[array replaceObjectAtIndex: wasEditing withObject: newOne];
		}
		else
		{
			newOne = [NSDictionary dictionaryWithObjectsAndKeys:
			 server, ServerListInfoServer,
			 commands, ServerListInfoCommands,
			 nick, IRCDefaultsNick,
			 real, IRCDefaultsRealName,
			 password, IRCDefaultsPassword,
			 user, IRCDefaultsUserName,
			 port, ServerListInfoPort,
			 string, ServerListInfoName,
			 autoconnect, ServerListInfoAutoConnect,
			 nil];
			[array addObject: newOne];
		}
	
		[self saveServerListPreferences: prefs];
	
		reload_column(browser, 1);
		
		[[editor window] close];
		[window makeKeyAndOrderFront: nil];
	}
}
- (void)addEntryHit: (NSButton *)sender
{
	if (editor)
	{
		if ([editor isKindOfClass: [ServerEditorController class]])
		{
			[[editor window] makeKeyAndOrderFront: nil];
			return;
		}
		else
		{
			[[editor window] close];
		}
	}
	
	if ([browser selectedColumn] < 0) return;
	
	editor = [[ServerEditorController alloc] init];
	if (![NSBundle loadNibNamed: @"ServerEditor" owner: editor])
	{
		[editor release];
		editor = nil;
		return;
	}
	
	[[editor window] setDelegate: self];
	[[editor okButton] setTarget: self];
	[[editor okButton] setAction: @selector(editorDone:)];
}
- (void)addGroupHit: (NSButton *)sender
{
	if (editor)
	{
		if ([editor isKindOfClass: [GroupEditorController class]])
		{
			[[editor window] makeKeyAndOrderFront: nil];
			return;
		}
		else
		{
			[[editor window] close];
		}
	}
	
	editor = [[GroupEditorController alloc] init];
	if (![NSBundle loadNibNamed: @"GroupEditor" owner: editor])
	{
		[editor release];
		editor = nil;
		return;
	}
	
	[[editor window] setDelegate: self];
	[[editor okButton] setTarget: self];
	[[editor okButton] setAction: @selector(editorDone:)];
}
- (void)editHit: (NSButton *)sender
{
	id tmp = [self serverListPreferences]; 
	NSInteger row;
	id o;

	if ([browser selectedColumn] == 0)
	{
		row = [browser selectedRowInColumn: 0];
		
		if (row >= (NSInteger)[tmp count] || row < 0) return;
		
		[self addGroupHit: nil];
		
		o = [tmp objectAtIndex: row];
		[[editor entryField] setStringValue: [o objectForKey: ServerListInfoName]];
		
		wasEditing = row;
	}
	else
	{
		NSInteger first = [browser selectedRowInColumn: 0];
		row = [browser selectedRowInColumn: 1];
		
		if (first >= (NSInteger)[tmp count] || first < 0) return;
		
		o = [[tmp objectAtIndex: first] objectForKey: ServerListInfoEntries];
		
		if (row >= (NSInteger)[o count] || row < 0) return;
		
		[self addEntryHit: nil];

		o = [o objectAtIndex: row];
		
		[[editor entryField] setStringValue: [o objectForKey: ServerListInfoName]]; 
		[[editor nickField] setStringValue: [o objectForKey: IRCDefaultsNick]]; 
		[[editor realField] setStringValue: [o objectForKey: IRCDefaultsRealName]]; 
		[[editor passwordField] setStringValue: [o objectForKey: IRCDefaultsPassword]]; 
		[[editor userField] setStringValue: [o objectForKey: IRCDefaultsUserName]]; 
		[[editor serverField] setStringValue: [o objectForKey: ServerListInfoServer]]; 
		[[editor portField] setStringValue: [o objectForKey: ServerListInfoPort]];
		[[editor commandsText] setString: [o objectForKey: ServerListInfoCommands]];
		if ([[o objectForKey: ServerListInfoAutoConnect] isEqualToString: @"YES"])
		{
			[[editor connectButton] setState: NSOnState];
		}
		else
		{
			[[editor connectButton] setState: NSOffState];
		}
		
		wasEditing = row;
	}
}
- (void)removeHit: (NSButton *)sender
{
	id prefs = [self serverListPreferences];
	NSInteger row;
	
	if ([browser selectedColumn] == 0)
	{
		row = [browser selectedRowInColumn: 0];
		
		if (row >= (NSInteger)[prefs count]) return;
		
		[prefs removeObjectAtIndex: row];
		
		[self saveServerListPreferences: prefs];
	
		reload_column(browser, 0);
	}
	else
	{
		id x;
		NSInteger first = [browser selectedRowInColumn: 0];
		row = [browser selectedRowInColumn: 1];
		
		if (first >= (NSInteger)[prefs count]) return;
		
		x = [[prefs objectAtIndex: first] objectForKey: ServerListInfoEntries];
		
		if (row >= (NSInteger)[x count]) return;
		
		[x removeObjectAtIndex: row];
		
		[self saveServerListPreferences: prefs];
	
		reload_column(browser, 1);
	}		
}
- (void)connectHit: (NSButton *)sender
{
	id tmp = [self serverListPreferences];
	id aContent = nil;
	id aConnect;
	
	NSInteger first, row;
	if ([browser selectedColumn] != 1) return;
	
	first = [browser selectedRowInColumn: 0];
	row = [browser selectedRowInColumn: 1];
	
	if (first >= (NSInteger)[tmp count]) return;
	
	tmp = [[tmp objectAtIndex: first] objectForKey: ServerListInfoEntries];
	
	if (row >= (NSInteger)[tmp count]) return;

	if ([forceButton state] == NSOffState)
	{
		id tmpArray;
		tmpArray = [_GS_ unconnectedConnectionControllers];
		if ([tmpArray count])
		{
			aConnect = [tmpArray objectAtIndex: 0];
			aContent = [[aConnect contentController] retain];
			[aContent autorelease];
			[aContent setConnectionController: nil];
			[aConnect setContentController: nil];
		}
	}	

	aConnect = [[ServerListConnectionController alloc]
	  initWithServerListDictionary: [tmp objectAtIndex: row]
	  inGroup: first atRow: row withContentController: aContent];
	[aConnect autorelease];

	aContent = [aConnect contentController];
	
	[[editor window] close];
	[window close];

	[[[aContent primaryMasterController] window] makeKeyAndOrderFront: nil];	
}
- (void)forceHit: (NSButton *)sender
{
}
- (NSBrowser *)browser
{
	return browser;
}
- (NSWindow *)window
{
	return window;
}
@end

@interface ServerListController (WindowDelegate)
@end

@implementation ServerListController (WindowDelegate)
- (void)windowWillClose: (NSNotification *)aNotification
{
	if ([aNotification object] == window)
	{
		[window setDelegate: nil];
		[browser setDelegate: nil];
		[browser setTarget: nil];
		[self autorelease];
	}
	else if ([aNotification object] == [editor window])
	{
		[[editor window] setDelegate: nil];
		[[editor okButton] setTarget: nil];
		[editor autorelease];
		editor = nil;
		wasEditing = -1;
	}
}	
@end

@interface ServerListController (BrowserDelegate)
@end

@implementation ServerListController (BrowserDelegate)
- (int)browser: (NSBrowser *)sender numberOfRowsInColumn: (NSInteger)column
{
	id serverList = [self serverListPreferences]; 
	
	if (!serverList)
	{
		return 0;
	}
	
	if (column == 0)
	{
		return [serverList count]; 
	}
	if (column == 1)
	{
		NSInteger col = [sender selectedRowInColumn: 0];
		id group;
		
		if (col >= (NSInteger)[serverList count])
		{
			return 0;
		}
		
		group = [serverList objectAtIndex: col];
		
		group = [group objectForKey: ServerListInfoEntries];
		
		return [group count];
	}
		
	return 0;	
}
- (NSString *)browser: (NSBrowser *)sender titleOfColumn: (NSInteger)column
{
	if (column == 0)
	{
		return _l(@"Groups");
	}
	if (column == 1)
	{
		return _l(@"Servers");
	}
	
	return @"";
}
- (void)browser: (NSBrowser *)sender willDisplayCell: (id)cell
  atRow: (NSInteger)row column: (NSInteger)column
{
	id serverList = [self serverListPreferences]; 

	if (!serverList) return;
	
	if (column == 0)
	{
		id tmp;
		
		if (row >= (NSInteger)[serverList count]) return;
		
		tmp = [serverList objectAtIndex: row];
		[cell setStringValue: [tmp objectForKey: ServerListInfoName]];
		[cell setLeaf: NO];
	}
	else if (column == 1)
	{
		id tmp;
		NSInteger first;
		
		first = [sender selectedRowInColumn: 0];
		
		if (first >= (int)[serverList count]) return;
		
		tmp = [serverList objectAtIndex: first];
		tmp = [tmp objectForKey: ServerListInfoEntries];
		
		if (row >= (NSInteger)[tmp count]) return;
		
		tmp = [tmp objectAtIndex: row];
		
		[cell setStringValue: [tmp objectForKey: ServerListInfoName]];
		[cell setLeaf: YES];
	}
	[cell setFont: [NSFont userFontOfSize: 0.0]];
}

@end
