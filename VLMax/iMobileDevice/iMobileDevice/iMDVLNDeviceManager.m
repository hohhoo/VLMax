//
//  iMDVLNDeviceManager.m
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNDeviceManager.h"
#import "NSError+libimobiledevice.h"
#import "iMDVLNDevice.h"
#import "iMDVLNConstants.h"
#import "iMDVLNPlistTools.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/sbservices.h>
#import <libimobiledevice/screenshotr.h>

void device_event_callback(const idevice_event_t *event, void *userdata);

@interface iMDVLNDeviceManager ()

@property (nonatomic, assign, getter=isSubscribedForNotifications) BOOL subscribedForNotifications;
@property (nonatomic, strong) NSMutableArray *connectedDevices;

@end

@implementation iMDVLNDeviceManager

+ (instancetype) sharedManager
{
	static iMDVLNDeviceManager *_sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[iMDVLNDeviceManager alloc] init];
	});
	return _sharedManager;
}

- (id) init
{
	if ((self = [super init]))
	{
		_connectedDevices = [NSMutableArray array];
	}
	
	return self;
}

#pragma mark - Device connection event subscriptions

- (BOOL) subscribeForNotifications:(NSError **)error
{
	if (self.isSubscribedForNotifications) {
		return YES;
	}
	
	idevice_error_t errCode = idevice_event_subscribe(&device_event_callback, NULL);
	if (error != IDEVICE_E_SUCCESS)
	{
		*error = [NSError errorWithDeviceErrorCode:errCode];
		return NO;
	}
	
	self.subscribedForNotifications = YES;
	
	return YES;
}

- (BOOL) unsubscribeForNotifications:(NSError **)error
{
	if (!self.isSubscribedForNotifications) {
		return YES;
	}
	
	idevice_error_t errCode = idevice_event_unsubscribe();
	if (error != IDEVICE_E_SUCCESS)
	{
		*error = [NSError errorWithDeviceErrorCode:errCode];
		return NO;
	}
	
	self.subscribedForNotifications = NO;
	
	return YES;
}

void device_event_callback(const idevice_event_t *event, void *userdata)
{
	[[iMDVLNDeviceManager sharedManager] checkNewDeviceEvent:event userData:userdata];
}

- (void) checkNewDeviceEvent:(const idevice_event_t *)event userData:(void *)userdata
{
	NSString *udid = [[NSString alloc] initWithCString:event->udid encoding:NSUTF8StringEncoding];
	
	if (event->event == IDEVICE_DEVICE_ADD)
	{
		NSLog(@"iMDVLNDeviceManager.checkNewDeviceEvent: device added UDID: %@", udid);
	}
	else if (event->event == IDEVICE_DEVICE_REMOVE)
	{
		NSLog(@"iMDVLNDeviceManager.checkNewDeviceEvent: device removed UDID: %@", udid);
	}
	
	[self updateConnectedDevices];
}

#pragma mark - Update Avaliable Devices

- (void) updateConnectedDevices
{
	@synchronized(self)
	{
		NSMutableArray *oldDevices = [NSMutableArray arrayWithArray:self.connectedDevices];
		NSMutableArray *newDevices = [NSMutableArray array];
		
		char **list = nil;
		int count = 0;
		idevice_error_t errCode = idevice_get_device_list(&list, &count);
		if (errCode != IDEVICE_E_SUCCESS)
		{
			NSLog(@"iMDVLNDeviceManager.updateConnectedDevices error %@", [NSError errorWithDeviceErrorCode:errCode]);
		}
		
		int index = 0;
		for (; list[index] != NULL; index++)
		{
			iMDVLNDevice *device = [self createDeviceFromUDID:list[index]];
			[oldDevices removeObject:device];
			[newDevices addObject:device];
		}
		
		idevice_device_list_free(list);
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			[self removeDevices:oldDevices];
			[self addDevices:newDevices];
		});
	}
}

- (iMDVLNDevice *) createDeviceFromUDID:(const char *)udid
{
	NSString *deviceId = [NSString stringWithUTF8String:udid];
	
	// Check existing
	iMDVLNDevice *device = [self deviceWithUDID:deviceId];
	if (device == nil) {
		device = [[iMDVLNDevice alloc] initWithUDID:deviceId];
	}
	
	return device;
}

#pragma mark - Device List

- (NSArray *) devices
{
	return [NSArray arrayWithArray:self.connectedDevices];
}

- (iMDVLNDevice *) deviceWithUDID:(NSString *)UDID
{
	NSArray *devices = [self.connectedDevices valueForKeyPath:@"UDID"];
	NSInteger index = [devices indexOfObject:UDID];
	if (index != NSNotFound) {
		return [self.connectedDevices objectAtIndex:index];
	}
	
	return nil;
}

- (void) addDevices:(NSArray *)devices
{
	for (iMDVLNDevice *device in devices) {
		[self addDevice:device];
	}
}

- (void) addDevice:(iMDVLNDevice *)device
{
	if ([[self.connectedDevices valueForKeyPath:@"UDID"] containsObject:device.UDID]) {
		NSLog(@"iMDVLNDeviceManager.addDevice Cannot add device as _connectedDevices already contains device UDID (%@)", device.UDID);
		return;
	}
	
	[self.connectedDevices addObject:device];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:iMDVLNDeviceAddedNotification object:[iMDVLNDeviceManager sharedManager]
													  userInfo:@{iMDVLNDeviceNotificationKeyUDID: device.UDID}];
}

- (void) removeDevices:(NSArray *)devices
{
	for (iMDVLNDevice *device in devices) {
		[self removeDevice:device];
	}
}

- (void) removeDevice:(iMDVLNDevice *)device
{
	if (![[self.connectedDevices valueForKeyPath:@"UDID"] containsObject:device.UDID]) {
		NSLog(@"iMDVLNDeviceManager.removeDevice Cannot remove device as _connectedDevices does not contain device UDID (%@)", device.UDID);
		return;
	}
	
	[self.connectedDevices removeObject:device];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:iMDVLNDeviceRemovedNotification object:[iMDVLNDeviceManager sharedManager]
													  userInfo:@{iMDVLNDeviceNotificationKeyUDID: device.UDID}];
}

@end
