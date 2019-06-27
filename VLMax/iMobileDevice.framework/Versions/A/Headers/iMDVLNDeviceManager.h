//
//  iMDVLNDeviceManager.h
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iMDVLNDevice;

@interface iMDVLNDeviceManager : NSObject

+ (instancetype) sharedManager;

#pragma mark - Device notifications

@property (nonatomic, readonly, getter=isSubscribed) BOOL subscribed;

- (BOOL) subscribeForNotifications:(NSError **)error;

- (BOOL) unsubscribeForNotifications:(NSError **)error;

#pragma mark - Devices

- (NSArray *) devices;

- (id) deviceWithUDID:(NSString *)UDID;

@end
