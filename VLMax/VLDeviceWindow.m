//
//  VLDeviceWindow.m
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "VLDeviceWindow.h"
#import <iMobileDevice/iMobileDevice.h>
#import <iMobileDevice/iMDVLNClient.h>

#import "CoordinateManager.h"
#import "VLAlertView.h"

#define VLConsole(...) [self console:__VA_ARGS__]

@interface VLDeviceWindow () <VLMapWindowDelegate>

@end

@implementation VLDeviceWindow
{
    bool _isConnect;
}


- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceAdded:)
                                                 name:iMDVLNDeviceAddedNotification
                                               object:[iMDVLNDeviceManager sharedManager]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceRemoved:)
                                                 name:iMDVLNDeviceRemovedNotification
                                               object:[iMDVLNDeviceManager sharedManager]];
    
    self.textView.editable = NO;
    
    [self updateDevicePopup];
    
}

#pragma mark - Notifications

- (void) deviceAdded:(NSNotification *)notification
{
    [self updateDevicePopup];
}

- (void) deviceRemoved:(NSNotification *)notification
{
    [self updateDevicePopup];
}

#pragma mark - Device popup

- (void) updateDevicePopup
{
    NSArray *devices = [iMDVLNDeviceManager sharedManager].devices;
    
    for (iMDVLNDevice *device in devices)
    {
        VLConsole(@"Device uuid :%@",device.UDID);
    }
}

- (IBAction)buttonClick:(id)sender {
    
    NSArray <NSString *> *strArr = [self.locTF.stringValue componentsSeparatedByString:@","];

    if (strArr.count < 2) {
        VLConsole(@"❌ Enter error, Rule is (latitude, longitude)");
        return;
    }
    
    
    NSString *lat = strArr[0];
    NSString *lon = strArr[1];
    
    double validity = lat.doubleValue;
    if (!validity) {
        VLConsole(@"❌ Enter error, An invalid argument was used");
        return;
    }
    
    validity = lon.doubleValue;
    if (!validity) {
        VLConsole(@"❌ Enter error, An invalid argument was used");
        return;
    }
    
    
//    NSArray <NSNumber *> *locArray = [CoordinateManager GCJ02ToWGS84With:lon.doubleValue and:lat.doubleValue];
//
//    [self updateLocation:locArray[1].stringValue longitude:locArray[0].stringValue];
    [self updateLocation:lat longitude:lon];
}


- (void)updateLocation:(NSString *)latitude longitude:(NSString *)longitude {

    if (self.textView.string.length > 500) {
        self.textView.string = @"";
    }
    
    
    NSArray *deviceList = [iMDVLNDeviceManager sharedManager].devices;
    
    if (!deviceList.count) {
        VLConsole(@"❌ Can't find device");
        return;
    }
    
    VLConsole(@"😯 Update Location : %@,%@",latitude,longitude);
    
    // For Each devices
    for (iMDVLNDevice *device in deviceList)
    {
        NSError *error = [device updateLocation:latitude longitude:longitude];
        if (!error) {
            VLConsole(@"✅ Update Location success ");
        } else {
            
            NSString *errorDesc = error.userInfo[@"NSLocalizedDescription"];
            
            if (errorDesc)
                VLConsole([NSString stringWithFormat:@"❌ Update Location failed, Error description :%@",errorDesc]);
            else
                VLConsole(@"❌ Update Location failed ,Error description unknown ");

        }
    }
    
    
    
}

- (IBAction)openMapWindows:(id)sender {

    VLMapWindow *w = (VLMapWindow *)[AppDelegate shareInstance].mapWindow;
    if (w.isActive) [w close];
    else [w makeKeyAndOrderFront:nil];
    
}


- (IBAction)gotoKeyWindow:(id)sender {
    
    VLKeyWindow *w = (VLKeyWindow *)[AppDelegate shareInstance].keyWindow;
    if (w.isActive) [w close];
    else [w makeKeyAndOrderFront:nil];
    
}


#pragma mark - VLMapWindow delegate
- (void)webViewCallBack:(NSString *)message {
    
    NSArray <NSString *> *strArr = [message componentsSeparatedByString:@","];

    NSString *lat = strArr[0];
    NSString *lon = strArr[1];
    
    NSArray <NSNumber *> *locArray = [CoordinateManager GCJ02ToWGS84With:lon.doubleValue and:lat.doubleValue];
    
    self.locTF.stringValue = [NSString stringWithFormat:@"%@,%@",lat,lon];

    
    
    
    [self updateLocation:locArray[1].stringValue longitude:locArray[0].stringValue];
    
}


- (void)console:(NSString *)logString, ... {

    va_list args;
    va_start(args, logString);
    logString = [[NSString alloc] initWithFormat:logString arguments:args];
    va_end(args);

    self.textView.string = [NSString stringWithFormat:@"%@\n%@",self.textView.string,logString];
    self.textView.layoutManager.allowsNonContiguousLayout = true;
    
}

- (void)close {
    exit(0);
}

@end
