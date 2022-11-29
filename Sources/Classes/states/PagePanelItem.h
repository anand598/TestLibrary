//
//  PagePanelItem.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/2/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/HasID.h>

typedef enum {
    PagePanelItemType_Any,
    PagePanelItemType_Product,
    PagePanelItemType_Variant,
    PagePanelItemType_LinkExternal,
    PagePanelItemType_LinkInternal,
    PagePanelItemType_HTMLVideo,
    PagePanelItemType_Video
} PagePanelItemType;

@interface PagePanelItem : NSObject

@property (readwrite) PagePanelItemType itemType;
@property (readwrite) id<HasID> item;

@end
