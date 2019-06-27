//
//  iMDVLNClient.h
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iMDVLNClientProtocol.h"


@class iMDVLNDevice;

@interface iMDVLNClient : NSObject

@property (nonatomic, readonly) iMDVLNDevice *device;

- (id) initWithDevice:(iMDVLNDevice *)device;

- (BOOL) connect:(NSError **)error;
- (BOOL) disconnect:(NSError **)error;

- (BOOL) isConnected;
@end
