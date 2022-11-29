//
//  SyndecaAlertView.h
//  CocoaViewer
//
//  Created by Schell Scivally on 6/21/11.
//  Copyright 2011 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaRequest.h>

/** An alert view that holds service operation state info. */
@interface SyndecaAlertView : UIAlertView

@property (readwrite) SyndecaRequest* request;

#pragma mark - Specific Alerts

/** Another alert for offline errors. */
+ (SyndecaAlertView*)alertNoConnectivity;
/** An alert for failed downloads. */
+ (SyndecaAlertView*)alertDownloadFailed;

/** A notification that updates have been downloaded. */
+ (SyndecaAlertView*)alertUpdatedDataWithMessage:(NSString*)message;
/** A notification of optional app updates. */
+ (SyndecaAlertView*)alertOptionalAppUpdate;
/** Another notification of optional app updates. */
+ (SyndecaAlertView*)alertOptionalAppUpdateWithNewFeatures;
/** An alert that forces a user into the app update screen on iTunes. */
+ (SyndecaAlertView*)alertRequiredAppUpdate;

@end
