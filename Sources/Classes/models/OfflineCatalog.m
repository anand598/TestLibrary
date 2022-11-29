//
//  OfflineCatalog.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSDictionary+AsObjectOrNil.h"
#import "NSDictionary+Serialization.h"
#import "OfflineCatalog.h"
#import "FetchProxy.h"
#import "ProductGroupModel.h"


@implementation OfflineCatalog

+ (NSURL*)offlineDataURL {
    NSURL* docs = [[NSFileManager defaultManager]
                   URLForDirectory:NSDocumentDirectory
                   inDomain:NSUserDomainMask
                   appropriateForURL:nil
                   create:YES
                   error:nil];
    docs = [docs URLByAppendingPathComponent:@"offline-data"];
    return docs;
}

+ (NSURL*)offlineImagesURL {
    NSURL* docs = [[NSFileManager defaultManager]
                   URLForDirectory:NSDocumentDirectory
                   inDomain:NSUserDomainMask
                   appropriateForURL:nil
                   create:YES
                   error:nil];
    docs = [docs URLByAppendingPathComponent:@"offline-images"];
    return docs;
}

- (BOOL)writeToDisk {
    if (!self.issueModel || !self.catalogModel || !self.products) {
        return NO;
    }
    
    NSDictionary* info = [NSDictionary prunedValueOf:[self info]];
    if ([info valuesCanBeSerialized]) {
        NSURL* url = [self localURL];
        BOOL saved = [info writeToURL:url atomically:YES];
        return saved;
    }
    return NO;
}

- (id)init {
    self = [super init];
    if (self) {
        // Create our storage directories
        for (NSURL* url in @[[OfflineCatalog offlineDataURL], [OfflineCatalog offlineImagesURL]]) {
            NSError* error = nil;
            BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:url
                                                    withIntermediateDirectories:YES
                                                                     attributes:nil
                                                                          error:&error];
            if (!created) {
                NSLog(@"could not create offline storage! %@",error);
            }
        }
    }
    return self;
}

- (id)initWithContentsOfURL:(NSURL*)url {
    self = [self init];
    if (self) {
        NSDictionary* info = [[NSDictionary alloc] initWithContentsOfURL:url];
        if (!info) {
            return nil;
        }
        self.issueModel = [[IssueModel alloc] initWithInfo:[info infoByKey:@"issue"]];
        self.catalogModel = [[[CatalogModel DIClass] alloc] initWithInfo:[info infoByKey:@"catalog"]];
        
        NSArray* products = @[];
        NSArray* productInfos = [info arrayByKey:@"products"];
        for (NSDictionary* productInfo in productInfos) {
            ProductGroupModel* product = [[[ProductGroupModel DIClass] alloc] initWithInfo:productInfo];
            products = [products arrayByAddingObject:product];
        }
        self.products = products;
    }
    return self;
}

- (NSDictionary*)info {
    return @{ @"issue" : self.issueModel.info,
              @"catalog" : self.catalogModel.info,
              @"products" : [[self.products.rac_sequence map:^id(ProductGroupModel* pm) {
                  return pm.info;
              }] array]};
}

- (NSURL*)localURL {
    NSString* filename = self.issueModel.title;
    NSURL* offline = [OfflineCatalog offlineDataURL];
    NSURL* url = [offline URLByAppendingPathComponent:filename];
    url = [url URLByAppendingPathExtension:@"plist"];
    return url;
}

- (NSArray*)allImageURLs {
    NSDictionary* urls = self.issueModel.imageURLs;
    
    if (!urls || [urls isEqual:[NSNull null]]) {
        return @[];
    }
    
    NSArray* imgs = [self.issueModel.imageURLs allValues];
    imgs = [imgs arrayByAddingObjectsFromArray:[self.catalogModel allImageURLs]];
    
    // SYN-422 simplifying offline download.
    //for (ProductModel* product in self.products) {
    //    imgs = [imgs arrayByAddingObjectsFromArray:[product allImageURLs]];
    //}
    // Make sure the images are unique.
    imgs = [[NSSet setWithArray:imgs] allObjects];
    return imgs;
}

@end
