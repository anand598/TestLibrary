//
//  WishlistTemplate.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 3/19/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "WishlistTemplate.h"

@interface WishlistTemplate ()

@property (readwrite) NSString* start;
@property (readwrite) NSString* item;
@property (readwrite) NSString* end;
@property (readwrite) NSArray* items;

@end

@implementation WishlistTemplate

- (id)initWithFilePath:(NSString*)filepath andInfo:(NSDictionary*)info andItems:(NSArray*)items {
    self = [super init];
    if (self) {
        NSString* template = [[NSString alloc] initWithContentsOfFile:filepath
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
        NSArray* parts = [template componentsSeparatedByString:@"<!--- item --->"];
        assert([parts count] == 3);
        self.start = parts[0];
        self.item = parts[1];
        self.end = parts[2];
        
        [self addStartInfo:info];
        [self addEndInfo:info];
        [self addItemInfo:items];
    }
    return self;
}

- (NSString*)applyInfo:(NSDictionary*)info toTemplate:(NSString*)template {
    NSString* str = [NSString stringWithString:template];
    for (NSString* key in [info allKeys]) {
        NSString* identifier = [NSString stringWithFormat:@"{{%@}}",key];
        NSString* value = [info valueForKey:key];
        str = [str stringByReplacingOccurrencesOfString:identifier
                                             withString:value];
    }
    return str;
}

- (void)addStartInfo:(NSDictionary*)info {
    self.start = [self applyInfo:info toTemplate:self.start];
}

- (void)addEndInfo:(NSDictionary*)info {
    self.end = [self applyInfo:info toTemplate:self.end];
}

- (void)addItemInfo:(NSArray*)infos {
    self.items = @[];
    for (NSDictionary* info in infos) {
        self.items = [self.items arrayByAddingObject:[self applyInfo:info toTemplate:self.item]];
    }
}

- (NSString*)toString {
    return [NSString stringWithFormat:@"%@%@%@",
            self.start,
            [self.items componentsJoinedByString:@""],
            self.end];
}

@end
