//
//  ProductDetailViewResult.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ProductDetailViewResultTypeUnknown,
    ProductDetailViewResultTypeShopNow,
    ProductDetailViewResultTypeWishlist,
    ProductDetailViewResultTypePinterest
} ProductDetailViewResultType;

@interface ProductDetailViewResult : NSObject

@property (readwrite) ProductDetailViewResultType resultType;
@property (readwrite) id result;

@end
