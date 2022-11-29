//
//  NSDictionary+AsObjectOrNil.h
//  CocoaViewer
//
//  Created by Schell Scivally on 8/8/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSDictionary (AsObjectOrNil)

/** Returns whether the key exists in the dictionary's set of keys. */
- (BOOL)hasKey:(NSString*)key;
/** Returns the object at the given path, where each index of the path is
 specified by an object. For example:
 
     NSString* value = [info valueByPath:@"playlist",@(0),@"medium",@(1),nil];
 
 is equivalent to:
 
     NSString* value = [[[[info valueForKey:@"playlist"] objectAtIndex:0] arrayByKey:@"medium"] objectAtIndex:1];
 
 @warning Requires nil termination!
 */
- (id)valueByPath:(id)values, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("Use dictionary literals instead");
/** Returns the string value of the given key, or nil. 

 String values that will equate to nil are: 
    @"<null>"
 */
- (NSString*)stringByKey:(NSString*)key;
/** Returns the array value of the given key, or nil. */
- (NSArray*)arrayByKey:(NSString*)key;
/** Returns the dictionary value of the given key, or nil. */
- (NSDictionary*)infoByKey:(NSString*)key;
/** Returns the NSUInteger value of the given key, or NSUIntegerMax. */
- (NSUInteger)uintByKey:(NSString*)key;
/** Returns the CGFloat value of the given key, or CGFLOAT_MAX. */
- (CGFloat)floatByKey:(NSString*)key;
/** Returns the NSNumber value of the given key, or nil. */
- (NSNumber*)numberByKey:(NSString*)key;
/** Return the NSURL value of the given key or nil. */
- (NSURL*)URLByKey:(NSString*)key;
- (BOOL)boolByKey:(NSString*)key;

@end
