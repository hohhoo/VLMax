//
//  AppDelegate.m
//  iMobileTestApp
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSWindowController *windowController;

@end

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSError *error = nil;
	[[iMDVLNDeviceManager sharedManager] subscribeForNotifications:&error];
	
	if (error) {
		NSLog(@"AppDelegate.applicationDidFinishLaunching error subscribing to notifications %@", error);
	}
	
	self.windowController = [[NSWindowController alloc] initWithWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	NSError *error = nil;
	[[iMDVLNDeviceManager sharedManager] unsubscribeForNotifications:&error];
	
	if (error) {
		NSLog(@"AppDelegate.applicationWillTerminate error unsubscribing from notifications %@", error);
	}
}

@end
