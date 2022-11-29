//
//  VariantModel.m
//  Justice
//
//  Created by Schell Scivally on 6/26/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "VariantModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation VariantModel

- (NSString*)ID {
    return self.variantId;
}

- (NSDictionary*)info {
    return [self.productGroup info];
}

- (ProductGroupModel*)productRepresentation {
    
    for (ProductEntityModel *entity in self.productGroup.entities) {
        if([entity.ID isEqualToString:self.variantId]){
            return entity.parent;
        }
    }
    return self.productGroup;
//    return [self.productGroup.entities.rac_sequence
//            foldLeftWithStart:nil
//            reduce:^ProductGroupModel*(ProductGroupModel* acc, ProductGroupModel* value) {
//                if ([value.ID isEqualToString:self.variantId]) {
//                    return value;
//                }
//
//                return value;
//            }];
}

- (NSUInteger)indexInProductGroup {
    return [self.productGroup.entities indexOfObject:[self productRepresentation]];
}

@end
