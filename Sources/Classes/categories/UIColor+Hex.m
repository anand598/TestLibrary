//
//  UIColor+Hex.m
//  Nordstrom
//
//  Created by Schell Scivally on 3/30/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

- (NSString*)asHexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
//    CGFloat r,g,b,a;
//    [self getRed:&r green:&g blue:&b alpha:&a];
//    char str[16];
//sprintf(str, "%02x%02x%02x", (int)round(r),(int)round(g),(int)round(b));
//    NSString* ocstr = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
//    
//    return [@"#" stringByAppendingString:[ocstr stringByReplacingOccurrencesOfString:@"0x" withString:@""]];
}

@end
