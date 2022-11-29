//
//  CatalogModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "CatalogModel.h"
#import "PageModel.h"
#import "ShareItem.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation CatalogModel

SYNTHESIZE_DI

- (NSArray*)allImageURLs {
    NSArray* urls = @[];
    for (PageModel* page in self.pageModels) {
        urls = [urls arrayByAddingObject:page.imageURL];
        urls = [urls arrayByAddingObject:page.thumbURL];
    }
    return urls;
}

- (RACSignal*)imageForSharing {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (NSURL*)URLForSharing {
    return nil;
}

- (NSString*)textForSharingForActivity:(NSString *)a {
    return self.title;
}

- (NSArray*)activityItems {
    return @[ [[ShareItem alloc] initWithItem:self.title],
              [[ShareItem alloc] initWithPlaceholderItem:self.title andSignal:[self imageForSharing]]];
}

- (ShareType)typeForSharing {
    return ShareTypeCatalog;
}

-(AppExtensions*)extensions {
    AppExtensions* exts = [[AppExtensions alloc] init];
    BOOL sharing = [self.info boolByKey:@"sharingEnabled"];
    BOOL search = [self.info boolByKey:@"searchEnabled"];
    BOOL toc = [self.info boolByKey:@"tocEnabled"];
    BOOL shop = [self.info boolByKey:@"shopNowEnabled"];
    if (![self.info hasKey:@"shopNowEnabled"]) {
        shop = YES;
    }
    BOOL cover = [self.info boolByKey:@"hasCover"];
    BOOL singles = [self.info boolByKey:@"forceSinglePage"];
    exts.sharingEnabled = sharing;
    exts.searchEnabled = search;
    exts.tocEnabled = toc;
    exts.shoppingEnabled = shop;
    exts.hasCover = cover;
    exts.usesSinglePages = singles;
    return exts;
}

-(NSString*)title {
    return [self.info stringByKey:@"title"];
}

-(NSString*)buildNum {
    NSUInteger buildNum = [self.info uintByKey:@"buildNum"];
    return [NSString stringWithFormat:@"%lu",(unsigned long)buildNum];
}

- (NSString*)key {
    return [self.info stringByKey:@"key"];
}

- (BOOL)isVertical {
    NSString* layoutString = [self.info stringByKey:@"layout"];
    if([layoutString isEqualToString:@"vertical"]){
        return true;
    }
    
    NSString* layout = [self.info stringByKey:@"layout"];
    if([layout isEqualToString:@"grid"]){
        return true;
    }
    
    return false;
}

- (BOOL)isGrid {
    NSString* layout = [self.info stringByKey:@"layout"];
    if([layout isEqualToString:@"grid"]){
        return true;
    }
    return false;
}


- (CGSize)pageSize{
    NSArray* pages = [self.info arrayByKey:@"pages"];
    if (pages) {
        NSDictionary* pageInfo = (NSDictionary*)[pages objectAtIndex:0];
        if(pageInfo){
            CGFloat width = [pageInfo floatByKey:@"width"];
            CGFloat height = [pageInfo floatByKey:@"height"];
            if(width && height){
                return CGSizeMake(width, height);
            }
        }
    }
    return CGSizeMake(0, 0);
}

/** The page models in this catalog. 
 An array of PageModels.
 */
-(NSArray*)pageModels {
    NSArray* pageModels = @[];
    NSArray* pages = [self.info arrayByKey:@"pages"];
    if (pages) {
        for (int i = 0; i < [pages count]; i++) {
            NSDictionary* pageInfo = (NSDictionary*)[pages objectAtIndex:i];
            PageModel* pageModel = [[[PageModel DIClass] alloc] initWithInfo:pageInfo];
            pageModel.catalog = self;
            pageModel.index = i;
            pageModels = [pageModels arrayByAddingObject:pageModel];
        }
    }
    return pageModels;
}

@end
