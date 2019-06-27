//
//  iMDVLNLockdowndClient.h
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNClient.h"

@interface iMDVLNLockdowndClient : iMDVLNClient <iMDVLNClientProtocol>

- (id) getAllPropertiesWithinDomain:(NSString *)domain;

- (id) getPropertyForKey:(NSString *)key;
- (id) getPropertyForKey:(NSString *)key domain:(NSString *)domain;

#pragma mark - Lockdownd Services

- (NSError *) connectToService:(const char *)serviceIdentifier;
- (BOOL) disconnectFromService;

- (NSError *)updateLocationWithLatitude:(NSString *)latitude longitude:(NSString *)longitude;
@end
