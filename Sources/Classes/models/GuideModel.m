//
//  GuideModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "GuideModel.h"
#import "IssueModel.h"
#import "Icons.h"
#import "MasterConfiguration.h"
#import "SyndecaTabBarController.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation GuideModel

SYNTHESIZE_DI

- (BOOL)isSameVersionAsGuideModel:(GuideModel*)guideModel {
    if (guideModel) {
        if ([[guideModel info] isEqualToDictionary:[self info]]) {
            return YES;
        }
    }
    return NO;
}

- (IssueModel*)issueWithID:(NSString*)ID {
    NSLog(@"looking for ID %@",ID);
    for (IssueModel* issue in self.issueModels) {
        NSLog(@"%@",issue.ID);
        if ([ID isEqualToString:issue.ID]) {
            return issue;
        }
    }
    return nil;
}

- (NSURL*)logoURL {
    NSString* s = self.info[@"logo"];
    return [NSURL URLWithString:s];
}

- (NSArray*)newerAppVersions {
    NSDictionary* viewer = [self.info infoByKey:@"viewer"];
    if (viewer) {
        NSArray* newerVersions = [viewer arrayByKey:@"newerVersions"];
        if (newerVersions) {
            return newerVersions;
        }
    }
    return nil;
}

- (NSString*)platformVersion {
    NSDictionary* viewer = [self.info infoByKey:@"viewer"];
    if (viewer) {
        NSDictionary* version = [viewer infoByKey:@"version"];
        if (version && [version count]) {
            float versionFloat = [version floatByKey:@"version"];
            NSString* versionString = [NSString stringWithFormat:@"%2f",versionFloat];
            return versionString;
        }
    }
    return nil;
}

//Returns an array of issue models in this guide. Each issuemodel can be used to configure a catalog model.
- (NSArray*)issueModels {
    NSMutableArray* issueModels = [NSMutableArray array];
    
    //    Testing the no publications alert
//    return [NSArray arrayWithArray:issueModels];
    NSArray* content = [self.info arrayByKey:@"content"];
    if (content) {
        for (int i = 0; i < [content count]; i++) {
            NSDictionary* issueInfo = [content objectAtIndex:i];
            if (issueInfo) {
                IssueModel* issueModel = [[IssueModel alloc] initWithInfo:issueInfo];
                issueModel.guide = self;
                [issueModels addObject:issueModel];
            }
        }
    }

    return [NSArray arrayWithArray:issueModels];
}

- (NSURL*)updateURL {
    NSDictionary* viewer = [self.info infoByKey:@"viewer"];
    if (viewer) {
        NSString* updatePath = [viewer stringByKey:@"updateUrl"];
        return [NSURL URLWithString:updatePath];
    }
    return nil;
}

@end
