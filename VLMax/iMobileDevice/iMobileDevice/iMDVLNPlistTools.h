//
//  iMDVLNPlistTools.h
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <plist/plist.h>

@interface iMDVLNPlistTools : NSObject

+ (NSString *) plistToString:(plist_t)plist;

+ (NSArray *) plistToArray:(plist_t)plist;

+ (plist_t) arrayToPlist:(NSArray *)array;

@end
