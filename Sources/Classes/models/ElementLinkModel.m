//
//  ElementLinkModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "ElementLinkModel.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "ExternalLinkParams.h"

@implementation ElementLinkModel

SYNTHESIZE_DI

- (id)initWithSearchModel:(SearchModel*)model {
    NSDictionary* data = [NSDictionary dictionaryWithObjects:@[model.catalogLink, @"url"] forKeys:@[@"url", @"type"]];
    NSDictionary* info = [NSDictionary dictionaryWithObjects:@[data, @"url", @"none"] forKeys:@[@"data", @"type", @"id"]];
    
    return [super initWithInfo:info];
}

- (NSDictionary*)data {
    return [self.info infoByKey:@"data"];
}

/** The link title. */
- (NSString*)linkID {
    return [[self.data numberByKey:@"id"] stringValue];
}

- (NSString*)linkTitle {
    if ([[[self data] allKeys] containsObject:@"text"]) {
        return [[self data] valueForKey:@"text"];
    }
    if ([[[self data] allKeys] containsObject:@"url"]) {
//        return [[self data] valueForKey:@"text"];
        return [self.data stringByKey:@"url"];
    }
    return nil;   
}

/** The link description. */
- (NSString*)linkDescription {
    if ([[self.data allKeys] containsObject:@"desc"]) {
        return [self.data stringByKey:@"desc"];
    }
    return nil;
}

/** The url of the link.
 
 Returns nil if linkType is any type other than LinkTypeExternal.
 */
- (UrlModel*)URL {
    if ([self linkType] == LinkTypeExternal) {
        NSString* path = [self.data stringByKey:@"url"];
        path = [path stringByReplacingOccurrencesOfString:@"{{viewer_var}}" withString:@"ios"];
        path = [path stringByReplacingOccurrencesOfString:@"{{link_var}}" withString:self.ID];
        path = [path stringByReplacingOccurrencesOfString:@"{{page_var}}" withString:@""];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL* url = [NSURL URLWithString:path];
        UrlModel* model = [[UrlModel alloc] initWithNSURL:url];
        return model;
    }
    return nil;
}
/** The page of the link.
 
 Returns NSUIntegerMax if linkType is any type other than LinkTypeInternal.
 */
- (NSUInteger)page {
    if ([self linkType] == LinkTypeInternal) {
        NSUInteger page = [self.data uintByKey:@"page"];
        // SYN-1025
        // Our pages are zero indexed so decrease this by one.
        if (page > 0) {
            page -= 1;
        }
        return page;
    } else {
        return NSUIntegerMax;
    }
};

#pragma mark - Determining Content
/// @name Determining Content

/** The link type. */
- (LinkType)linkType {
    NSString* type = [self.data stringByKey:@"type"];
    if ([type isEqualToString:@"url"]) {
        return LinkTypeExternal;
    } else if ([type isEqualToString:@"page"]) {
        return LinkTypeInternal;
    } else {
        return LinkTypeNone;
    }
}

/** Whether or not the link is a video. */
- (BOOL)isVideo {
    return ![[self style] isEqual:[NSNull null]] && [[self style] isEqualToString:@"VideoLinkTooltip"];
}

@end
