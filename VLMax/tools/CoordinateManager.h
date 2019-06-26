//
//  CoordinateManager.h
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoordinateManager : NSObject
+ (NSArray *)BD09ToGCJ02With:(double)bd_lat and:(double)bd_lon;
+ (NSArray *)BD09ToWGS84With:(long double)bd_lat and:(long double)bd_lon;
+ (NSArray *)GCJ02ToWGS84With:(double)clon and:(double)clat;
+ (NSArray *)GCJ02ToBD09With:(double)gg_lat and:(double)gg_lon;
+ (NSArray *)WGS84ToBD09With:(double)wgs_lat and:(double)wgs_lon;
+ (NSArray *)WGS84ToGCJ02With:(double)wgLon and:(double)wgLat;

@end

NS_ASSUME_NONNULL_END
