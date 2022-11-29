//
//  PageThumbCollectionViewController.h
//  Pods
//
//  Created by Schell Scivally on 4/12/16.
//
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>
#import <SyndecaSDK/PageModel.h>

/** The PagThumbCollectionViewController is used by the TOCController to display thumbnails of
 pages in a two dimensional grid.
 */
@interface PageThumbCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout> {
    NSArray* _pageModels;
}

/** The object to delegate page selections to. */
@property (readwrite) id<ItemSelectionDelegate> delegate;

/** Sets the pages to display. */
- (void)setPageModels:(NSArray*)pageModels;

/** Scrolls to and highlights the cell that displays the given PageModel. */
- (void)highlightPageWithModel:(PageModel*)pageModel;

@end
