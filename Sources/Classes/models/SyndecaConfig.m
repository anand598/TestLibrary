//
//  NSDictionary+SyndecaConfigInfo.m
//  CocoaViewer
//
//  Created by Schell Scivally on 11/20/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "SyndecaConfig.h"

@interface SyndecaConfig ()

@end

@implementation SyndecaConfig

#pragma mark - Creating Config Infos

- (id)init {
    self = [super init];
    if (self) {
        self.productionAPI = @"https://cdn-api.syndeca.com/v1/rest/";
        self.stagingAPI =    @"https://stage.api.syndeca.com/v1/rest/";
        self.shareAPI =      @"https://api.syndeca.com/v1/rest/share";
        self.trackAPI =      @"https://api.syndeca.com/v1/rest/track?";
        self.guideKey = nil;
        self.isDebug = IS_DEBUG;
        self.isArchive = NO;
        self.isStaging = IS_STAGING;
    }
    return self;
}

- (SyndecaConfig*)clone {
    SyndecaConfig* config = [[SyndecaConfig alloc] init];
    config.productionAPI = self.productionAPI;
    config.stagingAPI = self.stagingAPI;
    config.shareAPI = self.shareAPI;
    config.trackAPI = self.trackAPI;
    config.guideKey = self.guideKey;
    config.isDebug = self.isDebug;
    config.isArchive = self.isArchive;
    config.isStaging = self.isStaging;
    return config;
}

#pragma mark - Getting Config Settings

- (NSString*)syndecaAPI {
    if (self.isStaging) {
        return self.stagingAPI;
    }
    return self.productionAPI;
}


@end
