//
//  NSError+libimobiledevice.h
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "libimobiledevice.h"
#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/service.h>
#import <libimobiledevice/sbservices.h>
#import <libimobiledevice/screenshotr.h>

typedef enum
{
	iMDVLNDeviceSuccess = 0,
	iMDVLNDeviceNoImageDataReturned = 1,
	iMDVLNDeviceNoDataReturned = 2,
	iMDVLNDeviceUnableToConvertPlist = 3,
	iMDVLNDeviceUnableToStartService = 4,
	iMDVLNDeviceServiceAlreadyActive = 5
}
iMDVLNDeviceError;

@interface NSError (libmobiledeviceError)

+ (NSError *) errorWithLibraryError:(iMDVLNDeviceError)error;

+ (NSError *) errorWithDeviceErrorCode:(idevice_error_t)errorCode;

+ (NSError *) errorWithLockdownErrorCode:(lockdownd_error_t)errorCode;

+ (NSError *) errorWithSpringboardErrorCode:(sbservices_error_t)errorCode;

+ (NSError *) errorWithScreenshotErrorCode:(screenshotr_error_t)errorCode;

+ (NSError *)errorWithServiceErrorCode:(service_error_t)errorCode;

@end
