//
//  ItemSelectionDelegate.h
//  Nordstrom
//
//  Created by Schell Scivally on 1/14/16.
//  Copyright © 2016 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ItemSelection.h>


/** A very generic protocol for things that proxy a user selection event to a delegate. */
@protocol ItemSelectionDelegate <NSObject>

/** Called when an item container recognizes a user selection event. */
- (void)itemContainer:(id)container didMakeSelection:(ItemSelection*)selection;
- (void)itemContainer:(id)container didPressShopNowSelection:(ItemSelection*)selection;

@end
