//
//  VariantModel.h
//  Justice
//
//  Created by Schell Scivally on 6/26/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ProductGroupModel.h>

/** A VariantModel is a sub product. It is a member of a product group.
 For convenience a VariantModel has a reference to its parent product group
 (which is a ProductModel) and its sub-product ID.
 */
@interface VariantModel : NSObject <HasID>

@property (readwrite) ProductGroupModel* productGroup;
@property (readwrite) NSString* variantId;

- (NSString*)ID;
- (NSDictionary*)info;

/** Returns the ProductModel of the entity this variant represents. */
- (ProductGroupModel*)productRepresentation;

/** Returns the index of the variant in its product group. */
- (NSUInteger)indexInProductGroup;

@end
