//
//  SharalitySiteModel.m
//  SyndecaSDK
//
//  Created by Schell Scivally on 2/26/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "SharalitySiteModel.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation SharalitySiteModel

- (NSURL*)iconURLWithWidth:(NSUInteger)width andHeight:(NSUInteger)height {
    NSString* sizeString = [NSString stringWithFormat:@"%lux%lu",(unsigned long)width,(unsigned long)height];
    NSString* path = [self.iconPath stringByReplacingOccurrencesOfString:@"%s" withString:sizeString];
    return [NSURL URLWithString:path];
}

- (NSString*)ID {
    return [self key];
}

-(BOOL)isBookmarkable {
    return [[self.info valueForKey:@"bookmark"] boolValue];
}

-(BOOL)isEmbedable {
    return [[self.info valueForKey:@"embed"] boolValue];
}

-(NSString*)iconPath {
    return [self.info stringByKey:@"icon"];
}

-(NSString*)key {
    return [self.info stringByKey:@"key"];
}

-(NSString*)name {
    return [self.info stringByKey:@"name"];
}

@end
