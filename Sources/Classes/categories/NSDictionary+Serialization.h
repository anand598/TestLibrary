//
//  NSDictionary+Serialization.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDictionary (Serialization)

+ (BOOL)keyPath:(NSString*)path withValueCanBeSaved:(id)value;
+ (id)prunedValueOf:(id)value;
- (BOOL)valuesCanBeSerialized;
- (NSDictionary*)dictionaryByPruningUnserializableObjects;

@end
