//
//  NSDictionary+AsObjectOrNil.m
//  CocoaViewer
//
//  Created by Schell Scivally on 8/8/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "NSDictionary+AsObjectOrNil.h"

@implementation NSDictionary (AsObjectOrNil)

- (BOOL)hasKey:(NSString *)key {
    return [[self allKeys] indexOfObject:key] != NSNotFound;
}

- (id)valueByPath:(id)key, ... {
    if (key == nil) {
        return nil;
    }
    id (^next)(id, id) = ^id (id k, id map) {
        if (k == nil || map == nil) {
            return nil;
        }
        
        if ([k isKindOfClass:[NSString class]] && [map isKindOfClass:[NSDictionary class]]) {
            return [map valueForKeyPath:k];
        }
        
        if ([k isKindOfClass:[NSNumber class]] && [map isKindOfClass:[NSArray class]] && [map count] > 0) {
            return [map objectAtIndex:[k integerValue]];
        }
        return nil;
    };
    
    va_list args;
    va_start(args, key);
    id item = next(key, self);
    while ((key = va_arg(args, id))) {
        item = next(key, item);
        if (item == nil) {
            return nil;
        }
    }
    
    return item;
}

- (NSString*)stringByKey:(NSString *)key {
    NSString* string = nil;
    
    id obj = [self valueForKey:key];
    if ([obj respondsToSelector:@selector(stringValue)]) {
        string = [obj stringValue];
    } else if ([obj respondsToSelector:@selector(isEqualToString:)]) {
        // Value is a string.
        string = (NSString*)obj;
    }
    
    if (string && [string respondsToSelector:@selector(isEqualToString:)] && ![string isEqualToString:@"(null)"]) {
        return string;
    }
    
    return nil;
}

- (NSArray*)arrayByKey:(NSString*)key {
    NSArray* array = [self valueForKey:key];
    if (array && [array respondsToSelector:@selector(indexOfObject:)]) {
        return array;
    }
    return nil;
}

- (NSDictionary*)infoByKey:(NSString *)key {
    NSDictionary* info = [self valueForKey:key];
    if (info && [info respondsToSelector:@selector(valueForKey:)] && ![info isEqual:[NSNull null]]) {
        return info;
    }
    return nil;
}

- (NSUInteger)uintByKey:(NSString*)key {
    NSString* str = [self stringByKey:key];
    if (str) {
        return [str integerValue];
    }
    
    NSNumber* value = [self valueForKey:key];
    if (value && [value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return NSUIntegerMax;
}

- (CGFloat)floatByKey:(NSString *)key {
    id value = [self valueForKey:key];
    if (value
        && [value respondsToSelector:@selector(floatValue)]
        && ![value respondsToSelector:@selector(isEqualToString:)]) {
        return [value floatValue];
    }
    return CGFLOAT_MAX;

}

- (NSNumber*)numberByKey:(NSString *)key {
    NSNumber* num = [self valueForKey:key];
    if (num && [num respondsToSelector:@selector(stringValue)]) {
        return num;
    }
    return nil;
}

- (NSURL*)URLByKey:(NSString*)key {
    id URL = [self valueForKey:key];
    if (URL && [URL respondsToSelector:@selector(absoluteURL)]) {
        return URL;
    }
    if (URL && [URL respondsToSelector:@selector(isEqualToString:)]
            && [URL hasPrefix:@"http"]) {
        return [NSURL URLWithString:URL];
    }
    return nil;
}

- (BOOL)boolByKey:(NSString*)key {
    id truthy = [self valueForKey:key];
    if ([truthy respondsToSelector:@selector(boolValue)]) {
        return [truthy boolValue];
    }
    return NO;
}

@end
