//
//  AddToBagCart.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/17/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ShoppingCart.h"
#import "NSDictionary+AsObjectOrNil.h"
#import "NSDictionary+Serialization.h"
#import "ProductGroupModel.h"
#import "FIRTrackProxy.h"

@interface ShoppingCart ()

@property (readwrite) BOOL shouldPersist;
@property (readwrite) NSString* saveName;
@property (readwrite, copy) ReadCartItem reader;

@end


@implementation ShoppingCart

- (id)init {
    self = [super init];
    if (self) {
        self.shouldPersist = NO;
        self.saveName = @"default";
        self.reader = ^id<HasID>(NSDictionary *info) {
            return [[[ProductGroupModel DIClass] alloc] initWithInfo:info];
        };
        self.itemStore = @{};
        [self readItemStore];
        self.isWishlist = NO;
    }
    return self;
}

- (id)initWithSaveName:(NSString*)saveName andReader:(ReadCartItem)reader {
    self = [self init];
    if (self) {
        self.shouldPersist = YES;
        self.saveName = saveName;
        self.reader = reader;
        self.itemStore = @{};
        [self readItemStore];
    }
    return self;
}

#pragma mark - Working with items

- (void)updateItem:(id<HasID>)item toQuantity:(NSUInteger)quantity {
    if ([self quantityOfItem:item]) {
        [self removeItem:item];
    }
    if (quantity) {
        [self addItem:item inQuantity:quantity];
    }
}

- (void)addItem:(id<HasID>)item inQuantity:(NSUInteger)quantity {
    if (!item) {
        return;
    }
    
    NSMutableDictionary* itemStore = [NSMutableDictionary dictionaryWithDictionary:self.itemStore];
    
    NSUInteger currentQuantity = [self quantityOfItemWithID:item.ID];
    
    if (quantity == 0) {
        [itemStore removeObjectForKey:item.ID];
    } else {
        [itemStore setObject:@{@"item":item,@"quantity":@(quantity+currentQuantity)}
                      forKey:item.ID];
    }
    
    self.itemStore = [NSDictionary dictionaryWithDictionary:itemStore];
    if (self.shouldPersist) {
        [self saveItemStore];
    }
    self.runningTotal = [self totalQuantityOfItems];
}

- (void)addItemsFromCart:(ShoppingCart *)cart {
    for (id<HasID> item in [cart array]) {
        [self addItem:item inQuantity:1];
    }
}

- (void)removeItem:(id<HasID>)item {
    if (!item) {
        return;
    }
    
    NSMutableDictionary* itemStore = [NSMutableDictionary dictionaryWithDictionary:self.itemStore];
    [itemStore removeObjectForKey:item.ID];
    self.itemStore = [NSDictionary dictionaryWithDictionary:itemStore];
    [self saveItemStore];
    self.runningTotal = [self totalQuantityOfItems];
}

- (NSString*)idString {
    NSArray* ids = [self.itemStore allKeys];
    return [ids componentsJoinedByString:@","];
}

- (NSUInteger)quantityOfItem:(id<HasID>)item {
    return [self quantityOfItemWithID:item.ID];
}

- (NSUInteger)quantityOfItemWithID:(NSString*)ID {
    NSDictionary* storedItem = [self.itemStore objectForKey:ID];
    if (storedItem) {
        return [storedItem uintByKey:@"quantity"];
    }
    return 0;
}

- (id<HasID>)itemWithID:(NSString*)ID {
    NSDictionary* storedItem = [self.itemStore objectForKey:ID];
    if (storedItem) {
        return [storedItem objectForKey:@"item"];
    }
    return nil;
}

- (NSUInteger)totalQuantityOfItems {
    NSUInteger total = 0;
    for (NSString* ID in [self.itemStore allKeys]) {
        total += [self quantityOfItemWithID:ID];
    }
    return total;
}

- (CGFloat)totalPrice {
    CGFloat price = 0;
    for (ProductGroupModel* pm in [self array]) {
        if ([pm respondsToSelector:@selector(priceFloat)]) {
            CGFloat pricef = 0;
            if (pm.priceSaleFloat && pm.priceSaleFloat < pm.priceFloat) {
                pricef = pm.priceSaleFloat;
            } else {
                pricef = pm.priceFloat;
            }
            price += [self quantityOfItem:pm] * pricef;
        }
    }
    return price;
}

- (NSArray*)array {
    NSArray* items = @[];
    for (NSDictionary* storedItem in [self.itemStore allValues]) {
        id item = [storedItem valueForKey:@"item"];
        items = [items arrayByAddingObject:item];
    }
    return items;
}

#pragma mark - Persistence

- (void)saveItemStore {
    NSArray* cart = @[];
    for (NSString* key in [self.itemStore allKeys]) {
        id<HasID> item = [self itemWithID:key];
        NSUInteger quantity = [self quantityOfItem:item];
        
        NSDictionary* itemStore = @{ @"quantity" : @(quantity),
                                     @"item" : [NSDictionary prunedValueOf:item.info]};
        cart = [cart arrayByAddingObject:itemStore];
    }
    NSURL* URL = [self cartFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
        if (!deleted) {
            NSLog(@"%s could not delete shopping cart from disk.",__func__);
        }
    }
    BOOL written = [cart writeToURL:URL atomically:YES];
    if (!written) {
        NSLog(@"%s could not write shopping cart to disk.",__func__);
    }
}

- (void)readItemStore {
    self.itemStore = @{};
    
    NSURL* URL = [self cartFile];
    NSArray* cart = [NSArray arrayWithContentsOfURL:URL];
    if (cart) {
        BOOL previousPersistance = self.shouldPersist;
        self.shouldPersist = NO;
        for (NSDictionary* itemStore in cart) {
            NSNumber* quant = [itemStore numberByKey:@"quantity"];
            NSDictionary* itemInfo = [itemStore infoByKey:@"item"];
            id<HasID> item = self.reader(itemInfo);
            if (item) {
                [self addItem:item inQuantity:[quant integerValue]];
            }
        }
        self.shouldPersist = previousPersistance;
    }
}

- (BOOL)itemIsFavorited:(id<HasID>)item {
    
    [self readItemStore];
    NSMutableDictionary* itemStore = [NSMutableDictionary dictionaryWithDictionary:self.itemStore];
    NSObject* object = [itemStore objectForKey:item.ID];
    
    if(object){
        return true;
    }
    return false;
}

- (NSURL*)cartFile {
    NSURL* file = [[NSFileManager defaultManager]
                   URLForDirectory:NSDocumentDirectory
                   inDomain:NSUserDomainMask
                   appropriateForURL:nil
                   create:YES
                   error:nil];
    file = [file URLByAppendingPathComponent:self.saveName];
    file = [file URLByAppendingPathExtension:@"plist"];
    return file;
}

@end
