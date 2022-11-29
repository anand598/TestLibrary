//
//  ScanInterstitialView.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/11/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/DependencyInjection.h>

@interface ScanInterstitialView : UIView <DependencyInjection>

/** Holds a background image view */
@property (readwrite) UIImageView* backgroundImageView;

/** A button that allows a user to move to the camera view */
@property (readwrite) UIButton* goButton;

/** This label provides instructions on how to use the camera to recognize an image */
@property (readwrite) UILabel* instructionsLabel;

/** This label allows you to place promotional text at the top of the view */
@property (readwrite) UILabel* topLabel;

@end
