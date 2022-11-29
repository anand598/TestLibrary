//
//  VerticalProductItemView.m
//  Pods
//
//  Created by Rijul Gupta on 6/29/17.
//
//

#import "VerticalProductItemView.h"
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

@implementation VerticalProductItemView
static Class __verticalProductItemViewClass = nil;
+ (Class)DIClass {
    if (!__verticalProductItemViewClass) {
        __verticalProductItemViewClass = [VerticalProductItemView class];
    }
    return __verticalProductItemViewClass;
}

+ (void)setDIClass:(Class)c {
    if ([c isSubclassOfClass:[VerticalProductItemView class]]) {
        __verticalProductItemViewClass = c;
    } else {
        [NSException raise:@"Class is not a subclass of VerticalProductItemView" format:@""];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
        UIImageView* thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:thumbView];
        self.thumbView = thumbView;

        UIButton* heartView = [[UIButton alloc] initWithFrame:CGRectZero];
        [heartView setImage:[Icons sharedIcons].heartIconEmptyImage() forState:UIControlStateNormal];
        [self addSubview:heartView];
        self.heartView = heartView;
        self.heartView.alpha = 0.0;
        
        
        UILabel* titleView = [[UILabel alloc] initWithFrame:self.bounds];
        titleView.numberOfLines = 2;
        titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        titleView.textColor = [UIColor darkGrayColor];
        titleView.text = @"title";
        titleView.font = [Fonts fontType:FontTypeNormalLight
                                withSize:FontSizeMedium];
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
        subtitleView.numberOfLines = 2;
        subtitleView.textColor = [UIColor lightGrayColor];
        subtitleView.text = @"subtitle";
        subtitleView.font = [Fonts fontType:FontTypeNormalLight
                                   withSize:FontSizeMedium];
       // subtitleView.font = [UIFont fontWithName:[subtitleView.font fontName] size:([subtitleView.font pointSize])];
        [self addSubview:subtitleView];
        self.subtitleView = subtitleView;
        
        UILabel* priceView = [[UILabel alloc] initWithFrame:self.bounds];
        priceView.numberOfLines = 1;
        priceView.textColor = [UIColor blackColor];
        priceView.text = @"";
        priceView.font = [Fonts fontType:FontTypeNormal
                                withSize:FontSizeMedium];
        priceView.font = [UIFont fontWithName:[priceView.font fontName] size:([priceView.font pointSize])];
        [self addSubview:priceView];
        self.priceView = priceView;
        
        
        UILabel* priceViewStrike = [[UILabel alloc] initWithFrame:self.bounds];
        priceViewStrike.numberOfLines = 1;
        priceViewStrike.textColor = [UIColor blackColor];
        priceViewStrike.text = @"";
        priceViewStrike.font = [Fonts fontType:FontTypeNormal
                                withSize:FontSizeMedium];
        priceViewStrike.font = [UIFont fontWithName:[priceViewStrike.font fontName] size:([priceViewStrike.font pointSize])];
        [self addSubview:priceViewStrike];
        self.priceViewStrike = priceViewStrike;
        
        UILabel* saleView = [[UILabel alloc] initWithFrame:self.bounds];
        saleView.numberOfLines = 1;
        saleView.textColor = [UIColor redColor];
        saleView.text = @"";
        saleView.font = [Fonts fontType:FontTypeNormal
                               withSize:FontSizeMedium];
        saleView.font = [UIFont fontWithName:[saleView.font fontName] size:([saleView.font pointSize])];
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
        // one layout for ipad and iphone
                [self.thumbView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@0);
                    make.left.equalTo(self.mas_left).offset(2);
                    make.right.equalTo(self.mas_right).offset(-2);
                    make.bottom.equalTo(self.subtitleView.mas_top).offset(-5);
                }];
                [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.mas_left).offset(2);
                    make.right.equalTo(self.mas_right).offset(-2);
                    make.top.equalTo(self.thumbView.mas_bottom);
                    make.bottom.equalTo(self.priceView.mas_top);
                }];
                [self.priceView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.lessThanOrEqualTo(self.saleView.mas_left);
                    make.bottom.equalTo(self.mas_bottom).offset(-2);
                    make.height.equalTo(@12);
                }];
    
                [self.priceViewStrike mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.lessThanOrEqualTo(self.saleView.mas_left);
                    make.bottom.equalTo(self.mas_bottom).offset(-2);
                    make.height.equalTo(@12);
                }];
    
                [self.saleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.priceView.mas_right).offset(5);
                    make.right.lessThanOrEqualTo(self.mas_right).offset(-2);
                    make.bottom.equalTo(self.mas_bottom).offset(-2);
                    make.height.equalTo(@12);
                }];
                [self.subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.titleView.mas_left);
                    make.right.equalTo(self.mas_right).offset(-5);
                    make.bottom.lessThanOrEqualTo(self.priceView.mas_top).offset(-5);
                    make.height.greaterThanOrEqualTo(@32);
                }];
    
}

- (void)reset {
    [self.thumbView cancelImageLoad];
    self.thumbView.image = nil;
    self.subtitleView.textColor = [UIColor blackColor];
    self.subtitleView.text = nil;
    self.titleView.numberOfLines = 2;
    self.titleView.textColor = [UIColor blackColor];
    self.titleView.text = nil;
    self.saleView.textColor = [UIColor redColor];
    self.saleView.text = nil;
    self.priceView.textColor = [UIColor blackColor];
    self.priceView.text = nil;
    self.priceViewStrike.textColor = [UIColor blackColor];
    self.priceViewStrike.text = nil;
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
    
    
    self.isSale = false;
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
                 if(self.removePanelItemDelegate){
                     [self.removePanelItemDelegate removePanelItemForProductWithId:productModel];
                 }
             }
             completed:^{}];
            });
        
    }
    
    NSString* k = productModel.brand;
    if (productModel && productModel.brand && ![productModel.brand isEqualToString:@"(null)"]) {
        self.titleView.htmlText = productModel.brand;
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
//            self.priceView.attributedText = [[NSAttributedString alloc]
//                                             initWithString:[f stringFromNumber:n]
//                                             attributes:nil];
            self.priceView.attributedText = nil;
            self.priceView.text = nil;
//            self.priceView.text = @"TEST";
            self.priceViewStrike.alpha = 0.0;
            self.priceView.alpha = 1.0;
            self.priceView.attributedText = [[NSAttributedString alloc]
                                             initWithString:[f stringFromNumber:n]
                                             attributes:@{}];
//            self.priceView.htmlText = [f stringFromNumber:n];
            
            
        }
    }
    
    if (productModel && ((productModel.priceSaleFloat < productModel.priceFloat && productModel.priceSaleFloat != 0.0) || productModel.isSale)) {
        // This product is on sale!
        self.isSale = true;
        NSNumber* n = [NSNumber numberWithFloat:productModel.priceSaleFloat];
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        f.locale = [NLS nls].locale;
        f.numberStyle = NSNumberFormatterCurrencyStyle;
        self.saleView.text = [@"Now " stringByAppendingString:[f stringFromNumber:n]];
        
        self.priceViewStrike.alpha = 1.0;
        self.priceView.alpha = 0.0;
        self.priceViewStrike.attributedText = [[NSAttributedString alloc]
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
