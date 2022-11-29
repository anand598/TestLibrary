//
//  SyndecaModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "SyndecaModel.h"

@implementation SyndecaModel

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.info = info;
    }
    return self;
}

- (NSString*)ID {
    id possibleID = [self.info valueForKey:@"id"];
    NSString* ID = @"";
    if ([possibleID respondsToSelector:@selector(stringByAppendingFormat:)]) {
        ID = (NSString*)possibleID;
    } else {
        ID = [(NSNumber*)possibleID stringValue];
    }
    
    if (!ID) {
        [NSException raise:@"AAAAAHHH! Expected an ID." format:@"%@",self.info];
    }
    
    return ID;
}

@end
