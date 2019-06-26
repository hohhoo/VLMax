//
//  NSError+libimobiledevice.m
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "NSError+libimobiledevice.h"
#import "iMDVLNConstants.h"


@implementation NSError (libmobiledeviceError)

+ (NSError *)errorWithDeviceErrorCode:(idevice_error_t)errorCode
{
	if (errorCode == IDEVICE_E_SUCCESS) {
		return nil;
	}
	
	NSDictionary *userInfo = nil;
	if (errorCode == IDEVICE_E_INVALID_ARG) {
		userInfo = @{NSLocalizedDescriptionKey: @"An invalid argument was used"};
	}
	else if (errorCode == IDEVICE_E_UNKNOWN_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"An unknown error occurred"};
	}
	else if (errorCode == IDEVICE_E_NO_DEVICE) {
		userInfo = @{NSLocalizedDescriptionKey: @"No device connected"};
	}
	else if (errorCode == IDEVICE_E_NOT_ENOUGH_DATA) {
		userInfo = @{NSLocalizedDescriptionKey: @"Not enough data"};
	}
	else if (errorCode == IDEVICE_E_BAD_HEADER) {
		userInfo = @{NSLocalizedDescriptionKey: @"Bad header received"};
	}
	else if (errorCode == IDEVICE_E_SSL_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"An SSL error occurred"};
	}
	
	return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)errorWithLockdownErrorCode:(lockdownd_error_t)errorCode
{
	if (errorCode == LOCKDOWN_E_SUCCESS) {
		return nil;
	}
	
	NSDictionary *userInfo = nil;
    if (errorCode == LOCKDOWN_E_INVALID_ARG) {
        userInfo = @{NSLocalizedDescriptionKey: @"invalid arg"};
    } else if (errorCode == LOCKDOWN_E_INVALID_CONF) {
		userInfo = @{NSLocalizedDescriptionKey: @"Configuration data is wrong"};
	}
	else if (errorCode == LOCKDOWN_E_PLIST_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"PList read/write incorrectly formatted"};
	}
	else if (errorCode == LOCKDOWN_E_PAIRING_FAILED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unable to pair"};
	}
	else if (errorCode == LOCKDOWN_E_SSL_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"An SSL error occured"};
	}
	else if (errorCode == LOCKDOWN_E_DICT_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"Dict read/write incorrectly formatted"};
	}
	else if (errorCode == LOCKDOWN_E_START_SERVICE_FAILED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Lockdownd service failed to start"};
	}
	else if (errorCode == LOCKDOWN_E_NOT_ENOUGH_DATA) {
		userInfo = @{NSLocalizedDescriptionKey: @"Not enough data"};
	}
	else if (errorCode == LOCKDOWN_E_SET_VALUE_PROHIBITED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unable to set value, prohibited"};
	}
	else if (errorCode == LOCKDOWN_E_GET_VALUE_PROHIBITED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unable to get value, prohibited"};
	}
	else if (errorCode == LOCKDOWN_E_REMOVE_VALUE_PROHIBITED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unable to remove value, prohibited"};
	}
	else if (errorCode == LOCKDOWN_E_MUX_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"MUX error occured"};
	}
	else if (errorCode == LOCKDOWN_E_ACTIVATION_FAILED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Activation error occured"};
	}
	else if (errorCode == LOCKDOWN_E_PASSWORD_PROTECTED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Password protected"};
	}
	else if (errorCode == LOCKDOWN_E_NO_RUNNING_SESSION) {
		userInfo = @{NSLocalizedDescriptionKey: @"No running lockdownd session"};
	}
	else if (errorCode == LOCKDOWN_E_INVALID_HOST_ID) {
		userInfo = @{NSLocalizedDescriptionKey: @"Invalid host ID"};
	}
	else if (errorCode == LOCKDOWN_E_INVALID_SERVICE) {
		userInfo = @{NSLocalizedDescriptionKey: @"Invalid service"};
	}
	else if (errorCode == LOCKDOWN_E_INVALID_ACTIVATION_RECORD) {
		userInfo = @{NSLocalizedDescriptionKey: @"Invalid activation record"};
	}
	else if (errorCode == LOCKDOWN_E_PAIRING_DIALOG_PENDING) {
		userInfo = @{NSLocalizedDescriptionKey: @"Pairing dialog pending"};
	}
	else if (errorCode == LOCKDOWN_E_USER_DENIED_PAIRING) {
		userInfo = @{NSLocalizedDescriptionKey: @"User denied pairing"};
	}
	else if (errorCode == LOCKDOWN_E_UNKNOWN_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"An unknown error occured"};
	}
	return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)errorWithServiceErrorCode:(service_error_t)errorCode
{
    if (errorCode == SERVICE_E_SUCCESS) {
        return nil;
    }
    
//#define SERVICE_E_SUCCESS                0
//#define SERVICE_E_INVALID_ARG           -1
//#define SERVICE_E_MUX_ERROR             -3
//#define SERVICE_E_SSL_ERROR             -4
//#define SERVICE_E_START_SERVICE_ERROR   -5
//#define SERVICE_E_UNKNOWN_ERROR       -256
    
    NSDictionary *userInfo = nil;
    if (errorCode != SERVICE_E_SUCCESS) {
        userInfo = @{NSLocalizedDescriptionKey: @"Service Client Create failed"};
    }
    
    return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *) errorWithSpringboardErrorCode:(sbservices_error_t)errorCode
{
	if (errorCode == SBSERVICES_E_SUCCESS) {
		return nil;
	}
	
	NSDictionary *userInfo = nil;
	if (errorCode == SBSERVICES_E_INVALID_ARG) {
		userInfo = @{NSLocalizedDescriptionKey: @"An invalid argument was used"};
	}
	else if (errorCode == SBSERVICES_E_PLIST_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"SBServices plist error"};
	}
	else if (errorCode == SBSERVICES_E_CONN_FAILED) {
		userInfo = @{NSLocalizedDescriptionKey: @"Connection to SBServices failed"};
	}
	else if (errorCode == SBSERVICES_E_UNKNOWN_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unknown error"};
	}
	return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *) errorWithScreenshotErrorCode:(screenshotr_error_t)errorCode
{
	if (errorCode == SCREENSHOTR_E_SUCCESS) {
		return nil;
	}
	
	NSDictionary *userInfo = nil;
	if (errorCode == SCREENSHOTR_E_INVALID_ARG) {
		userInfo = @{NSLocalizedDescriptionKey: @"An invalid argument was used"};
	}
	else if (errorCode == SCREENSHOTR_E_PLIST_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"Screenshotr plist error"};
	}
	else if (errorCode == SCREENSHOTR_E_MUX_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"Screenshotr MUX error"};
	}
	else if (errorCode == SCREENSHOTR_E_BAD_VERSION) {
		userInfo = @{NSLocalizedDescriptionKey: @"Screenshotr bad version error"};
	}
	else if (errorCode == SCREENSHOTR_E_UNKNOWN_ERROR) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unknown screenshotr error"};
	}
	return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *) errorWithLibraryError:(iMDVLNDeviceError)error
{
	if (error == iMDVLNDeviceSuccess) {
		return nil;
	}
	
	NSDictionary *userInfo = nil;
	if (error == iMDVLNDeviceNoImageDataReturned) {
		userInfo = @{NSLocalizedDescriptionKey: @"No image data was returned"};
	}
	else if (error == iMDVLNDeviceUnableToStartService) {
		userInfo = @{NSLocalizedDescriptionKey: @"Unable to start service"};
	}
	else if (error == iMDVLNDeviceServiceAlreadyActive) {
		userInfo = @{NSLocalizedDescriptionKey: @"Service already active, disconnect from the previous service first"};
	}
	else if (error == iMDVLNDeviceNoDataReturned) {
		userInfo = @{NSLocalizedDescriptionKey: @"No data was returned from the service"};
	}
	else if (error == iMDVLNDeviceUnableToConvertPlist) {
		userInfo = @{NSLocalizedDescriptionKey: @"Could not convert plist to native type, likely trying to convert a string to dictionary"};
	}
	return [NSError errorWithDomain:iMDVLNDeviceErrorDomain code:error userInfo:userInfo];}

@end
