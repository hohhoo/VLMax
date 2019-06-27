//
//  iMDVLNScreenshotrClient.m
//  iMobileDevice
//
//  Created by Daniel Love on 29/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNScreenshotrClient.h"
#import <libimobiledevice/screenshotr.h>
#import "NSError+libimobiledevice.h"

@interface iMDVLNClient ()
@property (nonatomic, assign) idevice_t idevice_t;
@end

@interface iMDVLNLockdowndClient ()
@property (nonatomic, readonly) lockdownd_client_t lockdownd_t;
@property (nonatomic, readonly) lockdownd_service_descriptor_t lockdownd_service_t;
@end

@interface iMDVLNScreenshotrClient ()

@property (nonatomic, assign) screenshotr_client_t screenshotr_t;

@end

@implementation iMDVLNScreenshotrClient

#pragma mark - iMDVLNClientProtocol

- (BOOL) connectToClient:(NSError **)error
{
	NSError *internalError = nil;
	
	// We require lockdownd
	[super connectToClient:&internalError];
	
	if (!internalError)
	{
		internalError = [self connectToService:SCREENSHOTR_SERVICE_NAME];
		
		if (!internalError)
		{
			screenshotr_error_t shotrErrCode = screenshotr_client_new(self.idevice_t, self.lockdownd_service_t, &_screenshotr_t);
			if (shotrErrCode != SBSERVICES_E_SUCCESS)
			{
				internalError = [NSError errorWithScreenshotErrorCode:shotrErrCode];
				NSLog(@"iMDVLNScreenshotrClient.connectToClient: Unable to create new screenshotr client %@", internalError);
			}
			else
			{
				return YES;
			}
		}
	}
	
	*error = internalError;
	
	return NO;
}

- (BOOL) disconnectFromClient:(NSError **)error
{
	NSError *internalError = nil;
	[super disconnectFromClient:&internalError];
	*error = internalError;
	
	if (_screenshotr_t != nil)
	{
		screenshotr_client_free(_screenshotr_t);
		_screenshotr_t = nil;
	}
	
	return YES;
}

- (BOOL) isConnected
{
	return (_screenshotr_t != nil);
}

#pragma mark - Methods

- (NSImage *) getScreenshot:(NSError **)error
{
	NSImage *image = nil;
	
	char *pngdata;
	uint64_t pngsize;
	
	screenshotr_error_t shotrErrCode = screenshotr_take_screenshot(_screenshotr_t, &pngdata, &pngsize);
	if (shotrErrCode == SBSERVICES_E_SUCCESS)
	{
		if (pngdata)
		{
			NSData *data = [[NSData alloc] initWithBytesNoCopy:pngdata length:pngsize];
			image = [[NSImage alloc] initWithData:data];
		}
		else
		{
			*error = [NSError errorWithLibraryError:iMDVLNDeviceNoImageDataReturned];
		}
	}
	else
	{
		*error = [NSError errorWithScreenshotErrorCode:shotrErrCode];
	}
	
	return image;
}

@end
