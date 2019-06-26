//
//  CoordinateManager.m
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "CoordinateManager.h"

@implementation CoordinateManager

static long double a = 6378245.0;
static long double ee = 0.00669342162296594323;
static long double interval = 0.000001;


static bool outOfChina(long double lat, long double lon)
{
    
    if ((lon < 72.004 || lon > 137.8347) || (lat < 0.8293 || lat > 55.8271))
    {
        return true;
    }
    else
    {
        return false;
    }
    
}
static long double transformLat(double x, double y)
{
    
    long double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    
    return ret;
    
}
static long double transformLon(long double x, long double y)
{
    
    long double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(abs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0* M_PI)) * 2.0 / 3.0;
    
    return ret;
}






static long double* BD09ToGCJ02(long double bd_lat, long double bd_lon)
{
    
    static long double newArray[] = {0,0};
    
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * (M_PI *3000.0 / 180.0));
    double theta = atan2(y, x) - 0.000003 * cos(x * (M_PI *3000.0 / 180.0));
    double gg_lon = z * cos(theta);
    double gg_lat = z * sin(theta);
    
    newArray[0] = gg_lon;
    newArray[1] = gg_lat;
    
    return  newArray;
    
}

static long double* BD09ToWGS84(long double bd_lat, long double bd_lon)
{
    
    long double* gcj = BD09ToGCJ02(bd_lon, bd_lat);
    return GCJ02ToWGS84(gcj[0], gcj[1]);
    
    
}
static long double* GCJ02ToWGS84(long double clon, long double clat)
{
    
    static long double newArray[] = {0,0};
    
    long double wlat, wlon;
    
    long double *wgs = WGS84ToGCJ02(clon, clat); // 输入坐标转换为Mars坐标
    // 计算坐标差值
    long double dlat = wgs[1] - clat;
    long double dlon = wgs[0] - clon;
    
    // 带入差值，模拟wgs坐标
    wlat = clat + dlat;
    wlon = clon + dlon;
    
    // 将计算出来的wgs坐标转换为Mars坐标，并与输入坐标校验精度
    long double *mars = WGS84ToGCJ02(wlon, wlat);
    
    dlat = mars[1] - clat;
    dlon = mars[0] - clon;
    long double dis = sqrt(dlat * dlat + dlon * dlon);
    
    while (dis > interval) {
        dlat = dlat / 2;
        dlon = dlon / 2;
        wlat = wlat - dlat;
        wlon = wlon - dlon;
        mars = WGS84ToGCJ02(wlon, wlat);
        long double _lat = mars[1] - clat;
        long double _lon = mars[0] - clon;
        dis = sqrt(_lat * _lat + _lon * _lon);
        dlat = abs(dlat) > abs(_lat) ? dlat : _lat;
        dlon = abs(dlon) > abs(_lon) ? dlon : _lon;
    }
    
    newArray[0] = wlon;
    newArray[1] = wlat;
    
    return newArray;
    
}
static long double* GCJ02ToBD09(long double gg_lat, long double gg_lon)
{
    
    static long double newArray[] = {0,0};
    
    long double x = gg_lon, y = gg_lat;
    long double z = sqrt(x * x + y * y) + 0.00002 * sin(y * (M_PI *3000.0 / 180.0));
    long double theta = atan2(y, x) + 0.000003 * cos(x * (M_PI *3000.0 / 180.0));
    
    long double bd_lon = z * cos(theta) + 0.0065;
    long double bd_lat = z * sin(theta) + 0.006;
    
    
    newArray[0] = bd_lon;
    newArray[1] = bd_lat;
    
    return newArray;
    
}
static long double* WGS84ToBD09(long double wgs_lat, long double wgs_lon)
{
    
    long double *gcj = WGS84ToGCJ02(wgs_lat, wgs_lon);
    
    return GCJ02ToBD09(gcj[1], gcj[0]);
    
}

static long double* WGS84ToGCJ02(long double wgLon, long double wgLat)
{
    
    static long double newArray[] = {0,0};
    
    
    long double mgLat = 0;
    long double mgLon = 0;
    if (outOfChina(wgLat, wgLon))
    {
        mgLat = wgLat;
        mgLon = wgLon;
        static long double new[] = {0,0};
        new[0] = wgLon;
        new[1] = wgLat;
        
        return new;
        
    }
    long double dLat = transformLat((wgLon - 105.0), (wgLat - 35.0));
    long double dLon = transformLon((wgLon - 105.0),(wgLat - 35.0));
    long double radLat = wgLat / 180.0 * M_PI;
    long double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    long double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    mgLat = wgLat + dLat;
    mgLon = wgLon + dLon;
    
    
    newArray[0] = mgLon;
    newArray[1] = mgLat;
    
    return newArray;
}









+ (NSArray *)BD09ToGCJ02With:(double)bd_lat and:(double)bd_lon
{
    
    long double *arr = BD09ToGCJ02(bd_lat, bd_lon);
    //NSLog(@"BD09ToGCJ02:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
    
}
+ (NSArray *)BD09ToWGS84With:(long double)bd_lat and:(long double)bd_lon
{
    
    long double *arr = BD09ToWGS84(bd_lat, bd_lon);
    ////NSLog(@"BD09ToWGS84:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
}

+ (NSArray *)GCJ02ToWGS84With:(double)clon and:(double)clat
{
    
    long double *arr = GCJ02ToWGS84(clon, clat);
    //NSLog(@"GCJ02ToWGS84:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
}

+ (NSArray *)GCJ02ToBD09With:(double)gg_lat and:(double)gg_lon
{
    
    long double *arr = GCJ02ToBD09(gg_lat, gg_lon);
    //NSLog(@"GCJ02ToBD09:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
}

+ (NSArray *)WGS84ToBD09With:(double)wgs_lat and:(double)wgs_lon
{
    
    long double *arr = WGS84ToBD09(wgs_lat, wgs_lon);
    //NSLog(@"WGS84ToBD09:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
}
+ (NSArray *)WGS84ToGCJ02With:(double)wgLon and:(double)wgLat
{
    
    long double *arr = WGS84ToGCJ02(wgLon, wgLat);
    //NSLog(@"WGS84ToGCJ02:>>>>>>%.14Lf,%.14Lf",arr[0],arr[1]);
    return [NSArray arrayWithObjects:[NSDecimalNumber numberWithDouble:arr[0]],[NSDecimalNumber numberWithDouble:arr[1]], nil];
}

@end
