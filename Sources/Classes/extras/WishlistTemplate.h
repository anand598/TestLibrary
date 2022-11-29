//
//  WishlistTemplate.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 3/19/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WishlistTemplate : NSObject

- (id)initWithFilePath:(NSString*)filepath andInfo:(NSDictionary*)info andItems:(NSArray*)items;
- (NSString*)toString;

@end
