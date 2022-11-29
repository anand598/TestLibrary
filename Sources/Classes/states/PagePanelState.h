//
//  ProductPanelState.h
//  Syndeca iOS SDK
//
//  Created by Schell on 6/6/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/PagePanelItem.h>

@interface PagePanelState : NSObject

/** This is an array of arrays of PagePanelItem. */
@property (readwrite) NSArray<NSArray<PagePanelItem*>*> *itemsBySection;
@property (readwrite) NSArray<NSString*> *sectionHeaderModels;
                                              
- (NSIndexPath*)indexPathForItemType:(PagePanelItemType)type withId:(NSString*)ID;
- (NSIndexPath*)indexPathForItemWithId:(NSString*)ID;
- (PagePanelItem*)itemWithIndexPath:(NSIndexPath*)indexPath;

/** Allows the remove of an item as a specific index path. Used to remove items with image urls to lead to errors*/
-(void)removeItemAtIndex:(NSIndexPath*)indexPath;

/** ProductPanelState is a monoid where mappend fmaps mappend to both its 
 arrays. */
- (PagePanelState*)pagePanelStateByAppending:(PagePanelState*)ps;


@end
