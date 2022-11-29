//
//  ProductGroupModel.h
//  Pods
//
//  Created by Rijul Gupta on 1/7/17.
//
//


#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/PageModel.h>
#import <SyndecaSDK/Shareable.h>
#import <SyndecaSDK/CatalogModel.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/ProductEntityModel.h>

@interface ProductGroupModel : SyndecaModel <DependencyInjection,Shareable>
    
/** Sets a flag that tells all products whether the app is currently in a scan and shop mode. */
+ (void)setIsScanAndShop:(BOOL)isScanShop;
/** Returns a flag that tells all products whether the app is currently in a scan and shop mode. */
+ (BOOL)isScanAndShop;
    
#pragma mark - Offline Helpers
- (NSArray*)allImageURLs;
    
#pragma mark - Smart Functions
- (NSString*)localizedPriceString;
    
#pragma mark - Properties
/** The parent catalog. */
@property (readwrite) CatalogModel* catalog;
/** If this product is an "entity" this prop will be the entity's parent product (product group) */
//ProductGroup is the parent of product entities

/** Any on-page elements associated with this product. */
@property (readwrite) NSArray* associatedElements;
    
#pragma mark - Getters
/** A product's sub products. */
- (NSArray*)entities;
/** The first sub product. */
- (ProductEntityModel*)firstEntity;
/** The name of the product. */
- (NSString*)name;
/** The description of the product.
  This is named 'productDescription' instead of 'description' in order to
  distinguish itself from [NSObject description]
 */
    @property(nonatomic, retain) NSString* onPageVariant;
- (NSString*)productDescription;
/** The descipriton of the product, which may include html tags. */
- (NSString*)rawDescription;
/** The current price of the product. */
- (NSString*)price;
- (CGFloat)priceFloat;
- (CGFloat)priceSaleFloat;
- (BOOL)isSale;
- (BOOL)hasPriceRange;
- (NSArray*)priceRange;
/** A promotional message of sorts. */
- (NSString*)promoMessage;
/** The title of the price. */
- (NSString*)priceTitle;
/** The text of the price label in case that price is nil. */
- (BOOL)priceIsUnavailable;
/** In the case of a sale, this is the original price. */
- (NSString*)originalPrice;
/** In the case of a sale, this is the title of the original price. */
- (NSString*)originalPriceTitle;
/** The url of the preview image. */
- (NSURL*)previewURL;
/** An array of alt images, which may be contained in previewURLs. */
- (NSArray*)altImageURLs;
/** The title of the product.
     
  Title is an alias of name.
 */
- (NSString*)title;
/** The subtitle of the product. */
- (NSString*)subtitle;
/** The syndeca_cta custom value for the product **/
- (NSString*)syndecaCTATitle;
/** A list of features for the product. */
- (NSArray*)features;
/** A list of size models for the product. */
- (NSArray*)sizes;
/** A list of swatch models for the product. */
- (NSArray*)swatches;
/** A string to use in case this product is emailed somewhere. */
- (NSString*)emailSubject;
/** The price view info dictionary. */
- (NSDictionary*)priceView;
/** The brand of the product or nil. */
- (NSString*)brand;
/** The style number of the product or nil. */
- (NSString*)styleNum;
/** The shipping information for the product, used in the PDP. */
- (NSString*)shippingInfo;

#pragma mark Table Cell Labels
/** The cell title. */
- (NSString*)cellTitle;
/** The cell description. */
- (NSString*)cellDescription;

#pragma mark Sharing
/** The url1 value. */
- (NSURL*)url1;
/** The url1_shareurl value. */
- (NSURL*)url1_shareurl;
/** The url1_link_id value. */
- (NSString*)url1_link_id;
/** The url1 value with additional tracking info appended.*/
- (NSURL*)url1_tracking;
#pragma mark - Setters
    
/** Overwrites the title in the model's underlying data. */
- (void)setTitle:(NSString*)title;
    
@end
