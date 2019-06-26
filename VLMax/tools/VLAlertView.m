//
//  VLAlertView.m
//  VLMax
//
//  Created by huhao on 2019/6/19.
//  Copyright © 2019 soulsee. All rights reserved.
//

#import "VLAlertView.h"

@implementation VLAlertView
+ (void)alertSheetFirstBtnTitle:(NSString *)firstname SecondBtnTitle:(NSString *)secondname MessageText:(NSString *)messagetext InformativeText:(NSString *)informativetext window:(NSWindow *)window completionHandler:(void (^)(NSModalResponse))handler {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:firstname];
    
    [alert addButtonWithTitle:secondname];
    
    //    [alert addButtonWithTitle:@"chenglibin1"];//可以添加三个按钮
    
    [alert setMessageText:messagetext];
    
    [alert setInformativeText:informativetext];
    
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:window completionHandler:handler];
}

+ (void)alertSheetWithMessageText:(NSString *)messageText InformativeText:(NSString *)inforMativeText window:(NSWindow *)window completionHandler:(void (^)(NSModalResponse))handler {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"确定"];
    
    [alert setMessageText:messageText];
    
    [alert setInformativeText:inforMativeText];
    
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:window completionHandler:handler];
}


@end
