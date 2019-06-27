//
//  iMDVLNDevice.m
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNDevice.h"
#import "iMDVLNDeviceManager.h"
#import "NSError+libimobiledevice.h"
#import "NSColor+Hex.h"
#import "iMDVLNLockdowndClient.h"
#import "iMDVLNSpringboardClient.h"
#import "iMDVLNScreenshotrClient.h"

#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>

@interface iMDVLNDevice ()

@property (nonatomic, strong) NSString *UDID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *productType;
@property (nonatomic, strong) NSColor *deviceColor;
@property (nonatomic, strong) NSImage *wallpaper;
@property (nonatomic, strong) NSImage *screenshot;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenScaleFactor;
@property (nonatomic, assign) CGFloat springboardIconGridColumns;
@property (nonatomic, assign) CGFloat springboardIconGridRows;
@property (nonatomic, assign) CGFloat springboardIconMaxPages;
@property (nonatomic, assign) CGFloat springboardFolderGridColumns;
@property (nonatomic, assign) CGFloat springboardFolderGridRows;
@property (nonatomic, assign) CGFloat springboardFolderMaxPages;
@property (nonatomic, assign) CGFloat springboardDockIconMaxCount;
@property (nonatomic, assign) CGFloat springboardIconHeight;
@property (nonatomic, assign) CGFloat springboardIconWidth;
@property (nonatomic, assign) BOOL springboardVideosSupported;
@property (nonatomic, assign) BOOL springboardNewsStandSupported;
@property (nonatomic, assign) BOOL springboardWillSaveIconStateChanges;

@end

@implementation iMDVLNDevice

- (instancetype) initWithUDID:(NSString *)UDID
{
	if ((self = [super init]))
	{
		_UDID = UDID;
	}
	
	return self;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"VLNDevice: %@ - %@ - %@", self.name, self.productType, self.UDID];
}

#pragma mark - Clients

- (iMDVLNLockdowndClient *) lockdownClient
{
	if (_lockdownClient == nil) {
		_lockdownClient = [[iMDVLNLockdowndClient alloc] initWithDevice:self];
	}
	
	return _lockdownClient;
}

- (iMDVLNSpringboardClient *) springboardClient
{
	if (_springboardClient == nil) {
		_springboardClient = [[iMDVLNSpringboardClient alloc] initWithDevice:self];
	}
	
	return _springboardClient;
}

- (iMDVLNScreenshotrClient *) screenshotrClient
{
	if (_screenshotrClient == nil) {
		_screenshotrClient = [[iMDVLNScreenshotrClient alloc] initWithDevice:self];
	}
	
	return _screenshotrClient;
}

#pragma mark - Device

- (void) loadBasicDevicePropertiesWithCompletion:(void (^)())completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		[self.lockdownClient connect:&error];
		
		if (error == nil)
		{
			_name = [self.lockdownClient getPropertyForKey:@"DeviceName"];
			_productType = [self.lockdownClient getPropertyForKey:@"ProductType"];
			
			NSString *color = [self.lockdownClient getPropertyForKey:@"DeviceEnclosureColor"];
			_deviceColor = [NSColor colorFromHexadecimalValue:color];
			
			_screenHeight = [[self.lockdownClient getPropertyForKey:@"ScreenHeight" domain:@"com.apple.mobile.iTunes"] floatValue];
			_screenWidth = [[self.lockdownClient getPropertyForKey:@"ScreenWidth" domain:@"com.apple.mobile.iTunes"] floatValue];
			_screenScaleFactor = [[self.lockdownClient getPropertyForKey:@"ScreenScaleFactor" domain:@"com.apple.mobile.iTunes"] floatValue];
			
			[self.lockdownClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"IMDVLNDevice.loadBasicDevicePropertiesWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler();
			}
		});
	});
}

- (void) loadProperty:(NSString *)key domain:(NSString *)domain completion:(void (^)(id property, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSString *result = nil;
		NSError *error = nil;
		[self.lockdownClient connect:&error];
		
		if (error == nil)
		{
			result = [self.lockdownClient getPropertyForKey:key domain:domain];
			
			[self.lockdownClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.loadProperty: %@ domain %@ error %@", key, domain, error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler(result, error);
			}
		});
	});
}

#pragma mark - Images

- (void) getWallpaperWithCompletion:(void (^)(NSImage *wallpaper, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		NSImage *image = nil;
		[self.springboardClient connect:&error];
		
		if (error == nil)
		{
			image = [self.springboardClient getWallpaper:&error];
			
			if (error != nil) {
				NSLog(@"iMDVLNDevice.getWallpaperWithCompletion image %@ error %@", image, error);
			}
			
			[self.springboardClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.getWallpaperWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler(image, error);
			}
		});
	});
}

- (void) getScreenshotWithCompletion:(void (^)(NSImage *screenshot, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		NSImage *image = nil;
		[self.screenshotrClient connect:&error];
		
		if (error == nil)
		{
			image = [self.screenshotrClient getScreenshot:&error];
			
			if (error != nil) {
				NSLog(@"iMDVLNDevice.getScreenshotWithCompletion image %@ error %@", image, error);
			}
			
			[self.screenshotrClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.getScreenshotWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler(image, error);
			}
		});
	});
}

- (void) getAppIconForBundleId:(NSString *)bundleId withCompletion:(void (^)(NSImage *icon, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		NSImage *image = nil;
		[self.springboardClient connect:&error];
		
		if (error == nil)
		{
			image = [self.springboardClient getIconImageForBundleId:bundleId error:&error];
			
			if (error != nil) {
				NSLog(@"iMDVLNDevice.getAppIconForBundleId:%@withCompletion: image %@ error %@", bundleId, image, error);
			}
			
			[self.springboardClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.getAppIconForBundleId:%@withCompletion: error %@", bundleId, error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler(image, error);
			}
		});
	});
}

#pragma mark - Springboard

- (void) getIconStateWithCompletion:(void (^)(NSArray *iconState, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		NSArray *array = nil;
		[self.springboardClient connect:&error];
		
		if (error == nil)
		{
			array = [self.springboardClient getIconState:&error];
			
			if (error != nil) {
				NSLog(@"iMDVLNDevice.getIconStateWithCompletion array %@ error %@", array, error);
			}
			
			[self.springboardClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.getIconStateWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler(array, error);
			}
		});
	});
}

- (void) setIconState:(NSArray *)iconState withCompletion:(void (^)(BOOL result, NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		[self.springboardClient connect:&error];
		
		if (error == nil)
		{
			error = [self.springboardClient setIconState:iconState];
			
			if (error != nil) {
				NSLog(@"iMDVLNDevice.setIconStateWithCompletion array %@ error %@", iconState, error);
			}
			
			[self.springboardClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"iMDVLNDevice.setIconStateWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler((error == nil), error);
			}
		});
	});
}

#pragma mark - Springboard Icon Properties

- (void) loadSpringboardDisplayPropertiesWithCompletion:(void (^)())completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		NSError *error = nil;
		[self.lockdownClient connect:&error];
		
		if (error == nil)
		{
			_springboardIconGridColumns = [[self.lockdownClient getPropertyForKey:@"HomeScreenIconColumns" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardIconGridRows = [[self.lockdownClient getPropertyForKey:@"HomeScreenIconRows" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardIconMaxPages = [[self.lockdownClient getPropertyForKey:@"HomeScreenMaxPages" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardFolderGridColumns = [[self.lockdownClient getPropertyForKey:@"IconFolderColumns" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardFolderGridRows = [[self.lockdownClient getPropertyForKey:@"IconFolderRows" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardFolderMaxPages = [[self.lockdownClient getPropertyForKey:@"IconFolderMaxPages" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardDockIconMaxCount = [[self.lockdownClient getPropertyForKey:@"HomeScreenIconDockMaxCount" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardIconHeight = [[self.lockdownClient getPropertyForKey:@"HomeScreenIconHeight" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardIconWidth = [[self.lockdownClient getPropertyForKey:@"HomeScreenIconWidth" domain:@"com.apple.mobile.iTunes"] floatValue];
			_springboardVideosSupported = [[self.lockdownClient getPropertyForKey:@"HomeVideosSupported" domain:@"com.apple.mobile.iTunes"] boolValue];
			_springboardNewsStandSupported = [[self.lockdownClient getPropertyForKey:@"HomeScreenNewsstand" domain:@"com.apple.mobile.iTunes"] boolValue];
			_springboardWillSaveIconStateChanges = [[self.lockdownClient getPropertyForKey:@"IconStateSaves" domain:@"com.apple.mobile.iTunes"] boolValue];
			
			[self.lockdownClient disconnect:&error];
		}
		
		// Catch errors from connect/disconnect and methods
		if (error != nil) {
			NSLog(@"IMDVLNDevice.loadSpringboardDisplayPropertiesWithCompletion error %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (completionHandler) {
				completionHandler();
			}
		});
	});
}

- (NSError *)updateLocation:(NSString *)latitude longitude:(NSString *)longitude {
    
    NSError *error;
    
    do {
        if (![self.lockdownClient isConnected]) {
            
            [self.lockdownClient connect:nil];
            
            [self.lockdownClient connectToClient:nil];
            
            error = [self.lockdownClient connectToService:"com.apple.dt.simulatelocation"];
            if (error) {
                NSLog(@"connectToService error :\n%@", error.userInfo);
                break;
            }
        }
        
        error = [self.lockdownClient updateLocationWithLatitude:latitude longitude:longitude];
        if (error) {
            NSLog(@"updateLocationWithLatitude error :\n%@", error.userInfo);
            break;
        }
        
        break;

    } while (true);
    
    // must free client and service memory
    [self.lockdownClient disconnectFromClient:nil];
    
    return error;
    
}


@end
