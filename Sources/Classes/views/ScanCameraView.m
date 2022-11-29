//
//  ScanCameraView.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/15/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "ScanCameraView.h"
#import "Fonts.h"
#import "MasterConfiguration.h"
#import <Masonry/Masonry.h>
#import "UIViewHelper.h"

@interface ScanCameraView ()


@end

@implementation ScanCameraView

SYNTHESIZE_DI

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
        UIView* infoInterstitialView = [[UIView alloc] initWithFrame:CGRectZero];
        [infoInterstitialView setAlpha:0.0];
        [self addSubview:infoInterstitialView];
        self.infoInterstitialView = infoInterstitialView;
        
        UIView* infoBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [infoBackgroundView setBackgroundColor:[UIColor blackColor]];
        [infoBackgroundView setAlpha:0.8];
        [self.infoInterstitialView addSubview:infoBackgroundView];
        self.infoBackgroundView = infoBackgroundView;
        
        UILabel* instructions = [[UILabel alloc] init];
        instructions.numberOfLines = 0;
        instructions.text = @"Align the page between these lines.\nMake sure the page is flat and in good light.\nTap \"i\" to close";
        instructions.textAlignment = NSTextAlignmentCenter;
        instructions.textColor = [UIColor whiteColor];
        instructions.font = config.scanInterstitialLabelFont;
        [self.infoInterstitialView addSubview:instructions];
        self.instructions = instructions;
        
        UIImage* interstitialImage = [[UIImage imageNamed:@"ScanIconBook"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
        UIImageView* interstitialImageView = [[UIImageView alloc] initWithImage:interstitialImage];
        [self.infoInterstitialView addSubview:interstitialImageView];
        self.interstitialImageView = interstitialImageView;
        
        UIButton* infoButton = [[UIButton alloc] init];
        [infoButton setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
        
        [self addSubview:infoButton];
        self.infoButton = infoButton;
        
        UIImage* top = [[UIImage imageNamed:@"TopBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* topBracket = [[UIImageView alloc] initWithImage:top];
        //        [self addSubview:topBracket];
        //        self.topBracket = topBracket;
        
        UIImage* bottom = [[UIImage imageNamed:@"BottomBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* bottomBracket = [[UIImageView alloc] initWithImage:bottom];
        //        [self addSubview:bottomBracket];
        //        self.bottomBracket = bottomBracket;
        
        
        
        UIImage* topLeft = [[UIImage imageNamed:@"topLeftBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* topLeftBracket = [[UIImageView alloc] initWithImage:topLeft];
        [self addSubview:topLeftBracket];
        self.topLeftBracket = topLeftBracket;
        
        UIImage* topRight = [[UIImage imageNamed:@"topRightBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* topRightBracket = [[UIImageView alloc] initWithImage:topRight];
        [self addSubview:topRightBracket];
        self.topRightBracket = topRightBracket;
        
        UIImage* bottomLeft = [[UIImage imageNamed:@"bottomLeftBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* bottomLeftBracket = [[UIImageView alloc] initWithImage:bottomLeft];
        [self addSubview:bottomLeftBracket];
        self.bottomLeftBracket = bottomLeftBracket;
        
        UIImage* bottomRight = [[UIImage imageNamed:@"bottomRightBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
        UIImageView* bottomRightBracket = [[UIImageView alloc] initWithImage:bottomRight];
        [self addSubview:bottomRightBracket];
        self.bottomRightBracket = bottomRightBracket;
        
        NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[SyndecaConfig class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
        
        UIButton* snapPhotoButton = [[UIButton alloc] init];
        UIImage *testImage = [UIImage imageNamed:@"button.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [snapPhotoButton setImage:testImage forState:UIControlStateNormal];
        [self addSubview:snapPhotoButton];
        snapPhotoButton.alpha = 0.0;
        self.snapPhotoButton = snapPhotoButton;
        
        [self.snapPhotoButton addTarget:self action:@selector(animateButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self.snapPhotoButton addTarget:self action:@selector(animateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (IBAction)animateButtonDown:(id)sender{
    UIButton *buttonPressed = (UIButton*)sender;
    [self animateShrink:buttonPressed completion:^(BOOL success){}];
    
}

- (IBAction)animateButtonUp:(id)sender{
    UIButton *buttonPressed = (UIButton*)sender;
    [self animateBubble:buttonPressed];
    
}


- (UIButton*)getInfoButton {
    return self.infoButton;
}

- (UIButton*)getSnapPhotoButton {
    return self.snapPhotoButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    
    
    [self.infoInterstitialView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.bottom.left.right.equalTo(self);
    }];
    
    [self.infoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.bottom.left.right.equalTo(self.infoInterstitialView);
    }];
    
    [self.instructions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.infoInterstitialView.mas_centerY);
        make.width.equalTo(self.mas_width);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.interstitialImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.instructions.mas_top).offset(-12);
        make.width.height.equalTo(@52);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    
    
    
    [self.infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(38));
        make.right.equalTo(@(0)).offset(-10);
        make.width.equalTo(@(38));
        make.height.equalTo(@(38));
    }];
    //    [self.topBracket mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.instructions.mas_bottom).offset(30);
    //        make.left.equalTo(@(35));
    //        make.right.equalTo(@(-35));
    //    }];
    //    [self.bottomBracket mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self.mas_bottom).offset(-90);
    //        make.left.equalTo(@(35));
    //        make.right.equalTo(@(-35));
    //    }];
    
    [self.topLeftBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoButton.mas_bottom).offset(30);
        make.width.height.equalTo(@52);
        make.left.equalTo(@12);
    }];
    [self.topRightBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoButton.mas_bottom).offset(30);
        make.width.height.equalTo(@52);
        make.right.equalTo(@0).offset(-12);
    }];
    
    int bottomOffset = -72;
    if (@available(iOS 8.0, *)) {
        if(IS_IPHONE_X){
            bottomOffset = bottomOffset - 32;
        }
    } else {
        // Fallback on earlier versions
    }
    [self.bottomLeftBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(bottomOffset);
        make.width.height.equalTo(@52);
        make.left.equalTo(@12);
    }];
    [self.bottomRightBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(bottomOffset);
        make.width.height.equalTo(@52);
        make.right.equalTo(@0).offset(-12);
    }];
    
    [self.snapPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomRightBracket.mas_bottom);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(64));
        make.height.equalTo(@(64));
    }];
    
}

-(void)makeViewsTransparent{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoButton.alpha = 0.0;
        self.instructions.alpha = 0.0;
        self.topLeftBracket.alpha = 0.0;
        self.topRightBracket.alpha = 0.0;
        self.bottomLeftBracket.alpha = 0.0;
        self.bottomRightBracket.alpha = 0.0;
        self.infoInterstitialView.alpha = 0.0;
    });
}

-(void)makePhotoButtonShow{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.snapPhotoButton.alpha = 1.0;
    });
}

-(void)makeViewsShow{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoButton.alpha = 1.0;
        self.instructions.alpha = 1.0;
        self.topLeftBracket.alpha = 1.0;
        self.topRightBracket.alpha = 1.0;
        self.bottomLeftBracket.alpha = 1.0;
        self.bottomRightBracket.alpha = 1.0;
    });
    
    //not necessary, but this should be set to 0
    //     self.infoInterstitialView.alpha = 0.0;
}

-(void)resetViewToNormal{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoButton.alpha = 1.0;
        self.instructions.alpha = 1.0;
        self.snapPhotoButton.alpha = 0.0;
        self.topLeftBracket.alpha = 1.0;
        self.topRightBracket.alpha = 1.0;
        self.bottomLeftBracket.alpha = 1.0;
        self.bottomRightBracket.alpha = 1.0;
        self.infoInterstitialView.alpha = 0.0;
    });
}


-(void)didSelectInfo{
    
    if(self.infoInterstitialView.alpha > 0.0){
        [UIView animateWithDuration:0.3/1.5 animations:^{
            self.infoInterstitialView.alpha = 0.0;
        } completion:^(BOOL finished){
        }];
    } else{
        [UIView animateWithDuration:0.3/1.5 animations:^{
            self.infoInterstitialView.alpha = 0.9;
        } completion:^(BOOL finished){
        }];
    }
    
}


-(void)animateShrink:(UIView*)view completion:(void (^)(BOOL success))completionBlock{
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    } completion:^(BOOL finished){
        if (completionBlock != nil) completionBlock(true);
    }];
}
-(void)animateBubble:(UIView*)view{
    
    
    [UIView animateWithDuration:0.3/2.5 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/3 animations:^{
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                view.transform = CGAffineTransformIdentity;
                
            }];
        }];
    }];
    
}

@end
