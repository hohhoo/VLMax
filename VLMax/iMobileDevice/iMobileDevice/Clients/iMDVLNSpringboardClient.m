//
//  iMDVLNSpringboardClient.m
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNSpringboardClient.h"
#import "iMDVLNPlistTools.h"
#import <libimobiledevice/sbservices.h>


#import "NSError+libimobiledevice.h"

@interface iMDVLNClient ()
@property (nonatomic, assign) idevice_t idevice_t;
@end

//@interface iMDVLNLockdowndClient ()
//@property (nonatomic, readonly) lockdownd_client_t lockdownd_t;
//@property (nonatomic, readonly) lockdownd_service_descriptor_t lockdownd_service_t;
//@end


@interface iMDVLNSpringboardClient ()

@property (nonatomic, assign) sbservices_client_t sbservice_t;

@end

@implementation iMDVLNSpringboardClient

#pragma mark - iMDVLNClientProtocol

- (BOOL) connectToClient:(NSError **)error
{
	NSError *internalError = nil;
	
	sbservices_error_t sbErrCode = sbservices_client_start_service(self.idevice_t, &_sbservice_t, "iMobileDevice");
	if (sbErrCode != SBSERVICES_E_SUCCESS)
	{
		internalError = [NSError errorWithSpringboardErrorCode:sbErrCode];
		NSLog(@"iMDVLNSpringboardClient.connectToClient: Unable to create new springboard client %@", internalError);
	}
	else
	{
		return YES;
	}
	
	*error = internalError;
	
	return NO;
}

- (BOOL) disconnectFromClient:(NSError **)error
{
	if (_sbservice_t != nil)
	{
		sbservices_client_free(_sbservice_t);
		_sbservice_t = nil;
	}
	
	return YES;
}

- (BOOL) isConnected
{
	return (_sbservice_t != nil);
}

#pragma mark - Methods

- (NSImage *) getWallpaper:(NSError **)error
{
	NSImage *image = nil;
	
	char *pngdata;
	uint64_t pngsize;
	
	sbservices_error_t sbErrCode = sbservices_get_home_screen_wallpaper_pngdata(_sbservice_t, &pngdata, &pngsize);
	if (sbErrCode == SBSERVICES_E_SUCCESS)
	{
		if (pngdata)
		{
			NSData *data = [[NSData alloc] initWithBytesNoCopy:pngdata length:pngsize];
			image = [[NSImage alloc] initWithData:data];
		}
		else
		{
			*error = [NSError errorWithLibraryError:iMDVLNDeviceNoImageDataReturned];
			NSLog(@"iMDVLNSpringboardClient.getWallpaper: Wallpaper data seems empty? %@", *error);
		}
	}
	else
	{
		*error = [NSError errorWithSpringboardErrorCode:sbErrCode];
		NSLog(@"iMDVLNSpringboardClient.getWallpaper: Unable to get wallpaper %@", *error);
	}
	
	return image;
}

- (NSArray *) getIconState:(NSError **)error
{
	plist_t icon_state;
	NSArray *iconArray = nil;
	
	sbservices_error_t sbErrCode = sbservices_get_icon_state(_sbservice_t, &icon_state, "2");
	if(sbErrCode == SBSERVICES_E_SUCCESS)
	{
		NSString *strPlist = [iMDVLNPlistTools plistToString:icon_state];
		if ([strPlist length] != 0)
		{
			iconArray = [iMDVLNPlistTools plistToArray:icon_state];
			if (iconArray == nil || [iconArray count] == 0)
			{
				*error = [NSError errorWithLibraryError:iMDVLNDeviceUnableToConvertPlist];
				NSLog(@"iMDVLNSpringboardClient.getIconState: Unable to convert icon state to native type %@", *error);
			}
		}
		else
		{
			*error = [NSError errorWithLibraryError:iMDVLNDeviceNoDataReturned];
			NSLog(@"iMDVLNSpringboardClient.getIconState: Unable to get icon state from device %@", *error);
		}
	}
	
	plist_free(icon_state);
	
	return iconArray;
}

- (NSError *) setIconState:(NSArray *)iconState
{
	NSError *error = nil;
	plist_t icon_state = [iMDVLNPlistTools arrayToPlist:iconState];
	
	NSLog(@"iMDVLNSpringboardClient.setIconState %@",  [iMDVLNPlistTools plistToString:icon_state]);
	
	sbservices_error_t sbErrCode = sbservices_set_icon_state(_sbservice_t, icon_state);
	if(sbErrCode != SBSERVICES_E_SUCCESS)
	{
		error = [NSError errorWithSpringboardErrorCode:sbErrCode];
		NSLog(@"iMDVLNSpringboardClient.setIconState: Unable to set icon state %@", error);
	}
	
	plist_free(icon_state);
	
	return error;
}

- (NSImage *) getIconImageForBundleId:(NSString *)bundleId error:(NSError **)error
{
	NSImage *image = nil;
	
	const char *bundle = [bundleId cStringUsingEncoding:NSUTF8StringEncoding];
	char *pngdata;
	uint64_t pngsize;
	
	sbservices_error_t sbErrCode = sbservices_get_icon_pngdata(_sbservice_t, bundle, &pngdata, &pngsize);
	if (sbErrCode == SBSERVICES_E_SUCCESS)
	{
		if (pngdata)
		{
			NSData *data = [[NSData alloc] initWithBytesNoCopy:pngdata length:pngsize];
			image = [[NSImage alloc] initWithData:data];
		}
		else
		{
			*error = [NSError errorWithLibraryError:iMDVLNDeviceNoImageDataReturned];
			NSLog(@"iMDVLNSpringboardClient.getIconImage: Icon image data for %@ seems empty? %@", bundleId, *error);
		}
	}
	else
	{
		*error = [NSError errorWithSpringboardErrorCode:sbErrCode];
		NSLog(@"iMDVLNSpringboardClient.getIconImage: Unable to get icon image for %@ error: %@", bundleId, *error);
	}
	
	return image;
}

/*
sbservices_error_t sbservices_get_icon_state(sbservices_client_t client, plist_t *state, const char *format_version);
sbservices_error_t sbservices_set_icon_state(sbservices_client_t client, plist_t newstate);
sbservices_error_t sbservices_get_icon_pngdata(sbservices_client_t client, const char *bundleId, char **pngdata, uint64_t *pngsize);
sbservices_error_t sbservices_get_interface_orientation(sbservices_client_t client, sbservices_interface_orientation_t* interface_orientation);
sbservices_error_t sbservices_get_home_screen_wallpaper_pngdata(sbservices_client_t client, char **pngdata, uint64_t *pngsize);
*/

@end
