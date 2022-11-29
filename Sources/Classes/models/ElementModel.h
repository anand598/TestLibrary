//
//  ElementModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <SyndecaSDK/SyndecaModel.h>
#import <SyndecaSDK/PolygonModel.h>
#import <SyndecaSDK/HasID.h>
#import <SyndecaSDK/DependencyInjection.h>

@interface ElementModel : SyndecaModel <DependencyInjection,HasID>
/** An enumeration of element types. */
typedef enum {
    ElementModelType_None,
    ElementModelType_Product,
    ElementModelType_Variant,
    ElementModelType_Widget,
    ElementModelType_Link,
    ElementModelType_Any
} ElementModelType;

/** The type of on page element the ElementModel is. */
- (ElementModelType)type;
/** The 'tooltip' style of this element. */
- (NSString*)style;
/** The name of the element. */
- (NSString*)name;
/** Whether or not the element is disabled. */
- (BOOL)isDisabled;
/** The id of the associated product model. 
 
 Returns nil if the element is not a product element.
 */
- (NSString*)productID;
/** The widget id of the element.
 
 Returns nil if the element is not a widget element.
 */
- (NSString*)widgetID;
/** The hit area of the element. */
- (PolygonModel*)hitAreaPolygon;
/** Whether or not the element's style is supported. */
- (BOOL)isSupported;
/** The preselected variant ID. */
- (NSString*)selectedVariant;
- (NSString*)onPageVariantId;


@end
