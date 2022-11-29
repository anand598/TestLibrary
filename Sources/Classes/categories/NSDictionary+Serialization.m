//
//  NSDictionary+Serialization.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "NSDictionary+Serialization.h"

@implementation NSDictionary (Serialization)

- (BOOL)valuesCanBeSerialized {
    return [self valuesCanBeSerializedWithKeyPath:@"self"];
}

- (BOOL)valuesCanBeSerializedWithKeyPath:(NSString*)path {
    for (NSString* key in [self allKeys]) {
        NSString* keypath = [NSString stringWithFormat:@"%@.%@",path,key];
        if ([NSDictionary keyPath:keypath withValueCanBeSaved:[self valueForKey:key]]) {
            continue;
        }
        return NO;
    }
    return YES;
}

+ (BOOL)keyPath:(NSString*)path withValueCanBeSaved:(id)value {
    if ([value isKindOfClass:[NSData class]]) {
        return YES;
    }
    
    if ([value isKindOfClass:[NSDate class]]) {
        return YES;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        for (id subval in value) {
            NSInteger n = [value indexOfObject:subval];
            NSString* keyN = [path stringByAppendingFormat:@"[%li]",(long)n];
            if (![self keyPath:keyN withValueCanBeSaved:subval]) {
                NSLog(@"%@ of type %@ cannot be saved.",keyN,NSStringFromClass([value class]));
                return NO;
            }
        }
        return YES;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [value valuesCanBeSerializedWithKeyPath:path];
    }
    
    NSLog(@"%@ of type %@ cannot be saved.",path,NSStringFromClass([value class]));
    return NO;
}

+ (id)prunedValueOf:(id)value {
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSDate class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray* newVal = @[];
        for (id subval in value) {
            id newSubval = [NSDictionary prunedValueOf:subval];
            if (newSubval) {
                newVal = [newVal arrayByAddingObject:newSubval];
            }
        }
        return newVal;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* copy = [NSMutableDictionary dictionaryWithDictionary:value];
        for (NSString* key in [value allKeys]) {
            id valueValue = [value valueForKey:key];
            id newVal = [NSDictionary prunedValueOf:valueValue];
            if (newVal) {
                [copy setObject:newVal forKey:key];
            } else {
                [copy removeObjectForKey:key];
            }
        }
        return [NSDictionary dictionaryWithDictionary:copy];
    }
    
    return nil;
}

- (NSDictionary*)dictionaryByPruningUnserializableObjects {
    return [NSDictionary prunedValueOf:self];
}


@end
