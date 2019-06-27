//
//  AppDelegate.m
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "AppDelegate.h"
#import <iMobileDevice/iMobileDevice.h>

#define iMDMSM [iMDVLNDeviceManager sharedManager]

@interface AppDelegate ()

//@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
//    [self.mapWindow close];
    {
//        [[self.mapWindow standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        [[_mapWindow standardWindowButton:NSWindowZoomButton] setHidden:YES];
        
        _mapWindow.titleVisibility = NSWindowTitleHidden;
        _mapWindow.isActive = YES;
        _mapWindow.mwDelegate = self.deviceWindow;
        
        [[_keyWindow standardWindowButton:NSWindowZoomButton] setHidden:YES];
        [[_keyWindow standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        _keyWindow.isActive = YES;
        
        _keyWindow.locTF = _deviceWindow.locTF;
    }
    
    
    
    
    NSError *error = nil;
    [iMDMSM subscribeForNotifications:&error];
    
    if (error) {
        NSLog(@"AppDelegate.applicationDidFinishLaunching error subscribing to notifications %@", error);
    }

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSError *error = nil;
    [[iMDVLNDeviceManager sharedManager] unsubscribeForNotifications:&error];
    
    if (error) {
        NSLog(@"AppDelegate.applicationWillTerminate error unsubscribing from notifications %@", error);
    }
}

+ (AppDelegate *)shareInstance {
    return (AppDelegate *)[[NSApplication sharedApplication] delegate];
}



@end
