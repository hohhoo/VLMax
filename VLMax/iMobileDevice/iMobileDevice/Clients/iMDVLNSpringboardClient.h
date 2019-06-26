//
//  iMDVLNSpringboardClient.h
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNClient.h"

@interface iMDVLNSpringboardClient : iMDVLNClient <iMDVLNClientProtocol>

- (NSImage *) getWallpaper:(NSError **)error;

- (NSArray *) getIconState:(NSError **)error;
- (NSError *) setIconState:(NSArray *)iconState;

- (NSImage *) getIconImageForBundleId:(NSString *)bundleId error:(NSError **)error;

@end
