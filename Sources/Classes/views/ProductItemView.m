//
//  PolyProductItemVIew.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/15/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ProductItemView.h"
#import "SwatchModel.h"
#import "MasterConfiguration.h"
#import "ElementLinkModel.h"
#import "Icons.h"
#import "UIImageView+Offline.h"
#import "NLS.h"
#import "UIViewHelper.h"
#import "Fonts.h"
#import "UILabel+HTML.h"
#import "VariantModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation ProductItemView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
        
        UIView* thumbHolderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:thumbHolderView];
        self.thumbHolderView = thumbHolderView;
        
        UIImageView* thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [self.thumbHolderView addSubview:thumbView];
        self.thumbView = thumbView;
        
        
        UIButton* heartView = [[UIButton alloc] initWithFrame:CGRectZero];
        [heartView setImage:[Icons sharedIcons].heartIconEmptyImage() forState:UIControlStateNormal];
        [self addSubview:heartView];
        self.heartView = heartView;
        self.heartView.alpha = 0.0;
        
        UILabel* heartLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        heartLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        heartLabel.textColor = [UIColor colorWithWhite:0.48 alpha:1.0];
        heartLabel.text = [NSString stringWithFormat:@"%d", rand()%100 + 25];
        heartLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:heartLabel];
        self.heartLabel = heartLabel;
        self.heartLabel.alpha = 0;
        
        UILabel* titleView = [[UILabel alloc] initWithFrame:self.bounds];
        titleView.numberOfLines = 2;
        titleView.adjustsFontSizeToFitWidth = NO;
        titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        titleView.textColor = [UIColor darkGrayColor];
        titleView.text = @"title";
        titleView.font = [Fonts fontType:FontTypeNormalLight
                                withSize:FontSizeBig];
        [self addSubview:titleView];
        self.titleView = titleView;
        
        UILabel* moreInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        moreInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        moreInfoLabel.textColor = [UIColor colorWithWhite:0.44 alpha:1.0];
        moreInfoLabel.textAlignment = NSTextAlignmentCenter;
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        moreInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:@"More Info" attributes:underlineAttribute];
        moreInfoLabel.alpha = 0.0;
        [self addSubview:moreInfoLabel];
        self.moreInfoLabel = moreInfoLabel;
        
        
        UILabel* subtitleView = [[UILabel alloc] initWithFrame:self.bounds];
        if (IS_IPAD) {
            subtitleView.numberOfLines = 0;
        } else {
            subtitleView.numberOfLines = 2;
        }
        subtitleView.textColor = [UIColor lightGrayColor];
        subtitleView.text = @"subtitle";
        subtitleView.font = [Fonts fontType:FontTypeNormalLight
                                   withSize:FontSizeMedium];
        subtitleView.font = [UIFont fontWithName:[subtitleView.font fontName] size:([subtitleView.font pointSize] + 2)];
        [self addSubview:subtitleView];
        self.subtitleView = subtitleView;
        
        UILabel* priceView = [[UILabel alloc] initWithFrame:self.bounds];
        priceView.numberOfLines = 1;
        priceView.textColor = [UIColor blackColor];
        priceView.text = @"";
        priceView.font = [Fonts fontType:FontTypeNormal
                                withSize:FontSizeMedium];
        priceView.font = [UIFont fontWithName:[priceView.font fontName] size:([priceView.font pointSize] + 4)];
        [self addSubview:priceView];
        self.priceView = priceView;
        
        UILabel* saleView = [[UILabel alloc] initWithFrame:self.bounds];
        saleView.numberOfLines = 1;
        saleView.textColor = [UIColor redColor];
        saleView.text = @"";
        saleView.font = [Fonts fontType:FontTypeNormal
                               withSize:FontSizeMedium];
        saleView.font = [UIFont fontWithName:[saleView.font fontName] size:([saleView.font pointSize] + 4)];
        [self addSubview:saleView];
        self.saleView = saleView;
        
        
#pragma mark shopButton
        UIButton* shopButton = [[UIButton alloc] initWithFrame:CGRectZero];
        //        [shopButton addTarget:self action:@selector(didTapShopButton:) forControlEvents:UIControlEventTouchUpInside];
        shopButton.userInteractionEnabled = YES;
        shopButton.accessibilityLabel = @"shop-now";
        shopButton.layer.masksToBounds = YES;
        shopButton.layer.cornerRadius = 1;
        shopButton.backgroundColor = [MasterConfiguration choose:config.productDetailShopNowButtonColor or:[UIColor colorWithRed:1.0 green:0.92 blue:0.98 alpha:1]];
        shopButton.backgroundColor = [UIColor colorWithRed:0.08 green:0.04 blue:0.04 alpha:1.0];
        shopButton.titleLabel.textColor = [UIColor whiteColor];
        shopButton.titleLabel.font = [Fonts fontType:FontTypeNormalLight
                                            withSize:FontSizeLarge];
        
        
        [shopButton setTitle:[MasterConfiguration
                              choose:config.productDetailShopNowText or:@"shop now"]
                    forState:UIControlStateNormal];
        
        [self addSubview:shopButton];
        //        self.shopButton = shopButton;
        
#pragma mark coverView
        UIView* coverView = [[UIView alloc] initWithFrame:CGRectZero];
        coverView.userInteractionEnabled = YES;
        coverView.accessibilityLabel = @"cover-view";
        coverView.backgroundColor = [UIColor colorWithWhite:0.28 alpha:1.0];
        coverView.alpha = 0.0;
        [self addSubview:coverView];
        self.coverView = coverView;
        
        //Hook up data to our view
        @weakify(self)
        [RACObserve(self, panelItem) subscribeNext:^(PagePanelItem* panelItem) {
            @strongify(self)
            if (!panelItem) {
                // Treat it like a nil product.
                return [self configureForProduct:nil];
            }
            
            switch (panelItem.itemType) {
                case PagePanelItemType_Product: {
                    [self configureForProduct:(ProductGroupModel*)panelItem.item];
                    break;
                }
                    
                case PagePanelItemType_LinkExternal:
                case PagePanelItemType_LinkInternal: {
                    [self configureForLink:(ElementLinkModel*)panelItem.item];
                    break;
                }
                    
                case PagePanelItemType_Variant: {
                    VariantModel* variant = (VariantModel*)panelItem.item;
                    ProductGroupModel* pm = [variant productRepresentation];
                    [self configureForProduct:pm];
//                    [self configureForProduct:(ProductGroupModel*)panelItem.item];
                    break;
                }
                    
                case PagePanelItemType_Video: {
                    VideoModel* video = (VideoModel*)panelItem.item;
                    [self configureForVideo:video];
                    break;
                }
                    
                default:
                    NSLog(@"unhandled panel item configuration");
                    break;
            }
            
        }];
        
        [self makeLayout];
    }
    return self;
}

- (void)makeLayout {
    // Make our autolayout constraints.
    if (IS_IPHONE) {
        int topPadding = 12;
        int leftPadding = 5;
        int width = 112;
        [self.thumbHolderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.width.equalTo(@(width));
            make.centerY.equalTo(self.mas_centerY);
            switch (self.panelItem.itemType) {
                case PagePanelItemType_LinkExternal:
                case PagePanelItemType_LinkInternal: {
                    make.height.equalTo(@50);
                    break;
                }
                    
                default: {
                    make.height.equalTo(self.mas_height).offset(topPadding*-2);
                    break;
                }
            }
        }];
        
        int height = 0;
        if(self.thumbView.image){
            height = round( width * (self.thumbView.image.size.height/self.thumbView.image.size.width) );
        } else {
            NSLog(@"Thumb image is nill");
        }
        [self.thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.width.equalTo(self.thumbHolderView.mas_width);
            make.top.equalTo(self.thumbHolderView.mas_top).offset(topPadding);
            switch (self.panelItem.itemType) {
                case PagePanelItemType_LinkExternal:{
                    make.height.equalTo(@50);
                    break;
                }
                case PagePanelItemType_LinkInternal: {
                    make.height.equalTo(@50);
                    break;
                }
                    
                default: {
//                    make.height.equalTo(self.thumbHolderView.mas_height);
                    make.height.equalTo(@(height));
                    make.height.lessThanOrEqualTo(self.thumbHolderView.mas_height);
                    break;
                }
            }
        }];
        
        
        self.thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [self.heartView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(12);
            make.right.equalTo(self.mas_right).offset(-12);
            make.width.equalTo(@28);
            make.height.equalTo(@28);
        }];
        [self.heartLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.heartView.mas_left);
            make.right.equalTo(self.heartView.mas_right);
            make.height.greaterThanOrEqualTo(@18);
            make.top.equalTo(self.heartView.mas_bottom);
        }];
        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.thumbHolderView.mas_top).offset(12);
            make.left.equalTo(self.thumbHolderView.mas_right).offset(5);
            make.right.equalTo(self.mas_right).offset(-40);
            make.width.equalTo(@120);
            make.height.greaterThanOrEqualTo(@12);
//            make.height.lessThanOrEqualTo(@82);
        }];
        [self.subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleView.mas_bottom).offset(4);
            make.height.greaterThanOrEqualTo(@(2 * 12));
            make.left.equalTo(self.titleView.mas_left);
            make.width.equalTo(self.titleView.mas_width);
        }];
        [self.priceView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subtitleView.mas_bottom).offset(8);
            make.left.equalTo(self.subtitleView.mas_left);
            make.right.lessThanOrEqualTo(self.mas_right).offset(5);
            make.height.equalTo(@16);
        }];
        [self.saleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceView.mas_top);
            make.left.equalTo(self.priceView.mas_right).offset(5);
            make.right.lessThanOrEqualTo(self.mas_right).offset(5);
            make.height.equalTo(@16);
        }];
        [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.right.top.bottom.equalTo(self);
        }];
//        
//        [self.moreInfoLabel sizeToFit];
//        [self.moreInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make){
//            make.right.equalTo(self.mas_right).offset(-8);
//            make.top.equalTo(self.mas_centerY).offset(8);
//        }];
        
        
        //        [self.shopButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.priceView.mas_left);
        //            make.width.equalTo(@110);
        //            make.bottom.equalTo(self.mas_bottom).offset(-28);
        //            make.height.equalTo(@40);
        //        }];
        //
    } else {
        // iPad autolayout
        switch (self.panelItem.itemType) {
            case PagePanelItemType_LinkInternal:
            case PagePanelItemType_LinkExternal: {
                if (self.thumbView.image) {
                    [self.thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.left.equalTo(@10);
                        make.right.equalTo(self.mas_right).offset(-10);
                        make.bottom.equalTo(self.mas_bottom).offset(-57);
                    }];
                } else {
                    [self.thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.left.width.height.equalTo(@0);
                    }];
                }
                [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.thumbView.mas_bottom).offset(5);
                    make.left.equalTo(@12);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.height.greaterThanOrEqualTo(@12);
                }];
                [self.subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.top.equalTo(self.titleView.mas_bottom).offset(5);
                    make.height.greaterThanOrEqualTo(@40);
                }];
                [self.priceView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.width.height.equalTo(@0);
                    make.left.equalTo(self.titleView.mas_left);
                }];
                [self.saleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.width.height.equalTo(@0);
                    make.left.equalTo(self.titleView.mas_left);
                }];
                break;
            }
                
            default: {
                [self.thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.and.left.equalTo(@5);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.bottom.equalTo(self.subtitleView.mas_top).offset(-5);
                }];
                [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@12);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.top.equalTo(self.thumbView.mas_bottom);
                    make.bottom.equalTo(self.priceView.mas_top);
                }];
                [self.priceView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.lessThanOrEqualTo(self.saleView.mas_left);
                    make.bottom.equalTo(self.mas_bottom).offset(-5);
                    make.height.equalTo(@18);
                }];
                [self.saleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.priceView.mas_right).offset(5);
                    make.right.lessThanOrEqualTo(self.mas_right).offset(-5);
                    make.bottom.equalTo(self.mas_bottom).offset(-5);
                    make.height.equalTo(@12);
                }];
                [self.subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.bottom.lessThanOrEqualTo(self.priceView.mas_top).offset(-5);
                    make.height.greaterThanOrEqualTo(@40);
                }];
                break;
            }
        }
        
    }
}

- (void)reset {
        [self.thumbView cancelImageLoad];
        self.thumbView.image = nil;
        self.subtitleView.textColor = [UIColor blackColor];
        self.subtitleView.text = nil;
        self.titleView.adjustsFontSizeToFitWidth = NO;
        self.titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleView.textColor = [UIColor blackColor];
        self.titleView.text = nil;
        self.saleView.textColor = [UIColor redColor];
        self.saleView.text = nil;
        self.priceView.textColor = [UIColor blackColor];
        self.priceView.text = nil;
        self.swatchItems = nil;
}

- (void)configureForLink:(ElementLinkModel*)element {
    [self reset];
    if (element.linkType == LinkTypeExternal) {
        self.subtitleView.htmlText = element.linkTitle;
        self.thumbView.image = [Icons sharedIcons].globeIconImage();
    } else {
        self.subtitleView.textColor = [UIColor colorWithRed:0.2 green:0.49 blue:0.72 alpha:1];
        self.subtitleView.attributedText = [[NSAttributedString alloc]
                                            initWithString:element.linkTitle
                                            attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
    }
    self.thumbView.tintColor = [UIColor darkGrayColor];
    if (element.linkDescription) {
        self.titleView.numberOfLines = 3;
        self.titleView.htmlText = element.linkDescription;
        self.accessibilityLabel = element.linkDescription;
    }
    
    [self makeLayout];
    [self setNeedsLayout];
    [self updateConstraints];
}

- (void)configureForVideo:(VideoModel*)videoModel {
    [self reset];
    
    NSURL* imageURL = [videoModel thumbURL];
    [[self.thumbView loadImageWithURL:imageURL] subscribeNext:^(id x) {}];
        self.priceView.text = [videoModel title];
    
    [self makeLayout];
    [self setNeedsLayout];
    [self updateConstraints];
}

- (void)configureForProduct:(ProductGroupModel*)productModel {
    [self reset];
    
    NSURL* previewURL = nil;
    if (productModel && productModel.previewURL) {
        previewURL = productModel.previewURL;
    } else if (productModel && productModel.entities && [productModel.entities count]) {
        previewURL = ((ProductEntityModel*)[productModel.entities firstObject]).previewURL;
    } else if (productModel && !previewURL) {
        for (NSURL* url in productModel.altImageURLs) {
            if (url) {
                previewURL = url;
                break;
            }
        }
    }
    
    if (previewURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self.thumbView loadImageWithURL:previewURL]
             subscribeNext:^(id _){} error:^(NSError *error) {
                 NSLog(@"Error loading product item image!");
             }
             completed:^{
                 NSLog(@"Loaded product item image!");
                 [self makeLayout];
                 [self setNeedsLayout];
                 [self updateConstraints];
             }];
        });
        
    }
    
    NSString* k = productModel.brand;
    if (productModel && productModel.brand && ![productModel.brand isEqualToString:@"(null)"]) {
        self.titleView.htmlText = productModel.brand;
//        self.titleView.lineBreakMode = NSLineBreakByTruncatingTail;
//        self.titleView.text = productModel.brand;
    }
    if (productModel && productModel.title && ![productModel.title isEqualToString:@"(null)"]) {
        self.subtitleView.htmlText = productModel.title;
        self.accessibilityLabel = productModel.title;
    }
    
    if (productModel) {
        NSNumber* n = [NSNumber numberWithFloat:productModel.priceFloat];
        if (n.floatValue == 0) {
            self.priceView.htmlText = productModel.price;
        } else {
            NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
            f.locale = [NLS nls].locale;
            f.numberStyle = NSNumberFormatterCurrencyStyle;
            
//            self.priceView.htmlText = [f stringFromNumber:n];
            self.priceView.attributedText = nil;
            self.priceView.text = nil;
            self.priceView.attributedText = [[NSAttributedString alloc]
                                             initWithString:@"TEST"
                                             attributes:nil];
        }
    }
    
    if (productModel && productModel.priceSaleFloat < productModel.priceFloat && productModel.priceSaleFloat != 0.0 || productModel.isSale) {
        // This product is on sale!
        NSNumber* n = [NSNumber numberWithFloat:productModel.priceSaleFloat];
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        f.locale = [NLS nls].locale;
        f.numberStyle = NSNumberFormatterCurrencyStyle;
        self.saleView.text = [@"Now " stringByAppendingString:[f stringFromNumber:n]];
        
        self.priceView.attributedText = [[NSAttributedString alloc]
                                         initWithString:productModel.originalPrice
                                         attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
//        self.priceView.attributedText = [[NSAttributedString alloc]
//                                         initWithString:self.priceView.text
//                                         attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    }
    BOOL hasURL = productModel.url1 || productModel.url1_shareurl;
    if (productModel.catalog.extensions.shoppingEnabled && hasURL) {
        self.shopButton.hidden = NO;
        //self.pinterestButton.hidden = NO;
    } else {
        self.shopButton.hidden = YES;
        //self.pinterestButton.hidden = YES;
    }
    
    
//    if(productModel.isSale){
//        saleLabel.alpha = 1.0;
//        NSString* html = @"";
//        if (product.originalPrice) {
//            html = [NSString stringWithFormat:@"<font color=\"#7f7f7f\"><b><del>%@</del></b></font>",product.originalPrice];
//        }
//        saleLabel.attributedText = [saleLabel attributedStringFromHtml:html];
//        //        priceLabel.attributedText = [priceLabel strikeOutAttributedStringFromString:product.originalPrice];
//    }
    
    
    
    //    BOOL hasURL = productModel.url1 || productModel.url1_shareurl;
    //    if (productModel.catalog.extensions.shoppingEnabled && hasURL) {
    //        self.shopButton.hidden = NO;
    //        //self.pinterestButton.hidden = NO;
    //    } else {
    //        self.shopButton.hidden = YES;
    //        //self.pinterestButton.hidden = YES;
    //    }
    
    
    
    self.swatchItems = productModel.swatches;
    [self.swatchCollection reloadData];
    
    [self makeLayout];
    [self setNeedsLayout];
    [self updateConstraints];
}

#pragma mark - Cell View Interaction Animations

-(void)animateViewSelected{
    [UIView animateWithDuration:0.05 animations:^{
        self.coverView.alpha = 0.28;
    }];
}

-(void)animateViewUnSelected{
    [UIView animateWithDuration:0.05 animations:^{
        self.coverView.alpha = 0.0;
    }];
}
@end
