//
//  self.m
//  Pods
//
//  Created by Schell Scivally on 2/29/16.
//
//

#import "Overseer.h"
#import "SyndecaTabBarController.h"
#import "PolyPageView.h"
#import "PageView.h"
#import "UIViewHelper.h"

@implementation Overseer

+ (SyndecaConfig*)testConfig {
    // Configure the syndeca service.
    SyndecaConfig* config = [[SyndecaConfig alloc] init];
    NSString* demoGuideKey = @"CFB1A537-ECCD-D4B9-EBAD-ADFD17FA0A69";
    config.guideKey = demoGuideKey;
    config.isDebug = YES;
    config.isStaging = NO;
    config.usesCDN = NO;
    return config;
}

#pragma mark - Publications

+ (GuideViewController*)guideController {
    return nil;
}

+ (GuideModel*)guideModel {
    return [self guideController].guideModel;
}

+ (BOOL)guideIsLoaded {
    return [[self guideController] isLoaded];
}

+ (void)selectPublication:(NSInteger)n {
    IssueModel* issue = [[self guideModel].issueModels objectAtIndex:n];
    [[SyndecaTabBarController sharedController] loadIssueWithModel:issue];
}

#pragma mark - Publication

+ (CatalogViewController*)catalogController {
    return [SyndecaTabBarController sharedController].catalogController;
}

+ (CatalogModel*)catalogModel {
    return [self catalogController].catalogModel;
}

+ (BOOL)publicationIsLoaded {
    if ([self catalogController] == nil) {
        return NO;
    }
    return [self currentPageView].imageView.image != nil;
}

#pragma mark - Pages

+ (PageView*)currentPageView {
    return [self catalogController].leftPageView;
}

#pragma mark - Products

+ (void)selectProduct:(NSInteger)n {
    if (IS_IPAD) {
        
    }
}

@end
