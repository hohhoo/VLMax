//
//  iMDVLNClient.m
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNClient.h"
#import "iMDVLNPlistTools.h"
#import "iMDVLNDevice.h"
#import <libimobiledevice/libimobiledevice.h>

#import "NSError+libimobiledevice.h"


@interface iMDVLNClient ()


@property (nonatomic, assign) idevice_t idevice_t;

@property (nonatomic, strong) iMDVLNDevice *device;

@end

@implementation iMDVLNClient

- (id) initWithDevice:(iMDVLNDevice *)device
{
	if ((self = [super init]))
	{
		_device = device;
	}
	
	return self;
}

#pragma mark - Lifetime

- (BOOL) connect:(NSError **)error
{
	NSError *internalError = nil;
	if ([self isConnected] == NO)
	{
		idevice_error_t errCode = idevice_new(&_idevice_t, [self.device.UDID cStringUsingEncoding:NSUTF8StringEncoding]);
		if (errCode == LOCKDOWN_E_SUCCESS)
		{
			if ([self respondsToSelector:@selector(connectToClient:)])
			{
				BOOL result = [self connectToClient:&internalError];
				if (result) {
					return result;
				}
			}
		}
		else
		{
			internalError = [NSError errorWithDeviceErrorCode:errCode];
			NSLog(@"iMDVLNClient.connect: Unable to create new device %@", internalError);
		}
	}
	else
	{
		internalError = [NSError errorWithLockdownErrorCode:LOCKDOWN_E_PAIRING_FAILED];
		NSLog(@"iMDVLNClient.connect: Already connected to a client %@", internalError);
	}
	
    if (error) {
        *error = internalError;
    }
    
	return NO;
}

- (BOOL) disconnect:(NSError **)error
{
	if ([self respondsToSelector:@selector(disconnectFromClient:)]) {
		[self disconnectFromClient:error];
	}
	
	if (_device != nil)
	{
		idevice_free(_idevice_t);
		_idevice_t = nil;
	}
	
	return YES;
}

#pragma mark - iMDVLNClientProtocol

- (BOOL) connectToClient:(NSError **)error
{
	NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Clients need to over ride connectToClient.", nil),
								NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Implementation error", nil),
								NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Over ride connectToClient, to connect to a specific client, such as Lockdownd", nil)
							  };
	
	*error = [NSError errorWithDomain:@"net.daniellove.iMobileDevice.error"
								 code:-666
							 userInfo:userInfo];
	
	return NO;
}

- (BOOL) disconnectFromClient:(NSError **)error
{
	
	NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Clients need to over ride disconnectFromClient.", nil),
								NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Implementation error", nil),
								NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Over ride disconnectFromClient, to disconnect from a specific client, such as Lockdownd", nil)
							  };
	
	*error = [NSError errorWithDomain:@"net.daniellove.iMobileDevice.error"
								 code:-666
							 userInfo:userInfo];
	
	return NO;
}

- (BOOL) isConnected
{
	NSDictionary *userInfo = @{
								NSLocalizedDescriptionKey: NSLocalizedString(@"Clients need to over ride isConnected.", nil),
								NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Implementation error", nil),
								NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Over ride isConnected", nil)
							  };
	
	NSError * error = [NSError errorWithDomain:@"net.daniellove.iMobileDevice.error"
										  code:-666
									  userInfo:userInfo];
	
	NSLog(@"%@", error);
	
	return NO;
}

@end
