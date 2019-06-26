//
//  iMDVLNDevice.h
//  iMobileDevice
//
//  Created by Daniel Love on 14/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface iMDVLNDevice : NSObject

@property (nonatomic, readonly) NSString *UDID;

#pragma mark - Device

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *productType;
@property (nonatomic, readonly) NSColor *deviceColor;

#pragma mark - Screen

@property (nonatomic, readonly) CGFloat screenHeight;
@property (nonatomic, readonly) CGFloat screenWidth;
@property (nonatomic, readonly) CGFloat screenScaleFactor;

#pragma mark - Images

@property (nonatomic, readonly) NSImage *wallpaper;
@property (nonatomic, readonly) NSImage *screenshot;

#pragma mark - Springboard Homescreen

@property (nonatomic, readonly) CGFloat springboardIconGridColumns; // 4 - HomeScreenIconColumns
@property (nonatomic, readonly) CGFloat springboardIconGridRows; // 5 - HomeScreenIconRows
@property (nonatomic, readonly) CGFloat springboardIconMaxPages; // 15 - HomeScreenMaxPages

#pragma mark - Springboard Folder

@property (nonatomic, readonly) CGFloat springboardFolderGridColumns; // 3 - IconFolderColumns
@property (nonatomic, readonly) CGFloat springboardFolderGridRows; // 3 - IconFolderRows
@property (nonatomic, readonly) CGFloat springboardFolderMaxPages; // 15 - IconFolderMaxPages

#pragma mark - Springboard Dock

@property (nonatomic, readonly) CGFloat springboardDockIconMaxCount; // 4 - HomeScreenIconDockMaxCount

#pragma mark - Springboard Icons

@property (nonatomic, readonly) CGFloat springboardIconHeight; // 60 - HomeScreenIconHeight
@property (nonatomic, readonly) CGFloat springboardIconWidth; // 60 - HomeScreenIconWidth
@property (nonatomic, readonly) BOOL springboardVideosSupported; // true - HomeVideosSupported
@property (nonatomic, readonly) BOOL springboardNewsStandSupported; // true - HomeScreenNewsstand
@property (nonatomic, readonly) BOOL springboardWillSaveIconStateChanges; // true - IconStateSaves

- (instancetype) initWithUDID:(NSString *)UDID;

#pragma mark - Properties

- (void) loadBasicDevicePropertiesWithCompletion:(void (^)())completionHandler;
- (void) loadProperty:(NSString *)key domain:(NSString *)domain completion:(void (^)(id property, NSError *error))completionHandler;

#pragma mark - Images

- (void) getWallpaperWithCompletion:(void (^)(NSImage *wallpaper, NSError *error))completionHandler;
- (void) getScreenshotWithCompletion:(void (^)(NSImage *screenshot, NSError *error))completionHandler;
- (void) getAppIconForBundleId:(NSString *)bundleId withCompletion:(void (^)(NSImage *icon, NSError *error))completionHandler;

#pragma mark - Springboard

- (void) getIconStateWithCompletion:(void (^)(NSArray *iconState, NSError *error))completionHandler;
- (void) setIconState:(NSArray *)iconState withCompletion:(void (^)(BOOL result, NSError *error))completionHandler;

#pragma mark - Springboard Icon Properties

- (void) loadSpringboardDisplayPropertiesWithCompletion:(void (^)())completionHandler;

@end
