//
//  VLKeyWindow.m
//  VLMax
//
//  Created by huhao on 2019/6/21.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "VLKeyWindow.h"

#import "CoordinateManager.h"
#import "AppDelegate.h"

#define kDistance 0.0005

typedef enum : int {
    ZYKeyTypeLeft = 123,
    ZYKeyTypeRight,
    ZYKeyTypeDown,
    ZYKeyTypeUp
} ZYKeyType;

@implementation VLKeyWindow

- (void)keyDown:(NSEvent *)theEvent{
    
    unsigned short  keycode = [theEvent keyCode];
    
    _location = self.locTF.stringValue;
    
    NSArray <NSString *> *strArr = [_location componentsSeparatedByString:@","];
    
    if (!_location || !_location.length) {
        return;
    }

    CGFloat lat = [strArr[0] doubleValue];
    CGFloat lon = [strArr[1] doubleValue];
    
    switch (keycode) {
        case ZYKeyTypeLeft :
        {
            lon -= kDistance;
        }
            break;
        case ZYKeyTypeRight :
        {
            lon += kDistance;
        }
            break;
        case ZYKeyTypeDown :
        {
            lat -= kDistance;
        }
            break;
        case ZYKeyTypeUp :
        {
            lat += kDistance;
        }
            break;
        default:
            break;
    }
    
    
    self.location = [NSString stringWithFormat:@"%@,%@",@(lat).stringValue,@(lon).stringValue];
    
    self.locTF.stringValue = _location;
    
    [[AppDelegate shareInstance].deviceWindow updateLocation:@(lat).stringValue longitude:@(lon).stringValue];
    
    
    
}



- (void)close {
    [super close];
    _isActive = NO;
}

- (void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    _isActive = YES;
}



@end
