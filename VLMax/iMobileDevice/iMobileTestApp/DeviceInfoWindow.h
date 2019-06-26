//
//  DeviceInfoWindow.h
//  iMobileDevice
//
//  Created by Daniel Love on 28/06/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

@import Cocoa;
@import iMobileDevice;

@interface DeviceInfoWindow : NSWindow <NSMenuDelegate>

@property (nonatomic, assign) IBOutlet NSPopUpButton *devicePopup;
@property (nonatomic, assign) IBOutlet NSTextField *deviceNameTextField;
@property (nonatomic, assign) IBOutlet NSTextField *deviceProductTypeTextField;

@property (nonatomic, assign) IBOutlet NSTextField *deviceColorTextField;
@property (nonatomic, assign) IBOutlet NSColorWell *deviceColorWell;

@property (nonatomic, assign) IBOutlet NSTextField *deviceWidthTextField;
@property (nonatomic, assign) IBOutlet NSTextField *deviceHeightTextField;
@property (nonatomic, assign) IBOutlet NSTextField *deviceWidthScaledTextField;
@property (nonatomic, assign) IBOutlet NSTextField *deviceHeightScaledTextField;

@property (nonatomic, assign) IBOutlet NSTextField *customKeyTextField;
@property (nonatomic, assign) IBOutlet NSTextField *customDomainTextField;
@property (nonatomic, assign) IBOutlet NSTextView *outputTextField;

@property (nonatomic, assign) IBOutlet NSImageView *wallpaperImageView;
@property (nonatomic, assign) IBOutlet NSImageView *screenshotImageView;

@property (nonatomic, assign) IBOutlet NSButton *reloadWallpaperButton;
@property (nonatomic, assign) IBOutlet NSButton *reloadScreenshotButton;

@property (nonatomic, assign) IBOutlet NSImageView *appIconImage;
@property (nonatomic, assign) IBOutlet NSTextField *appIconLabel;

- (IBAction) reloadWallpaper:(id)sender;
- (IBAction) reloadScreenshot:(id)sender;

- (IBAction) getProperty:(id)sender;

- (IBAction) getIconState:(id)sender;
- (IBAction) setIconState:(id)sender;

@end
