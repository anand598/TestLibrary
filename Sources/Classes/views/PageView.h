//
//  PageView.h
//  Pods
//
//  Created by Schell Scivally on 1/22/16.
//
//

#import <SyndecaSDK/PageModel.h>
#import <SyndecaSDK/ElementSelectionDelegate.h>
#import <SyndecaSDK/VideoView.h>
#import <UIKit/UIKit.h>

/** A type to specify how to align the page. This
 helps with laying out spreads. */
typedef enum {
    PageAlignmentNone,
    PageAlignmentLeft,
    PageAlignmentRight,
    PageAlignmentTop,
    PageAlignmentBottom
} PageAlignment;

/** A view for showing Syndeca publication pages, configured with a page model. */
@interface PageView : UIView <ItemSelectionDelegate> {
    PageModel* _pageModel;
    PageAlignment _pageAlignment;
}

#pragma mark - Properties
/** Configures the page with a new model. */
@property (readwrite) PageModel* pageModel;
/** The alignment of this page. */
@property (readwrite) PageAlignment pageAlignment;
/** A delegate object to call back to when the user selects an on-page element. */
@property (readwrite) id<ElementSelectionDelegate> delegate;

/** This page's image view. */
@property (readwrite) UIImageView* imageView;

#pragma mark - Getters
/** Find the VideoView associated with the given ElementModel, or return nil. */
- (VideoView*)videoViewForElement:(ElementModel*)element;

#pragma mark - Managing the page
/** Resets the page canceling all ongoing operations and flushing videos, etc. */
- (void)reset;
/** Toggles playing of the on page video associated with the given element. */
- (void)toggleVideoForElement:(ElementModel*)element;
/** Pauses all videos. */
- (void)pauseAllVideos;

@end
