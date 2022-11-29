//
//  ScanShopViewController.h
//  Syndeca iOS Apps
//
//  Created by Kurt Guenther.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/DependencyInjection.h>
#import <SyndecaSDK/WebNavigationControllerDelegate.h>
#import <SyndecaSDK/ScanShopResultsDelegate.h>
#import <SyndecaSDK/ScanInterstitialView.h>
#import <SyndecaSDK/ScanCameraView.h>
#import <SyndecaSDK/ScanShopRecognitionDelegate.h>
#import <SyndecaSDK/ScanShopSelectionDelegate.h>

#import <CraftARCloudImageRecognitionSDK/CraftARProtocols.h>

extern NSString* const ScanShopHasDismissedInterstitalKey;

/** The ScanShopViewController controls data and views associated with Syndeca's Scan+Shop
 feature. Please see the *Scan+Shop* integration guide for setup info.
 We conform to the CraftARSDK Protocol in order to leverage the image recognition framework
 We conform to the ZBarDelegate to get responses from the zbar image scanner

 If a QR code is found within the buffer stream, it validates that the QR code contains a real URL. If a URL is found, a WebViewController is instantiated with this URL and presented directly on the top of the stack.
 */
@interface ScanShopViewController : UIViewController <WebNavigationControllerDelegate,
DependencyInjection,
ScanShopResultsDelegate, SearchProtocol, ScanShopRecognitionDelegate>
/** A URL to a page describing the Scan+Shop feature. */
@property (readwrite) NSURL* infoURL;
/** The view to show the user the first time they use the Scan+Shop
 feature. */
@property (readwrite) ScanInterstitialView* interstitialView;
/** The view the user sees while scanning/finding a match. */
@property (readwrite) ScanCameraView* cameraInputView;
/** The delegate to call out to when the user picks a result. */
@property (readwrite) id<ScanShopResultsDelegate> delegate;
@property (readwrite) id<ScanShopRecognitionDelegate> recognitionDelegate;
@property (readwrite) id<ScanShopSelectionDelegate> selectionDelegate;

/** Determines whether or not user selected results of type product, video and external links
 should be handled automatically.

 When set to YES, the ScanShopResultsDelegate object will not
 be notified of selections of these result types, and will only be notified of selections
 of pages and internal links (links to pages within a publication).

 When set to NO the default behavior is not to automatically handle any selections.

 The default value is YES.
 */
@property (readwrite) BOOL automaticallyHandleProductVideoAndExternalLinks;
/** The preview view where we show the video feed. Updated with the image pixel buffer*/
@property (readwrite) UIView *_preview;
/**A boolean we set to determine when the controller should search for barcodes. We set this to false while we're searching*/
@property (readwrite) BOOL shouldScanForBarcodes;
/**A button that will manually call the CraftAR and ZBar search*/
@property (nonatomic, strong)UIButton *snapPhotoButton;
/**Protects session from starting again after receiving results*/
@property (readwrite) BOOL hasShownResult;

- (UIView*)stopContinuousScanView;

/** Sets the value returned by scanShopAPIKey. */
+ (void)setScanShopAPIKey:(NSString*)key;
/** Sets the value returned by scanShopAPISecret. */
+ (void)setScanShopAPISecret:(NSString*)secret;

/**Sets the values retuned by the scanShopAPITarget */
+ (void)setScanShopToken:(NSString *)token;

/**Action added to the snap-to-scan button after an image isn't recognized. Manually calls the CraftARCloudImageRecognition search and ZBar search */
- (IBAction)snapPhotoToSearch:(id)sender;

/** Loads a publication page scan result into a view controller and returns that view controller. Exposed for testing. */
- (UIViewController*)loadScanResultsForCatalog:(NSString*)catalogID pageNumber:(NSInteger)pageNumber;
/** Loads a barcode scan result into a view controller and returns that view controller. Exposed for testing. */
- (UIViewController*)loadScanResultsForBarcode:(NSString*)barcode;
/** The Scan+Shop api key. You can set this value class-wide with setScanShopAPIKey.
 Before being set this value is nil, which effectively disables the Scan+Shop feature.*/
- (NSString*)scanShopAPIKey;
/** The Scan+Shop api secret. You can set this value class-wide with setScanShopAPISecret.
 Before being set this value is nil, which effectively disables the Scan+Shop feature.*/
- (NSString*)scanShopAPISecret;
/** The Scan+Shop api token*/
- (NSString*)scanShopToken;

- (void)restart;

@end
