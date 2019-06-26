//
//  iMDVLNScreenshotrClient.m
//  iMobileDevice
//
//  Created by Daniel Love on 29/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNLockdowndClient.h"

@interface iMDVLNScreenshotrClient : iMDVLNLockdowndClient

- (NSImage *) getScreenshot:(NSError **)error;

@end
