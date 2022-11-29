//
//  ElementModel.m
//  CocoaViewer
//
//  Created by Schell Scivally on 12/10/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import "ElementModel.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation ElementModel

static Class __elementModelClass = nil;
+ (Class)DIClass {
    if (!__elementModelClass) {
        __elementModelClass = [ElementModel class];
    }
    return __elementModelClass;
}

+ (void)setDIClass:(Class)c {
    if ([c isSubclassOfClass:[ElementModel class]]) {
        __elementModelClass = c;
    } else {
        [NSException raise:@"Class is not a subclass of ElementModel" format:@""];
    }
}

- (NSString*)description {
    NSString* desc = [[super description] stringByAppendingFormat:@"\n info:%@",[self info]];
    return desc;
}

- (NSDictionary*)data {
    return [self.info infoByKey:@"data"];
}

/** The type of on page element the ElementModel is. */
- (ElementModelType)type {
    NSString* type = [self.info stringByKey:@"type"];
    if ([type isEqualToString:@"product"]) {
        // SYN-1189
        // Update products to product group with variants.
        NSDictionary* variant = [[self data] infoByKey:@"entity"];
        if ([variant hasKey:@"id"]) {
            return ElementModelType_Variant;
        }
        return ElementModelType_Product;
    } else if ([type isEqualToString:@"widget"]) {
        return ElementModelType_Widget;
    } else if ([type isEqualToString:@"link"]) {
        return ElementModelType_Link;
    } else {
        return ElementModelType_None;
    }
}

/** The 'tooltip' style of this element. */
- (NSString*)style {
    return [[self data] stringByKey:@"style"];
}

/** The name of the element. */
- (NSString*)name {
    return [[self data] stringByKey:@"name"];
}

/** Whether or not the element is disabled. */
- (BOOL)isDisabled {
    return [[self data] boolByKey:@"disabled"];
}

/** The id of the associated product model. 
 
 Returns nil if the element is not a product element.
 */
- (NSString*)productID {
    if ([self type] == ElementModelType_Product) {
        id ID = [[self data] valueForKey:@"id"];
        if ([ID respondsToSelector:@selector(stringValue)]) {
            return [ID stringValue];
        } else {
            return ID;
        }
       
    } else if ([self type] == ElementModelType_Variant) {
        id ID = [[self data] valueForKey:@"id"];
        if ([ID respondsToSelector:@selector(stringValue)]) {
            return [ID stringValue];
        } else {
            return ID;
        }
    } else {
        return nil;
    }
}
/** The widget id of the element.
 
 Returns nil if the element is not a widget element.
 */
- (NSString*)widgetID {
    // The widget id, if it is a widget...
    NSUInteger wid = [[self data] uintByKey:@"widgetID"];
    if (wid != NSUIntegerMax) {
        return [NSString stringWithFormat:@"%lu",(unsigned long)wid];
    }
    return nil;
};
/** The hit area of the element. */
- (PolygonModel*)hitAreaPolygon{
    PolygonModel* hitAreaPolygon = [[PolygonModel alloc] init];
    NSArray* vertices = [NSMutableArray array];
    NSArray* points = [[self data] arrayByKey:@"points"];
    if (points) {
        for (int i = 0; i < [points count]; i++) {
            NSArray* components = (NSArray*)[points objectAtIndex:i];
            CGPoint point = CGPointMake([[components objectAtIndex:0] floatValue], [[components lastObject] floatValue]);
            NSValue* pointValue = [NSValue valueWithCGPoint:point];
            vertices = [vertices arrayByAddingObject:pointValue];
        }
    } else {
        CGFloat x = [[self data] floatByKey:@"x"];
        CGFloat y = [[self data] floatByKey:@"y"];
        CGFloat width = [[self data] floatByKey:@"width"];
        CGFloat height = [[self data] floatByKey:@"height"];
        
        if (x != CGFLOAT_MAX && y != CGFLOAT_MAX && width != CGFLOAT_MAX && height != CGFLOAT_MAX) {
            NSValue* p1 = [NSValue valueWithCGPoint:CGPointMake(x, y)];
            NSValue* p2 = [NSValue valueWithCGPoint:CGPointMake(x+width, y)];
            NSValue* p3 = [NSValue valueWithCGPoint:CGPointMake(x+width, y+height)];
            NSValue* p4 = [NSValue valueWithCGPoint:CGPointMake(x, y+height)];
            
            vertices = [NSArray arrayWithObjects:p1,p2,p3,p4, nil];
        }
    }
    [hitAreaPolygon setPoints:[NSArray arrayWithArray:vertices]];
    return hitAreaPolygon;
};
/** Whether or not the element's style is supported. */
- (BOOL)isSupported {
    return YES;
}
/** The preselected variant ID. */
- (NSString*)selectedVariant {
    if ([self type] == ElementModelType_Product) {
        // SYN-1189
        // Update products to product group with variants.
        NSDictionary* variant = [[self data] infoByKey:@"entity"];
        if ([variant hasKey:@"id"]) {
            return [variant stringByKey:@"id"];
        }
    }
    return nil;
}
    
/** The on-page variant ID. */
- (NSString*)onPageVariantId {
//    if ([self type] == ElementModelType_Variant) {
        NSDictionary* variant = [[self data] infoByKey:@"entity"];
        if ([variant hasKey:@"id"]) {
            return [variant stringByKey:@"id"];
        }
//    }
    return nil;
}

//- (NSDictionary*)preselectedVariant {
//    NSDictionary* info = [[self.info infoByKey:@"data"] infoByKey:@"entity"];
//    if ([[NSNull null] isEqual:info]) {
//        return nil;
//    }
//    return info;
//}

@end
