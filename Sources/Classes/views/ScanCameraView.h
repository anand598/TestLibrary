//
//  ScanCameraView.h
//  Nordstrom
//
//  Created by Schell Scivally on 12/15/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/DependencyInjection.h>


@interface ScanCameraView : UIView <DependencyInjection>

@property (readwrite) UIButton* infoButton;
@property (readwrite) UIImageView* topBracket;
@property (readwrite) UIImageView* bottomBracket;

@property (readwrite) UIImageView* bottomLeftBracket;
@property (readwrite) UIImageView* bottomRightBracket;
@property (readwrite) UIImageView* topLeftBracket;
@property (readwrite) UIImageView* topRightBracket;

@property (readwrite) UIButton* snapPhotoButton;

@property (readwrite) UIView* infoInterstitialView;
@property (readwrite) UIView* infoBackgroundView;
@property (readwrite) UIImageView* interstitialImageView;
@property (readwrite) UILabel* instructions;

- (UIButton*)getInfoButton;
- (UIButton*)getSnapPhotoButton;


-(void)makeViewsTransparent;
-(void)makePhotoButtonShow;
-(void)makeViewsShow;
-(void)resetViewToNormal;

-(void)didSelectInfo;
@end
