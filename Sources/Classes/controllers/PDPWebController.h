//
//  PDPWebController.h
//  Pods
//
//  Created by Rijul Gupta on 5/18/17.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SyndecaSDK/WebNavigationControllerDelegate.h>
#import <SyndecaSDK/ProductGroupModel.h>

/** A WebViewController is a simple controller that allows web browsing,
 starting at a specific URL. It displays an UIActivityIndicatorView as
 the right bar button item and sets it animating whenever loading begins.
 */
@interface PDPWebController : UIViewController <WKNavigationDelegate>

@property (readwrite) UIActivityIndicatorView* indicatorView;
- (id)initWithRequest:(NSURLRequest*)request;

- (void)reloadDetailViewWithProductGroupModel:(ProductGroupModel*)productGroupModel andVariantIndex:(NSUInteger)ndx;



/** A delegate to handle navigation for the ScanShopViewController */
@property (readwrite) id<WebNavigationControllerDelegate> delegate;


@property (readwrite) ProductGroupModel* productGroupModel;
/*This property allows you to override the hmaburger menu button and show a back button. Only set this to true if you are presenting this as a view controller from some other view in your app heirarchy**/
@property (readwrite) BOOL shouldShowBackButton;

@property (readwrite) BOOL isFromSearchController;
@property (readwrite) CGFloat elementTableViewWidth;
@property (readwrite) BOOL isVertical;

@end
