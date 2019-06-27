//
//  VLMapWindow.h
//  VLMax
//
//  Created by huhao on 2019/6/19.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol VLMapWindowDelegate <NSObject>

- (void)webViewCallBack:(NSString *)message;

@end


@interface VLMapWindow : NSWindow 
@property (nonatomic, assign) bool isActive;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, weak) id <VLMapWindowDelegate> mwDelegate;

@end

NS_ASSUME_NONNULL_END
