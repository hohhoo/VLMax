//
//  iMDVLNLockdowndClient.m
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNLockdowndClient.h"
#import "iMDVLNPlistTools.h"
#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/service.h>



#import "NSError+libimobiledevice.h"

@interface iMDVLNClient ()
@property (nonatomic, assign) idevice_t idevice_t;
@end


@interface iMDVLNLockdowndClient ()

@property (nonatomic, readonly) lockdownd_client_t lockdownd_t;
@property (nonatomic, readonly) lockdownd_service_descriptor_t lockdownd_service_t;

@property (nonatomic, readonly) service_client_t s_client_t;



@end

@implementation iMDVLNLockdowndClient

#pragma mark - iMDVLNClientProtocol

- (BOOL) connectToClient:(NSError **)error
{
	NSError *internalError = nil;
	
	lockdownd_error_t lockErrCode = lockdownd_client_new_with_handshake(self.idevice_t, &_lockdownd_t, "VLMax");
	if (lockErrCode != LOCKDOWN_E_SUCCESS)
	{
		internalError = [NSError errorWithLockdownErrorCode:lockErrCode];
		NSLog(@"iMDVLNLockdowndClient.connectToClient: Unable to create new lockdownd client with handshake %@", internalError);
	}
	else
	{
		return YES;
	}
	
    if (error) {
        *error = internalError;
    }
    
	return NO;
}

- (BOOL) disconnectFromClient:(NSError **)error
{
	[self disconnectFromService];
	
	if (_lockdownd_t != nil)
	{
		lockdownd_client_free(_lockdownd_t);
		_lockdownd_t = nil;
	}
    
    if (_s_client_t != nil) {
        service_client_free(_s_client_t);
        _s_client_t = nil;
    }
    
	return YES;
}

- (BOOL) isConnected
{
	return (_lockdownd_t != nil);
}

#pragma mark - Lockdownd Services

- (NSError *) connectToService:(const char *)serviceIdentifier
{
	NSError *internalError = nil;
	
//    if (self.isConnected && _s_client_t) {
//        return nil;
//    }
//
	// Already connected?
	if (_lockdownd_service_t != nil)
	{
		internalError = [NSError errorWithLibraryError:iMDVLNDeviceServiceAlreadyActive];
		return internalError;
	}
	
	lockdownd_error_t lockErrCode = lockdownd_start_service(_lockdownd_t, serviceIdentifier, &_lockdownd_service_t);
	if (lockErrCode != LOCKDOWN_E_SUCCESS)
	{
		internalError = [NSError errorWithLockdownErrorCode:lockErrCode];
		NSLog(@"iMDVLNLockdowndClient.connectToService: Unable to connect to service %s error: %@", serviceIdentifier, internalError);
        return internalError;
	}
	
	if (_lockdownd_service_t == nil || _lockdownd_service_t->port <= 0) {
		internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
        return internalError;
	}
//    service_error_t service_client_new(idevice_t device, lockdownd_service_descriptor_t service, service_client_t *client);
    service_error_t serviceError = service_client_new(self.idevice_t,_lockdownd_service_t,&_s_client_t);
    
    if (serviceError != SERVICE_E_SUCCESS) {
        internalError = [NSError errorWithServiceErrorCode:serviceError];
        NSLog(@"iMDVLNLockdowndClient.newServiceClient: Can't to perform this method with other error code %d",serviceError);
        return internalError;
    }
    
    if (_s_client_t == nil) {
        internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
        return internalError;
    }
    
    
	return internalError;
}

- (BOOL) disconnectFromService
{
	if (_lockdownd_service_t != nil)
	{
		lockdownd_service_descriptor_free(_lockdownd_service_t);
		_lockdownd_service_t = nil;
	}
	
	return YES;
}

- (NSError *)updateLocationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    
    
    
    const char * cLatitude = [latitude UTF8String];
    const char * cLongitude = [longitude UTF8String];
    
    
    NSError *internalError;
    
    if (_lockdownd_service_t == nil || _lockdownd_service_t->port <= 0
        ||_s_client_t == nil) {
        internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
    }
    
    
    uint32_t sent = 0;
    uint32_t startMessage = htonl(0);

    // start
    service_error_t e = service_send(_s_client_t, (void*)&startMessage, sizeof(startMessage), &sent);
    if (e != SERVICE_E_SUCCESS) {
        internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
        NSLog(@"Could not send data to Service Client.\n");
        return internalError;
    }
    
    // lat
    if (write_string(_s_client_t, cLatitude, &sent)) {
        internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
        NSLog(@"Error writing to the location service.\n");
    }
    
    //lon
    if (write_string(_s_client_t, cLongitude, &sent)) {
        internalError = [NSError errorWithLibraryError:iMDVLNDeviceUnableToStartService];
        NSLog(@"Error writing to the location service.\n");
    }
    
    
    
    return internalError;
}

static int write_string(service_client_t ref, const char* str, uint32_t *sent) {
    
    int length = (int)strlen(str);
    mach_error_t err = 0;
    int swapped_length = htonl(length);
    
    int result = service_send(ref, &swapped_length, 4, sent);
    
    result = service_send(ref, str, length, sent);
    
    return err;
}

#pragma mark - Methods

- (id) getAllPropertiesWithinDomain:(NSString *)domain
{
	return [self getPropertyForKey:nil domain:domain];
}

- (id) getPropertyForKey:(NSString *)key
{
	return [self getPropertyForKey:key domain:nil];
}

- (id) getPropertyForKey:(NSString *)key domain:(NSString *)domain
{
	return [self getLockdowndClientKey:key inDomain:domain];
}

- (id) getLockdowndClientKey:(NSString *)key inDomain:(NSString *)domain
{
	plist_t value_node = nil;
	
	const char *keyChar = [key cStringUsingEncoding:NSUTF8StringEncoding];
	const char *domainChar = [domain cStringUsingEncoding:NSUTF8StringEncoding];
	
	@try
	{
		lockdownd_get_value(_lockdownd_t, domainChar, keyChar, &value_node);
	}
	@catch (NSException *exception)
	{
		NSLog(@"iMDVLNLockdowndClient.getLockdowndClientKey: unable to value for key[%@] in domain[%@] - exception: %@", key, domain, exception);
		return nil;
	}
	
	char *val_char = nil;
	uint64_t val_int = 0;
	double val_double = 0;
	
	id returnResult = nil;
	
	if (value_node)
	{
		// If it has a key, then we aren't expecting a plist back, just a value
		if (key)
		{
			// So far I've only found 3 types to be used
			switch (plist_get_node_type(value_node))
			{
				case PLIST_UINT:
					plist_get_uint_val(value_node, &val_int);
					returnResult = [NSNumber numberWithUnsignedLongLong:val_int];
					break;
					
				case PLIST_REAL:
					plist_get_real_val(value_node, &val_double);
					returnResult = [NSNumber numberWithDouble:val_double];
					break;
					
				case PLIST_STRING:
					plist_get_string_val(value_node, &val_char);
					returnResult = [NSString stringWithUTF8String:val_char];
					break;
					
				case PLIST_BOOLEAN:
					NSLog(@"PLIST_BOOLEAN type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_ARRAY:
					NSLog(@"PLIST_ARRAY type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_DICT:
					NSLog(@"PLIST_DICT type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_DATE:
					NSLog(@"PLIST_DATE type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_DATA:
					NSLog(@"PLIST_DATA type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_KEY:
					NSLog(@"PLIST_KEY type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_UID:
					NSLog(@"PLIST_UID type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
				case PLIST_NONE:
					NSLog(@"PLIST_NONE type"); NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
					
				default:
					NSLog(@"Plist type not currently handled nor in the switch?");
					NSAssert(@"Node type not currently handled", @"Ensure node type is handled");
					break;
			}
		}
		// No key, expecting a plist
		else
		{
			returnResult = [iMDVLNPlistTools plistToString:value_node];
		}
	}
	
	plist_free(value_node);
	
	return returnResult;
}

@end
