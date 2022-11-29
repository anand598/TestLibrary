//
//  SearchModel.m
//  SyndecaSDK
//
//  Created by Schell Scivally on 6/20/21.
//

#import "SearchModel.h"
#import <SyndecaSDK/NSDictionary+AsObjectOrNil.h>
#import <SyndecaSDK/IssueModel.h>

@implementation SearchModel

- (id)initWithInfo:(NSDictionary *)info fromGuide:(GuideModel*)guide {
    self = [super init];
    if (self) {
        self.index = [info stringByKey:@"_index"];
        self.type = [info stringByKey:@"_type"];
        self.ID = [info stringByKey:@"_id"];
        self.score = [info floatByKey:@"_score"];
        
        NSDictionary* source = [info infoByKey:@"_source"];
        NSUInteger catalogId = [source uintByKey:@"catalog_id"];

        self.catalogLink = [source stringByKey:@"catalog_link"];
        self.title = [source stringByKey:@"title"];
        for (IssueModel* issue in [guide issueModels]) {
            if (catalogId == issue.numberId) {
                self.title = [NSString stringWithFormat:@"%@ - %@", self.title, issue.title];
            }
        }
        self.desc = [source stringByKey:@"description"];
        self.thumb = [source URLByKey:@"thumb"];
        
        NSArray* products = [source arrayByKey:@"products"];
        if (products && [products count] > 0) {
            NSDictionary* product = [products objectAtIndex:0];
            if ([self.desc isEqualToString:@""]) {
                self.desc = [product stringByKey:@"description"];
            }
        }
    }
    return self;
}

@end
