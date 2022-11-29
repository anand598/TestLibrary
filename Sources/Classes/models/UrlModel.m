//
//  UrlModel.m
//  SyndecaSDK
//
//  Created by Macbook Pro on 10/11/20.
//

#import "UrlModel.h"

@interface UrlModel ()

@property (readwrite) NSURL* rawUrl;

@end

@implementation UrlModel

- (id)initWithNSURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.rawUrl = url;
    }
    return self;
}

- (BOOL)isEqualTo:(UrlModel *)urlModel {
    return [[urlModel.rawUrl absoluteString] isEqualToString: [self.rawUrl absoluteString]];
}

- (BOOL)isCatalogLink {
    NSString* raw = [[self.rawUrl absoluteString] stringByRemovingPercentEncoding];
    return [raw characterAtIndex:0] == '#';
}

- (NSString *)catalog {
    NSString* str = [self.rawUrl absoluteString];
    NSArray* paths = [str componentsSeparatedByString:@"/"];
    NSInteger size = [paths count];
    if (size < 2 || size > 4) {
        return nil;
    }
    NSString* catalog = [paths objectAtIndex: 1];
    // sometimes there's a query string at the end...
    NSArray* query = [catalog componentsSeparatedByString:@"?"];
    return [query objectAtIndex:0];
}

- (NSString *)page {
    NSString* str = [self.rawUrl absoluteString];
    NSArray* paths = [str componentsSeparatedByString:@"/"];
    NSInteger size = [paths count];
    if (size != 4) {
        return nil;
    }
    NSArray* spread = [[paths objectAtIndex:3] componentsSeparatedByString:@"-"];
    NSString* page = [spread objectAtIndex:0];
    // sometimes there's a query string at the end...
    NSArray* query = [page componentsSeparatedByString:@"?"];
    return [query objectAtIndex:0];
}

- (NSString *)asString {
    return [self.rawUrl absoluteString]; 
}

- (NSURL *)asURL {
    return self.rawUrl;
}

@end
