//
//  ScanShopResult.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/16/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/PageModel.h>

/** Represents the different result selections a user can make. */
typedef enum {
    ScanShopResultTypeUnknown,
    ScanShopResultTypePage,
    ScanShopResultTypeProduct,
    ScanShopResultTypeVideo,
    ScanShopResultTypeLink,
    ScanShopResultTypeError
} ScanShopResultType;

/** The eventual object that the controller will call back with after the user makes a selection. */
@interface ScanShopResult : NSObject
/** The page model associated with the result. */
@property (readwrite) PageModel* page;
/** The type of the result. */
@property (readwrite) ScanShopResultType resultType;
/** The result object. Depending on the resultType this value will be a different object
 
    ScanShopResultTypeUnknown => id
    ScanShopResultTypePage    => PageModel
    ScanShopResultTypeProduct => ProductGroupModel
    ScanShopResultTypeVideo   => VideoModel
    ScanShopResultTypeLink    => ElementLinkModel
    ScanShopResultTypeError   => NSString (description of the error)
 
 Therefore you should use the resultType to cast the result to the specified type
 for handling.
 */
@property (readwrite) id result;
@end
