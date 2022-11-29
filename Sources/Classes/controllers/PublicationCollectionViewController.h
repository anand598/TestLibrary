//
//  PublicationCollectionViewController.h
//  Pods
//
//  Created by Schell Scivally on 4/12/16.
//
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>

/** Displays a list of Syndeca publications. */
@interface PublicationCollectionViewController : UICollectionViewController {
    NSArray* _publications;
}

/** A boolean flag that is set to true only if there is one catalog, and we have already pushed to the pages view. This ensures that we don't continually push to the pages view, if the user selects the home tab again.*/
@property (readwrite) BOOL hasShownPages;
/** Skips publications and automatically pushes into to the first publication regardless of hasShownPages */
@property (readwrite) BOOL skipToFeaturedPublication;
/** Font to use for publication titles */
@property (readwrite) UIFont* titleFont;

/** The object to delegate user selections to. */
@property (readwrite) id<ItemSelectionDelegate> itemSelectionDelegate;

/** Provide the controller with its list of publications. 
 This should be an array of IssueModel. 
 */
- (void)setPublications:(NSArray*)issues;

-(void)setVerticalLayout;
@property (readwrite) BOOL isVertical;



@end
