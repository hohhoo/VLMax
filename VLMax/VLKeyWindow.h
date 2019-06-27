//
//  VLKeyWindow.h
//  VLMax
//
//  Created by huhao on 2019/6/21.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLKeyWindow : NSWindow
@property (nonatomic, assign) bool isActive;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, weak) NSTextField *locTF;


@end

NS_ASSUME_NONNULL_END
