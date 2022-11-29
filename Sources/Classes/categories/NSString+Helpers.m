//
//  NSString+Helpers.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 12/16/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)

- (NSString*)urlEncodedString {
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
    return (NSString*)CFBridgingRelease(urlString);
}

@end
