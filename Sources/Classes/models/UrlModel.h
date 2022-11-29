//
//  UrlModel.h
//  SyndecaSDK
//
//  Created by Macbook Pro on 10/11/20.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/CatalogModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface UrlModel : NSObject

- (id)initWithNSURL:(NSURL*)url;
- (BOOL)isEqualTo:(UrlModel*)urlModel;
- (NSString*)asString;
- (NSURL*)asURL;
/** Whether or not the url is a link to another catalog */
- (BOOL)isCatalogLink;
/** Return the slug of the catalog to link to, or nil if this is not a catalog link. */
- (NSString*)catalog;
/** Return the page of the catalog to link to, or nil if this is not a catalog link. */
- (NSString*)page;
/** The referring catalog */
@property (readwrite) CatalogModel* referringCatalog;

@end

NS_ASSUME_NONNULL_END
