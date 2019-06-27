//
//  iMDVLNPlistTools.m
//  iMobileDevice
//
//  Created by Daniel Love on 01/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

#import "iMDVLNPlistTools.h"

@implementation iMDVLNPlistTools

+ (NSString *) plistToString:(plist_t)plist
{
	char *val_char = nil;
	uint32_t xml_length;
	plist_to_xml(plist, &val_char, &xml_length);
	
	if (val_char && xml_length > 0)
	{
		return [NSString stringWithUTF8String:val_char];
	}
	
	return nil;
}

+ (NSArray *) plistToArray:(plist_t)plist
{
	NSString *plistString = [self plistToString:plist];
	NSData *plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSError *error;
	NSPropertyListFormat format;
	NSArray *array = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
	
	if (!array) {
		NSLog(@"Error: %@", error);
	}
	
	return array;
}

+ (plist_t) arrayToPlist:(NSArray *)array
{
	NSError *error;
	plist_t plist = nil;
	NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
	
	NSString *plistString = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
	
	NSLog(@"%i", [NSPropertyListSerialization propertyList:plistString isValidForFormat:NSPropertyListXMLFormat_v1_0]);
	
	const char *val_char = [plistString UTF8String];
	uint32_t xml_length = (uint32_t)strlen(val_char) + sizeof(plistString);
	plist_from_xml(val_char, xml_length, &plist);
	
	NSLog(@"%@", [self plistToString:plist]);
	
	return plist;
}

@end
