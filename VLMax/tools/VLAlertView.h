//
//  VLAlertView.h
//  VLMax
//
//  Created by huhao on 2019/6/19.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface VLAlertView : NSObject

+ (void)alertSheetFirstBtnTitle:(NSString *)firstname
                 SecondBtnTitle:(NSString *)secondname
                    MessageText:(NSString *)messagetext
                InformativeText:(NSString *)informativetext
                         window:(NSWindow *)window
              completionHandler:(void (^)(NSModalResponse response))handler;

+ (void)alertSheetWithMessageText:(NSString *)messageText
                  InformativeText:(NSString *)inforMativeText
                           window:(NSWindow *)window
                completionHandler:(void (^)(NSModalResponse response))handler ;
@end

NS_ASSUME_NONNULL_END
