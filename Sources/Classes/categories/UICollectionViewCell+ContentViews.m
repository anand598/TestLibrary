//
//  UICollectionViewCell+UILabelContent.m
//  Pods
//
//  Created by Schell Scivally on 4/13/16.
//
//

#import "UICollectionViewCell+ContentViews.h"
#import "Fonts.h"
#import "Icons.h"
#import <Masonry/Masonry.h>
#import "UIImage+animatedGIF.h"
#import "UIImage+SyndecaSDK.h"

@implementation UICollectionViewCell (ContentViews)

- (UILabel*)contentViewLabelWithIdentifier:(NSString*)identifier {
    NSUInteger hash = [identifier hash];
    UILabel* label = [self.contentView viewWithTag:hash];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = hash;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@(0));
            make.width.and.height.equalTo(self.contentView);
        }];
    }
    return label;
}

- (UIImageView*)contentViewImageViewWithIdentifier:(NSString*)identifier {
    NSUInteger hash = [identifier hash];
    UIImageView* imageView = [self viewWithTag:hash];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.tag = hash;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.cornerRadius = 0;
        [self.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@(0));
            make.width.and.height.equalTo(self.contentView);
        }];
    }
    return imageView;
}

- (UIButton*)contentViewButtonWithIdentifier:(NSString*)identifier {
    NSUInteger hash = [identifier hash];
    UIButton* button = [self viewWithTag:hash];
    if (!button) {
        button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.tag = hash;
        button.contentMode = UIViewContentModeScaleAspectFit;
        button.layer.cornerRadius = 0;
        [self.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.equalTo(@(0));
            make.width.and.height.equalTo(self.contentView);
        }];
    }
    return button;
}


- (UIActivityIndicatorView*)contentViewActivityIndicatorWithIdentifier:(NSString*)identifier {
    NSUInteger hash = [identifier hash];
    UIActivityIndicatorView* indicatorView = [self viewWithTag:hash];
    if (!indicatorView) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.tag = hash;
        [self.contentView addSubview:indicatorView];
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.and.height.equalTo(@(40));
        }];
    }
    return indicatorView;
}

//- (UIImageView*)contentViewActivityImageIndicatorWithIdentifier:(NSString*)identifier {
//    NSUInteger hash = [identifier hash];
//    UIImageView* indicatorView = [self viewWithTag:hash];
//    if (!indicatorView) {
//        indicatorView = [[UIImageView alloc] init];
//        indicatorView.tag = hash;
//        [self.contentView addSubview:indicatorView];
//        NSURL *url = [UIImage SDKURLNamed:@"loader_Y_gif_alpha"];
//        UIImage* imageGif = [UIImage animatedImageWithAnimatedGIFURL:url];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            indicatorView.image = imageGif;
//        });
//        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.contentView);
//            make.width.and.height.equalTo(@(40));
//        }];
//    } else {
//        NSURL *url = [UIImage SDKURLNamed:@"loader_Y_gif_alpha"];
//        UIImage* imageGif = [UIImage animatedImageWithAnimatedGIFURL:url];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            indicatorView.image = imageGif;
//        });
//    }
//    return indicatorView;
//}


- (UIView*)contentViewWithIdentifier:(NSString*)identifier {
    return [self.contentView viewWithTag:[identifier hash]];
}

- (void)setupContentViewOfSearchResultWithTitleLabelId:(NSString *)titleLabelId andImageViewId:(NSString *)imageViewId andActivityIndicatorId:(NSString *)indicatorId andSubtitleLabelId:(NSString *)subtitleLabelId andPriceId:(NSString *)priceId andSaleId:(NSString *)saleId andHeartViewId:(NSString *)heartViewId{
    
    UILabel* priceLabel = [self contentViewLabelWithIdentifier:priceId];
    [priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.bottom.equalTo(self.contentView.mas_bottom);
//        make.width.equalTo(@(0));
        make.height.equalTo(@(20));
    }];
    [priceLabel setFont:[Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium]];
    [priceLabel setTextAlignment:NSTextAlignmentLeft];

    
    UILabel* saleLabel = [self contentViewLabelWithIdentifier:saleId];
    [saleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceLabel.mas_right).offset(6);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.equalTo(@80);
        make.height.equalTo(@(20));
    }];
    [saleLabel setFont:[Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium]];
    [saleLabel setTextAlignment:NSTextAlignmentLeft];

    
    UILabel* subtitleLabel = [self contentViewLabelWithIdentifier:subtitleLabelId];
    [subtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.bottom.equalTo(priceLabel.mas_top);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(@(32));
    }];
    subtitleLabel.numberOfLines = 0;
    [subtitleLabel setFont:[Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium]];
    [subtitleLabel setTextColor:[UIColor colorWithRed:(180.0/255.0) green:(180.0/255.0) blue:(180.0/255.0) alpha:1.0]];
    [subtitleLabel setTextAlignment:NSTextAlignmentLeft];
    

    UILabel* titleLabel = [self contentViewLabelWithIdentifier:titleLabelId];
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
//        make.top.equalTo(subtitleLabel.mas_bottom);
        make.bottom.equalTo(subtitleLabel.mas_top);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(@(16));
    }];
    [titleLabel setFont:[Fonts fontType:FontTypeNormal withSize:FontSizeMedium]];
    [titleLabel setTextColor:[UIColor colorWithRed:(25.0/255.0) green:(25.0/255.0) blue:(25.0/255.0) alpha:1.0]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    UIImageView* imageView = [self contentViewImageViewWithIdentifier:imageViewId];
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@(1));
        make.width.equalTo(self.contentView).offset(-1);
        make.bottom.equalTo(titleLabel.mas_top).offset(-1);
    }];
    
    UIButton* heartView = [self contentViewButtonWithIdentifier:heartViewId];
    heartView.contentMode = UIViewContentModeScaleAspectFit;
    [heartView setBackgroundImage:[Icons sharedIcons].heartIconEmptyImage() forState:UIControlStateNormal];
    [heartView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imageView.mas_right).offset(-5);
        make.top.equalTo(imageView.mas_top).offset(15);
        make.width.equalTo(@24);
        make.height.equalTo(@(24));
    }];
    [self contentViewActivityIndicatorWithIdentifier:indicatorId];
    
    
}
- (void)setupContentViewOfImageWithLabelId:(NSString *)labelId andImageViewId:(NSString *)imageViewId andActivityIndicator:(NSString *)indicatorId {
    UILabel* label = [self contentViewLabelWithIdentifier:labelId];
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(@(20));
    }];
    UIImageView* imageView = [self contentViewImageViewWithIdentifier:imageViewId];
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@(1));
        make.width.equalTo(self.contentView).offset(-1);
        make.bottom.equalTo(label.mas_top).offset(-1);
    }];
    [self contentViewActivityIndicatorWithIdentifier:indicatorId];
}

@end
