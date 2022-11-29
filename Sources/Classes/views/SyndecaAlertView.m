//
//  SyndecaAlertView.m
//  CocoaViewer
//
//  Created by Schell Scivally on 6/21/11.
//  Copyright 2011 Synapse Group International, Inc. All rights reserved.
//

#import "SyndecaAlertView.h"
#import "NSString+SyndecaAccessibility.h"
#import "NLS.h"


@implementation SyndecaAlertView

#pragma mark - Specific Alerts

+ (SyndecaAlertView*)alertNoConnectivity {
    NSString* title = [[NLS nls] stringFor:@"global.offlineErrorTitle"
                                   default:@"No connectivity"];
    NSString* msg = [[NLS nls] stringFor:@"global.offlineError" default:@"Without an internet connection this app has limited functionality."];
    NSString* cncl = [[NLS nls] stringFor:@"global.cancelButtonText" default:@"Okay"];
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:nil];
    alert.accessibilityLabel = [NSString offlineAlertLabel];
    return alert;
}

+ (SyndecaAlertView*)alertDownloadFailed {
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:@"Download Failed" 
                                message:@"The data could not be downloaded because of a connection error. Please verify you are online and try again." 
                               delegate:self 
                      cancelButtonTitle:@"Okay" 
                      otherButtonTitles:@"Retry",nil];
    
    alert.accessibilityLabel = [NSString failedDownloadAlertLabel];
    return alert;
}

#pragma mark - App Updates


+ (SyndecaAlertView*)alertOptionalAppUpdate {
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:@"New Version!" 
                                                     message:@"There is a newer version available. Would you like to upgrade now?" 
                                                    delegate:self 
                                           cancelButtonTitle:@"No Thanks" 
                                           otherButtonTitles:@"Yes!",nil];
    return alert;   
}

+ (SyndecaAlertView*)alertOptionalAppUpdateWithNewFeatures {
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:@"New Version!" 
                                                     message:@"You need to upgrade to the latest version to view new catalogs. Would you like to upgrade now?" 
                                                    delegate:self 
                                           cancelButtonTitle:@"Remind Me" 
                                           otherButtonTitles:@"Yes!",nil];
    return alert;
}

+ (SyndecaAlertView*)alertRequiredAppUpdate {
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:@"Oops!" 
                                                     message:@"We're sorry, you need to update your app." 
                                                    delegate:self 
                                           cancelButtonTitle:@"Update Now!" 
                                           otherButtonTitles:nil];
    return alert;
}

+ (SyndecaAlertView*)alertUpdatedDataWithMessage:(NSString *)message {
    SyndecaAlertView* alert = [[SyndecaAlertView alloc] initWithTitle:@"Updated data is being downloaded."
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Okay"
                                                    otherButtonTitles:nil];
    return alert;
}


@end
