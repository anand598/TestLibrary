//
//  OfflineProxy.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/29/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "OfflineProxy.h"
#import "OfflineCatalog.h"
#import "FetchProxy.h"
#import "UIImageView+AFNetworking.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/UIAlertView+RACSignalSupport.h>
//#import <AFNetworking/AFNetworking.h>
#import "AFNetworking.h"

@implementation OfflineProxy

static OfflineProxy* __shared = nil;
+ (OfflineProxy*)sharedProxy {
    if (!__shared) {
        __shared = [[OfflineProxy alloc] init];
    }
    return __shared;
}

+ (void)setSharedProxy:(OfflineProxy *)proxy {
    __shared = proxy;
}

- (id)init {
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        self.offlineCatalogs = [OfflineProxy offlineCatalogs];
        self.offlineGuide = [self guideFromOfflineCatalogs:self.offlineCatalogs];
    }
    return self;
}

#pragma mark - Set up

- (GuideModel*)guideFromOfflineCatalogs:(NSArray*)catalogs {
    NSArray* issues = [[[catalogs rac_sequence]
                        map:^id(OfflineCatalog* c) {
                            return c.issueModel.info;
                        }] array];
    GuideModel* guide = [[GuideModel alloc] initWithInfo:@{@"content" : issues}];
    return guide;
}

#pragma mark - Downloading

- (RACSignal*)alertAndDownload:(IssueModel*)issue {
    
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        return nil;
    }];
}

- (RACSignal*)downloadIssue:(IssueModel*)issue {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        OfflineCatalog* cache = [[OfflineCatalog alloc] init];
        cache.issueModel = issue;
        
        [subscriber sendNext:@"Downloading..."];
        [[FetchProxy fetchCatalogModelUsingIssueModel:issue] subscribeNext:^(CatalogModel* c) {
            @strongify(self);
            cache.catalogModel = c;
            
            // SYN-422 simplifying offline download.
            // RACSignal* fetchProducts = [FetchProxy fetchProductsInPageModels:c.pageModels fromCatalogModel:c];
            RACSignal* fetchProducts = [RACSignal return:[NSArray array]];
            [fetchProducts subscribeNext:^(NSArray* ps) {
                cache.products = ps;
                BOOL saved = [cache writeToDisk];
                if (!saved) {
                    [subscriber sendError:[NSError errorWithDomain:@"Could not save data for offline." code:0 userInfo:[cache info]]];
                    return;
                }
                
                [subscriber sendNext:@(0.0)];
                
                NSArray* imgs = [cache allImageURLs];
                
                __block CGFloat success = 0;
                __block CGFloat error = 0;
                [[self downloadImages:imgs] subscribeNext: ^(id img) {
                    if (img) {
                        success++;
                    } else {
                        error++;
                    }
                    [subscriber sendNext:@((success + error) / (CGFloat)[imgs count])];
                } completed:^{
                    [subscriber sendNext:@(1)];
                    self.offlineCatalogs = [self.offlineCatalogs arrayByAddingObject:cache];
                    self.offlineGuide = [self guideFromOfflineCatalogs:self.offlineCatalogs];
                    [[[RACSignal empty] delay:1] subscribeCompleted:^{
                        [subscriber sendCompleted];
                    }];
                }];
            }];
            
            
        }];
        return nil;
    }];
}

- (RACSignal*)downloadImages:(NSArray*)images {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
        NSMutableArray* imgs = [NSMutableArray arrayWithArray:images];
        NSURL* firsturl = [imgs firstObject];
        
        __block int count = 0;
        
        RACSignal* seq = [self downloadImage:firsturl];
        for (int i = 0; i < [images count]; i++) {
            seq = [seq flattenMap:^RACStream* (UIImage* prevImg) {
                NSURL* prev = [imgs firstObject];
                
                if (prevImg) {
                    NSLog(@"%i - %@",count,[prev absoluteString]);
                } else {
                    NSLog(@"%i - ERR %@",count,[prev absoluteString]);
                }
                [imgs removeObject:prev];
                NSLog(@"img: %lu",(unsigned long)[imgs count]);
                // Save the previous.
                BOOL saved = [OfflineProxy saveImage:prevImg usingURL:prev];
                if (saved) {
                    [subscriber sendNext:prevImg];
                } else {
                    [subscriber sendNext:nil];
                }
                
                count++;
                
                if ([imgs count]) {
                    NSURL* current = [imgs firstObject];
                    return [self downloadImage:current];
                } else {
                    return [RACSignal empty];
                }
            }];
        }
        [seq subscribeCompleted:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//- (RACSignal*)downloadImage:(NSURL*)url {
//    @weakify(self);
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        @strongify(self);
//        NSURLRequest* req = [NSURLRequest requestWithURL:url];
//        AFHTTPSessionManager* operation = [AFHTTPSessionManager manager];
//        operation.responseSerializer = [AFImageResponseSerializer serializer];
//        [operation GET:req.URL.absoluteString parameters:req.HTTPBody progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"got image:%@",responseObject);
//            [subscriber sendNext:responseObject];
//            [subscriber sendCompleted];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [subscriber sendNext:nil];
//            [subscriber sendCompleted];
//        }];
//        return nil;
//    }];
//}

- (RACSignal*)downloadImage:(NSURL*)url {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSURLRequest* req = [NSURLRequest requestWithURL:url];

        AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        operation.responseSerializer = [AFImageResponseSerializer serializer];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"got image:%@",responseObject);
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];

        [self.operationQueue addOperation:operation];

        return nil;
    }];
}

#pragma mark - Reloading

+ (NSArray*)offlineCatalogs {
    NSURL* dataURL = [OfflineCatalog offlineDataURL];
    NSArray* files = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtURL:dataURL
                      includingPropertiesForKeys:nil
                      options:NSDirectoryEnumerationSkipsHiddenFiles
                      error:nil];
    NSArray* cs = @[];
    for (NSURL* file in files) {
        OfflineCatalog* catalog = [[OfflineCatalog alloc] initWithContentsOfURL:file];
        if (catalog) {
            cs = [cs arrayByAddingObject:catalog];
        }
    }
    return cs;
}

- (OfflineCatalog*)offlineCatalogWithIssueID:(NSString*)ID {
    for (OfflineCatalog* c in self.offlineCatalogs) {
        if ([c.issueModel.ID isEqualToString:ID]) {
            return c;
        }
    }
    return nil;
}

#pragma mark - Saving to disk

static NSUInteger __byteSize = 0;
+ (BOOL)saveImage:(UIImage*)img usingURL:(NSURL*)url {
    NSURL* path = [OfflineProxy localURLForURL:url];
    NSData* imgData = UIImageJPEGRepresentation(img, 1); // UIImagePNGRepresentation(img);
    __byteSize += [imgData length];
    NSLog(@"img data byte size: %lu downloaded total: %lu", (unsigned long)[imgData length], (unsigned long)__byteSize);
    return [imgData writeToURL:path atomically:YES];
}

+ (NSURL*)localURLForURL:(NSURL*)url {
    if (!url) {
        return nil;
    }
    NSURL* images = [OfflineCatalog offlineImagesURL];
    NSString* ext = [url pathExtension];
    if ([ext isEqualToString:@"png"]) {
        ext = @"jpg";
    }
    NSString* filename = [NSString stringWithFormat:@"%lu",(unsigned long)[[url absoluteString] hash]];
    filename = [filename stringByAppendingPathExtension:ext];
    NSURL* localURL = [images URLByAppendingPathComponent:filename];
    NSLog(@"%s %@ local url is: %@",__func__, url,localURL);
    return localURL;
}

+ (NSURL*)localURLForSavedImageNamed:(NSString*)name {
    NSURL* images = [OfflineCatalog offlineImagesURL];
    NSURL* url = [images URLByAppendingPathComponent:name];
    return url;
}

#pragma mark - Removing from disk

- (void)deleteOfflineCatalogWithIssueID:(NSString*)ID {
    OfflineCatalog* c = [self offlineCatalogWithIssueID:ID];
    if (c) {
        [[NSFileManager defaultManager] removeItemAtURL:[c localURL] error:nil];
        // Now delete all the images. If two catalogs share images, too bad.
        NSArray* imgs = [c allImageURLs];
        imgs = [[imgs.rac_sequence map:^NSURL*(NSURL* url) {
            return [OfflineProxy localURLForURL:url];
        }] array];
        for (NSURL* url in imgs) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
    }
    self.offlineCatalogs = [[self.offlineCatalogs.rac_sequence
                             filter:^BOOL(OfflineCatalog* c2) {
                                 return ![c2.issueModel.ID isEqualToString:ID];
    }] array];
    self.offlineGuide = [self guideFromOfflineCatalogs:self.offlineCatalogs];
}

@end
