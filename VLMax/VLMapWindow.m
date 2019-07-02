//
//  VLMapWindow.m
//  VLMax
//
//  Created by huhao on 2019/6/19.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "VLMapWindow.h"
#import <Masonry/Masonry.h>
@interface VLMapWindow () <WKUIDelegate, WKNavigationDelegate ,WKScriptMessageHandler>

@end

@implementation VLMapWindow


- (void)awakeFromNib {
    [self initData];
}


- (void)initData {
    

    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    {
        config.preferences = [WKPreferences new];
        config.preferences.minimumFontSize = 10;
        config.preferences.javaScriptEnabled = true;
        config.preferences.javaScriptCanOpenWindowsAutomatically = false;
        config.processPool = [WKProcessPool new];
        config.userContentController = [WKUserContentController new];
        
        [config.userContentController addScriptMessageHandler:self name:@"JSObject"];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    
    _webView = [[WKWebView alloc] initWithFrame:self.frame configuration:config];
    {
        [_webView loadRequest:[NSURLRequest requestWithURL:pathURL]];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.contentView addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }

}



- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"JSObject"]) {
        if ([self.mwDelegate respondsToSelector:@selector(webViewCallBack:)]) {
            [self.mwDelegate webViewCallBack:[NSString stringWithFormat:@"%@",message.body]];
        }
    }
}


- (void)close {
    [super close];
    self.isActive = NO;
}

- (void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    self.isActive = YES;
}


- (void)dealloc {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"JSObject"];
}

@end
