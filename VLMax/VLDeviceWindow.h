//
//  VLDeviceWindow.h
//  VLMax
//
//  Created by huhao on 2019/6/18.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VLMapWindow.h"
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface VLDeviceWindow : NSWindow <VLMapWindowDelegate>
@property (weak) IBOutlet NSTextField *locTF;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (void)updateLocation:(NSString *)latitude longitude:(NSString *)longitude;

- (void)console:(NSString *)logString, ...;
@end

NS_ASSUME_NONNULL_END
