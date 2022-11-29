//
//  ItemSelection.h
//  Nordstrom
//
//  Created by Schell Scivally on 1/14/16.
//  Copyright © 2016 Schell Scivally. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ItemSelectionTypeIssue,
    ItemSelectionTypePage,
    ItemSelectionTypeProduct,
    ItemSelectionTypeVariant,
    ItemSelectionTypeVideo,
    ItemSelectionTypeLink,
    ItemSelectionTypeUnknown
} ItemSelectionType;

/** An object reflecting a user's selection. */
@interface ItemSelection : NSObject

/** The type of the selection. */
@property (readwrite) ItemSelectionType selectionType;
/** The model of the selection (IssueModel, PageModel, ProductGroupModel, VariantModel, ElementLinkModel or VideoModel). */
@property (readwrite) id selection;

@end
