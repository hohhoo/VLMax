//
//  DeviceInfoWindow.m
//  iMobileDevice
//
//  Created by Daniel Love on 28/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "DeviceInfoWindow.h"
#import "NSColor+Hex.h"

@interface DeviceInfoWindow ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoadingDeviceProperties;

@property (nonatomic, assign) NSInteger iconCount;

@end

@implementation DeviceInfoWindow

- (void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceAdded:)
												 name:iMDVLNDeviceAddedNotification
											   object:[iMDVLNDeviceManager sharedManager]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceRemoved:)
												 name:iMDVLNDeviceRemovedNotification
											   object:[iMDVLNDeviceManager sharedManager]];
	
	[self.devicePopup.menu setDelegate:self];
	[self updateDevicePopup];
}

#pragma mark - Notifications

- (void) deviceAdded:(NSNotification *)notification
{
	[self updateDevicePopup];
}

- (void) deviceRemoved:(NSNotification *)notification
{
	[self updateDevicePopup];
}

#pragma mark - Device popup

- (void) updateDevicePopup
{
	[self.devicePopup removeAllItems];
	[self.deviceNameTextField setStringValue:@""];
	[self.deviceProductTypeTextField setStringValue:@""];
	
	[self.deviceWidthTextField setStringValue:@""];
	[self.deviceHeightTextField setStringValue:@""];
	[self.deviceWidthScaledTextField setStringValue:@""];
	[self.deviceHeightScaledTextField setStringValue:@""];
	
	[self.deviceColorTextField setStringValue:@""];
	self.deviceColorWell.color = [NSColor blackColor];
	
	[self.customKeyTextField setStringValue:@""];
	[self.customDomainTextField setStringValue:@""];
	[self.outputTextField setString:@""];
	
	self.wallpaperImageView.image = nil;
	
	NSArray *devices = [iMDVLNDeviceManager sharedManager].devices;
	
	for (iMDVLNDevice *device in devices)
	{
		[self.devicePopup addItemWithTitle:device.UDID];
	}
}

#pragma mark - NSMenuDelegate

- (IBAction) loadDevice:(id)sender
{
	if (self.isLoadingDeviceProperties) {
		return;
	}
	
	self.isLoadingDeviceProperties = YES;
	
	[self.timer invalidate];
	self.timer = nil;
	
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	[device loadBasicDevicePropertiesWithCompletion:^
	{
		if (device.name == nil)
		{
			NSLog(@"Failed to load device name, something might be up");
			
			self.isLoadingDeviceProperties = NO;
			return;
		}
		
		[self.deviceNameTextField setStringValue:device.name];
		[self.deviceProductTypeTextField setStringValue:device.productType];
		
		[self.deviceColorTextField setStringValue:device.deviceColor.hexadecimalValue];
		self.deviceColorWell.color = device.deviceColor;
		
		[self.deviceWidthTextField setStringValue:[NSString stringWithFormat:@"%.0f",device.screenWidth / device.screenScaleFactor]];
		[self.deviceHeightTextField setStringValue:[NSString stringWithFormat:@"%.0f",device.screenHeight / device.screenScaleFactor]];
		
		[self.deviceWidthScaledTextField setStringValue:[NSString stringWithFormat:@"%.0f (%.0f)",device.screenWidth, device.screenScaleFactor]];
		[self.deviceHeightScaledTextField setStringValue:[NSString stringWithFormat:@"%.0f (%.0f)",device.screenHeight, device.screenScaleFactor]];
		
		[self updateWallpaperForDevice:device];
	}];
}

#pragma mark - Images

- (void) updateWallpaperForDevice:(iMDVLNDevice *)device
{
	self.reloadWallpaperButton.title = @"Reloading...";
	
	[device getWallpaperWithCompletion:^(NSImage *wallpaper, NSError *error)
	{
		self.wallpaperImageView.image = wallpaper;
		[self resizeImageView:self.wallpaperImageView forSize:wallpaper.size];
		
		self.reloadWallpaperButton.title = @"Reload";
		
		[self updateScreenshot];
		
		if (self.timer) {
			[self.timer invalidate];
			self.timer = nil;
		}
		
		self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(updateScreenshot) userInfo:nil repeats:YES];
	}];
}

- (void) updateScreenshot
{
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	if (device == nil)
	{
		[self.timer invalidate];
		self.timer = nil;
	}
	
	self.reloadScreenshotButton.title = @"Reloading...";
	
	[device getScreenshotWithCompletion:^(NSImage *screenshot, NSError *error)
	{
		if (screenshot == nil) {
			NSLog(@"Note, screenshots will likely fail over Wi-Fi, ideally connect via USB.");
		}
		
		self.screenshotImageView.image = screenshot;
		[self resizeImageView:self.screenshotImageView forSize:screenshot.size];
		
		self.reloadScreenshotButton.title = @"Reload";
	}];
}

- (void) resizeImageView:(NSImageView *)imageView forSize:(NSSize)size
{
	CGFloat max = 105.0f;
	
	CGRect frame = imageView.frame;
	CGFloat ratio = 1.0;
	
	CGFloat width = size.width;
	CGFloat height = size.height;
	if (width > max)
	{
		ratio = max / width;
		height = height * ratio;
		width = width * ratio;
	}
	
	if (height > max)
	{
		ratio = max / height;
		height = height * ratio;
		width = width * ratio;
	}
	
	size.height = height;
	size.width = width;
	
	frame.size = size;
	imageView.frame = frame;
}

#pragma mark - Properties

- (IBAction) getProperty:(id)sender
{
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	NSString *key = self.customKeyTextField.stringValue;
	if ([key isEqual:@""]) {
		key = nil;
	}
	
	NSString *domain = self.customDomainTextField.stringValue;
	if ([domain isEqual:@""]) {
		domain = nil;
	}
	
	[device loadProperty:key domain:domain completion:^(id property, NSError *error)
	{
		NSLog(@"Error %@", error);
		
		if (property == nil) {
			property = @"nil";
		}
		
		[self.outputTextField setString:property];
	}];
}

- (IBAction) reloadWallpaper:(id)sender
{
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	[self updateWallpaperForDevice:device];
}

- (IBAction) reloadScreenshot:(id)sender
{
	[self updateScreenshot];
}

#pragma mark - Icon state

- (IBAction) getIconState:(id)sender
{
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	[device getIconStateWithCompletion:^(NSArray *iconState, NSError *error)
	{
		[self.outputTextField setString:[NSString stringWithFormat:@"%@", iconState]];
		
		// Refresh the app icon
		_iconCount +=1;
		if (_iconCount > [[iconState objectAtIndex:1] count]-1) {
			_iconCount = 0;
		}
		
		NSDictionary *appDefinition = [[iconState objectAtIndex:1] objectAtIndex:_iconCount];
		self.appIconLabel.stringValue = [appDefinition objectForKey:@"displayName"];
		
		[device getAppIconForBundleId:[appDefinition objectForKey:@"bundleIdentifier"]
					   withCompletion:^(NSImage *icon, NSError *error)
									 {
										 self.appIconImage.image = icon;
									 }];
	}];
}

- (IBAction) setIconState:(id)sender
{
	NSString *UDID = self.devicePopup.titleOfSelectedItem;
	iMDVLNDevice *device = [[iMDVLNDeviceManager sharedManager] deviceWithUDID:UDID];
	
	NSArray *iconState = [NSPropertyListSerialization propertyListWithData:[self.outputTextField.string dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions format:NULL error:NULL];
	
	[device setIconState:iconState withCompletion:^(BOOL result, NSError *error)
	{
		NSLog(@"setting icon state was %i - now reloading icon state", result);
		
		[self getIconState:nil];
	}];
}

@end
