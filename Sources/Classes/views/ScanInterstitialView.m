//
//  ScanInterstitialView.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/11/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "ScanInterstitialView.h"
#import "Fonts.h"
#import "UIImage+SyndecaSDK.h"
#import <Masonry/Masonry.h>
#import "UIViewHelper.h"

@interface ScanInterstitialView ()

@end

@implementation ScanInterstitialView

SYNTHESIZE_DI

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:200.f/255.f green:202.f/255.f blue:201.f/255.f alpha:1.0];
        
        UIImage* img = [UIImage imageNamed:@"ScanInterstitial"];
        if(IS_IPAD == false || img == nil){
            UIImage* img2 = [UIImage imageNamed:@"ScanInterstitial-iPhone"];
            if (img2 != nil){
                img = img2;
            }
        }
        
        UIImageView* scanGirl = [[UIImageView alloc] initWithImage:img];
        [self addSubview:scanGirl];
        self.backgroundImageView = scanGirl;
        
        
        scanGirl.contentMode = UIViewContentModeScaleAspectFill;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 1136:
                    //                    printf("iPhone 5 or 5S or 5C");
                    break;
                    
                case 1334:
                    //                    printf("iPhone 6/6S/7/8");
                    break;
                    
                case 1920:
                    //                    printf("iPhone 6+/6S+/7+/8+");
                    break;
                
                case 2208:
                    //                    printf("iPhone 6+/6S+/7+/8+");
                    break;
                case 2436:
                    scanGirl.contentMode = UIViewContentModeScaleAspectFill;
                    //                    printf("iPhone X, XS");
                    break;
                    
                case 2688:
                    scanGirl.contentMode = UIViewContentModeScaleAspectFill;
                    //                    printf("iPhone XS Max");
                    break;
                    
                case 1792:
                    scanGirl.contentMode = UIViewContentModeScaleAspectFill;
                    //                    printf("iPhone XR");
                    break;
                    
                default:
                    //                    printf("Unknown");
                    break;
            }
        }
        
        [scanGirl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.mas_width);
            make.centerX.equalTo(self.mas_centerX);
            make.height.equalTo(self.mas_height);
            make.bottom.equalTo(self.mas_bottom);
            
        }];
        
        self.topLabel = [[UILabel alloc] init];
        self.topLabel.text = @"SCAN. SHOP.  BUY.  LOVE.";
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        self.topLabel.textColor = [UIColor colorWithWhite:49.f/255.f alpha:1.f];
        self.topLabel.font = [Fonts fontType:FontTypeNormal
                               withSize:FontSizeBig];
        self.topLabel.backgroundColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.f];
        [self addSubview:self.topLabel];
        
        
        self.instructionsLabel = [[UILabel alloc] init];
        self.instructionsLabel.textColor = [UIColor blackColor];
        self.instructionsLabel.numberOfLines = 0;
        self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
        NSString* firstPart = @""; //This was used in the first mockup.  Will remove if it does not come back (think it might)
        NSString* secondPart = @"Use your mobile device to scan any page from\nour catalog and buy right from this app.";
        
        NSMutableAttributedString* instructions = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", firstPart, secondPart]];
        [instructions addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.5f]} range:NSMakeRange(0, instructions.length)];
        [instructions addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12.5f]} range:NSMakeRange(firstPart.length, secondPart.length)];
        self.instructionsLabel.attributedText = instructions;
        
        [self addSubview:self.instructionsLabel];
        
        
        self.goButton = [[UIButton alloc] init];
        self.goButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.goButton.backgroundColor = [UIColor clearColor];
        self.goButton.layer.borderWidth = 2.f;
        self.goButton.layer.cornerRadius = 25.f;
        [self.goButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.goButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self addSubview:self.goButton];

        [self.goButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.top.equalTo(self.mas_top).offset(20);
            make.bottom.equalTo(self.mas_bottom).offset(20);
        }];
    }
    
    return self;
}

@end
