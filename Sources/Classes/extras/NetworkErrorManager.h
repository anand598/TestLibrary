//
//  NetworkErrorManager.h
//  Syndeca iOS SDK
//
//  Created by Michael Dominick on 7/15/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkErrorManager : NSObject

+ (NetworkErrorManager *)sharedManager;

@property (nonatomic) BOOL hasShownNetworkError;

@end
