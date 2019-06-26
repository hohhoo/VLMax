//
//  NSColor+Hex.h
//  iMobileDevice
//
//	https://gist.github.com/acwright/2707798
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Hex)

- (NSString *) hexadecimalValue;
+ (NSColor *) colorFromHexadecimalValue:(NSString *)hex;

@end
