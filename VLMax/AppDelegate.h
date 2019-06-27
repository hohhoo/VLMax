//
//  AppDelegate.h
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VLMapWindow.h"
#import "VLDeviceWindow.h"
#import "VLKeyWindow.h"

@class VLDeviceWindow;
@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (weak) IBOutlet VLMapWindow *mapWindow;
@property (weak) IBOutlet VLKeyWindow *keyWindow;
@property (weak) IBOutlet VLDeviceWindow *deviceWindow;

+ (AppDelegate *)shareInstance;

@end

