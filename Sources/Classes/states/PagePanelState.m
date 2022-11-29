//
//  ProductPanelState.m
//  Syndeca iOS SDK
//
//  Created by Schell on 6/6/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "PagePanelState.h"
#import "SyndecaSDK.h"
#import "PagePanelItem.h"

@implementation PagePanelState

- (id)init {
    self = [super init];
    if (self) {
        self.sectionHeaderModels = @[];
        self.itemsBySection = @[];
    }
    return self;
}

- (PagePanelItem*)itemWithIndexPath:(NSIndexPath*)indexPath {
    NSArray* section = [self.itemsBySection objectAtIndex:indexPath.section];
    return [section objectAtIndex:indexPath.row];
}

- (NSIndexPath*)indexPathForItemType:(PagePanelItemType)type withId:(NSString*)ID {
    for (int i = 0; i < [self.itemsBySection count]; i++) {
        NSArray* section = [self.itemsBySection objectAtIndex:i];
        for (int j = 0; j < [section count]; j++) {
            PagePanelItem* pitem = [section objectAtIndex:j];
            NSLog(@"%s Looking for %@ - %@",__func__,ID,pitem.item.ID);
            if ((pitem.itemType == type || type == PagePanelItemType_Any)
                && [pitem.item.ID isEqualToString:ID]) {
                return [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    return nil;
}

- (NSIndexPath*)indexPathForItemWithId:(NSString *)ID {
    return [self indexPathForItemType:PagePanelItemType_Any withId:ID];
}

-(void)removeItemAtIndex:(NSIndexPath*)indexPath{
    NSMutableArray* savedItems = [[NSMutableArray alloc] initWithArray:self.itemsBySection];
    NSMutableArray* sectionArr = [[NSMutableArray alloc] initWithArray:[self.itemsBySection objectAtIndex:indexPath.section]];
    [sectionArr removeObjectAtIndex:indexPath.row];
    [savedItems replaceObjectAtIndex:indexPath.section withObject:[sectionArr copy]];
    
    self.itemsBySection = [savedItems copy];
    
}
- (PagePanelState*)pagePanelStateByAppending:(PagePanelState*)ps {
    PagePanelState* nps = [[PagePanelState alloc] init];
    nps.sectionHeaderModels = [self.sectionHeaderModels
                               arrayByAddingObjectsFromArray:ps.sectionHeaderModels];
    nps.itemsBySection = [self.itemsBySection arrayByAddingObjectsFromArray:ps.itemsBySection];
    return nps;
}

@end
