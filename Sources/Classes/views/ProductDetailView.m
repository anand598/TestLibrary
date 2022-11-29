//
//  ProductDetailView.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/20/12.
//  Copyright (c) 2012 Schell Scivally. All rights reserved.
//

#import "ProductDetailView.h"
#import "SyndecaSDK.h"
#import "UIViewHelper.h"
#import "ShareProxy.h"
#import "FIRTrackProxy.h"
#import "MasterConfiguration.h"
#import "NLS.h"
#import "UICollectionViewCell+ContentViews.h"
#import "Icons.h"
#import "Fonts.h"
#import "UIImage+Resize.h"
#import "UILabel+HTML.h"
#import "UIPageControl+Design.h"
#import "SizeModel.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
//#import <DTCoreText/DTCoreText.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ProductDetailView ()
@property (readwrite) NSLayoutConstraint* sizeCVHeight;
@end

@implementation ProductDetailView

SYNTHESIZE_DI

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.elementTableViewWidth = 0;
        self.tabBarHeightAdjustment = 0;
        
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
#pragma mark - UI Setup
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
#pragma mark scrollView
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        [self.scrollView addSubview:self.contentView];
        
#pragma mark previewImages
        UICollectionViewLayout *layout = [self previewImagesLayoutForSize:frame.size];
        UICollectionView *previewImages = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        previewImages.backgroundColor = [UIColor clearColor];
        previewImages.pagingEnabled = YES;
        previewImages.delegate = self;
        previewImages.dataSource = self;
        previewImages.showsHorizontalScrollIndicator = NO;
        [previewImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"image"];
        [self.contentView addSubview:previewImages];
        self.previewImages = previewImages;
        
#pragma mark previewPageControl
        UIPageControl* previewPageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        previewPageControl.currentPageIndicatorTintColor = [UIColor clearColor];
        previewPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self.contentView addSubview:previewPageControl];
        
        self.previewPageControl = previewPageControl;
        self.previewPageControl.hidesForSinglePage = YES;
        
        
#pragma mark titleLabel
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [Fonts fontType:FontTypeNormalLight
                                 withSize:FontSizeJumbo];
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
#pragma mark swatchLabel
        UILabel* swatchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        swatchLabel.font = [Fonts fontType:FontTypeNormal
                                  withSize:FontSizeMedium];
        swatchLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        swatchLabel.textColor = [UIColor colorWithWhite:0.66 alpha:1.0];
        [self.contentView addSubview:swatchLabel];
        self.swatchLabel = swatchLabel;
        
#pragma mark swatchImages
        UICollectionView* swatchImages = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self swatchImagesLayout]];
        swatchImages.backgroundColor = [UIColor clearColor];
        swatchImages.contentInset = UIEdgeInsetsMake(0, 2, 0, 2);
        swatchImages.allowsMultipleSelection = NO;
        swatchImages.delegate = self;
        swatchImages.dataSource = self;
        [swatchImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"swatch"];
        [self.contentView addSubview:swatchImages];
        self.swatchImages = swatchImages;
        
        
#pragma mark priceLabel
        UILabel* priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        priceLabel.font = [Fonts fontType:FontTypeCurrency
                                 withSize:FontSizeMedium];
        priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        [self.contentView addSubview:priceLabel];
        self.priceLabel = priceLabel;
        
#pragma mark saleLabel
        UILabel* saleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        saleLabel.font = [Fonts fontType:FontTypeCurrency
                                withSize:FontSizeMedium];
        saleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        saleLabel.textColor = [UIColor redColor];
        [self.contentView addSubview:saleLabel];
        self.saleLabel = saleLabel;
        
#pragma mark auxPriceLabel
        UILabel* auxPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        auxPriceLabel.textColor = [UIColor redColor];
        auxPriceLabel.font = [Fonts fontType:FontTypeSubtext
                                    withSize:FontSizeMedium];
        auxPriceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        [self.contentView addSubview:auxPriceLabel];
        self.auxPriceLabel = auxPriceLabel;
        
#pragma mark subtitleLabel
        UILabel* subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.font = [UIFont fontWithName:[Fonts fontType:FontTypeNormal withSize:FontSizeMedium].fontName size:14.0];
        subtitleLabel.textColor = [UIColor colorWithWhite:0.40 alpha:1.0];
        [self.contentView addSubview:subtitleLabel];
        subtitleLabel.numberOfLines = 0;
        self.subtitleLabel = subtitleLabel;
        
#pragma mark errorLabel
        self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.errorLabel.font = [Fonts fontType:FontTypeNormal
                                      withSize:FontSizeMedium];
        self.errorLabel.textColor = [UIColor colorWithRed:0.6 green:0.15 blue:0 alpha:1];
        [self.contentView addSubview:self.errorLabel];
        
#pragma mark shopButton
        UIButton* shopButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [shopButton addTarget:self action:@selector(didTapShopButton:) forControlEvents:UIControlEventTouchUpInside];
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
        
        [self.contentView addSubview:shopButton];
        self.shopButton = shopButton;
        
#pragma mark sizesBar
        UIView* sizesBar = [[UIView alloc] initWithFrame:CGRectZero];
        sizesBar.backgroundColor = [UIColor colorWithRed:(194.0f/255.0f) green:(194.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:sizesBar];
        self.sizesBar = sizesBar;
        
#pragma mark sizesHolder
        UIView* sizesHolder = [[UIView alloc] initWithFrame:CGRectZero];
        sizesHolder.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:sizesHolder];
        self.sizesHolder = sizesHolder;
        
#pragma mark collectionViewSize
        UICollectionView* collectionViewSize = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self collectionViewSizeLayout]];
        collectionViewSize.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        collectionViewSize.contentInset = UIEdgeInsetsMake(16, 20, 16, 20);
        collectionViewSize.allowsMultipleSelection = NO;
        collectionViewSize.delegate = self;
        collectionViewSize.dataSource = self;
        [collectionViewSize registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"size"];
        [self.contentView addSubview:collectionViewSize];
        self.collectionViewSize = collectionViewSize;
        NSLayoutConstraint* heightC = [NSLayoutConstraint constraintWithItem:self.collectionViewSize attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0];
        self.sizeCVHeight = heightC;
        
#pragma mark descriptionLabel
        UILabel* descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.font = [Fonts fontType:FontTypeNormal
                                       withSize:FontSizeMedium];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textColor = [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:descriptionLabel];
        self.descriptionLabel = descriptionLabel;
        
#pragma mark descriptionTitleLabel
        UILabel* descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionTitleLabel.font = [Fonts fontType:FontTypeNormalLight
                                            withSize:FontSizeBig];
        descriptionTitleLabel.numberOfLines = 0;
        descriptionTitleLabel.textColor = [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:descriptionTitleLabel];
        self.descriptionTitleLabel = descriptionTitleLabel;
        
#pragma mark featuresLabel
        UILabel* featuresLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        featuresLabel.font = [Fonts fontType:FontTypeNormal
                                    withSize:FontSizeMedium];
        featuresLabel.numberOfLines = 0;
        featuresLabel.textColor = [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:featuresLabel];
        self.featuresLabel = featuresLabel;
        
#pragma mark topBar
        UIView* topBar = [[UIView alloc] initWithFrame:CGRectZero];
        topBar.backgroundColor =  [UIColor colorWithRed:(194.0f/255.0f) green:(194.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:topBar];
        self.topBar = topBar;
        
#pragma mark midBar
        UIView* midBar = [[UIView alloc] initWithFrame:CGRectZero];
        midBar.backgroundColor =  [UIColor colorWithRed:(194.0f/255.0f) green:(194.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:midBar];
        self.midBar = midBar;
        
#pragma mark detailsBar
        UIView* detailsBar = [[UIView alloc] initWithFrame:CGRectZero];
        detailsBar.backgroundColor =  [UIColor colorWithRed:(194.0f/255.0f) green:(194.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:detailsBar];
        self.detailsBar = detailsBar;
        
#pragma mark shippingBar
        UIView* shippingBar = [[UIView alloc] initWithFrame:CGRectZero];
        shippingBar.backgroundColor =  [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:shippingBar];
        self.shippingBar = shippingBar;
        
#pragma mark shippingTitleLabel
        UILabel* shippingTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shippingTitleLabel.font = [Fonts fontType:FontTypeNormalLight
                                         withSize:FontSizeBig];
        shippingTitleLabel.textColor = [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        shippingTitleLabel.numberOfLines = 0;
        [self.contentView addSubview:shippingTitleLabel];
        self.shippingTitleLabel = shippingTitleLabel;
        
#pragma mark shippingDetailLabel
        UILabel* shippingDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        shippingDetailLabel.font = [Fonts fontType:FontTypeNormal
                                          withSize:FontSizeMedium];
        shippingDetailLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(125.0f/255.0f) blue:(125.0f/255.0f) alpha:1.0];
        shippingDetailLabel.numberOfLines = 0;
        [self.contentView addSubview:shippingDetailLabel];
        self.shippingDetailLabel = shippingDetailLabel;
   
#pragma mark learnMoreLabel
        UILabel* learnMoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        learnMoreLabel.font = [Fonts fontType:FontTypeNormal
                                     withSize:FontSizeMedium];
        learnMoreLabel.textColor = [UIColor colorWithRed:(148.0f/255.0f) green:(148.0f/255.0f) blue:(148.0f/255.0f) alpha:1.0];
        learnMoreLabel.numberOfLines = 0;
        [self.contentView addSubview:learnMoreLabel];
        self.learnMoreLabel = learnMoreLabel;
        self.learnMoreLabel.alpha = 0;
        
#pragma mark btmBar
        UIView* btmBar = [[UIView alloc] initWithFrame:CGRectZero];
        btmBar.backgroundColor =  [UIColor colorWithRed:(194.0f/255.0f) green:(194.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0];
        [self.contentView addSubview:btmBar];
        self.btmBar = btmBar;
        
        
        
#pragma mark addToWishlistButton
        UIButton* addToWishlistButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [addToWishlistButton addTarget:self action:@selector(didTapAddToWishlistButton:) forControlEvents:UIControlEventTouchUpInside];
        addToWishlistButton.layer.masksToBounds = YES;
        addToWishlistButton.layer.cornerRadius = 2;
        addToWishlistButton.backgroundColor = [MasterConfiguration choose:config.productDetailShopNowButtonColor or:[UIColor colorWithRed:0.32 green:0.56 blue:0.79 alpha:1]];
        addToWishlistButton.titleLabel.textColor = [UIColor whiteColor];
        addToWishlistButton.titleLabel.font = [Fonts fontType:FontTypeNormal
                                                     withSize:FontSizeMedium];
        [addToWishlistButton setImage:[[[Icons sharedIcons].giftIconImage() imageWithSize:CGSizeMake(16, 16)]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                             forState:UIControlStateNormal];
        addToWishlistButton.imageView.tintColor = [UIColor whiteColor];
        addToWishlistButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [addToWishlistButton setTitle:[MasterConfiguration
                                       choose:config.productDetailShopNowText or:@"  add to wishlist"]
                             forState:UIControlStateNormal];
        [self.contentView addSubview:addToWishlistButton];
        self.addToWishlistButton = addToWishlistButton;
        
        
        MASAttachKeys(self.contentView,self.scrollView,self.previewImages,self.previewPageControl,self.topBar,
                      self.titleLabel,self.swatchLabel,self.swatchImages, self.midBar,
                      self.priceLabel,self.saleLabel,self.auxPriceLabel,self.subtitleLabel,self.errorLabel,
                      self.sizesBar,self.sizesHolder, self.collectionViewSize,
                      self.detailsBar,self.descriptionLabel,self.descriptionTitleLabel,self.featuresLabel,
                      self.shippingBar, self.shippingTitleLabel, self.shippingDetailLabel, self.learnMoreLabel,
                      self.btmBar,self.shopButton,self.addToWishlistButton);
    }
    return self;
}

#pragma mark - Layout

- (CGSize)sizeForPreviewImagesInsideSize:(CGSize)size {
    CGSize previewSize = CGSizeZero;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        previewSize = [UIViewHelper screenSize];
    } else {
        previewSize = size;
    }
    if (IS_IPAD && previewSize.width > previewSize.height) {
        previewSize = CGSizeMake(previewSize.width * 0.5 - self.elementTableViewWidth - 10, previewSize.height * 0.5);
    } else {
        previewSize = CGSizeMake(previewSize.width - self.elementTableViewWidth, 300);
    }
    return previewSize;
}

- (UICollectionViewLayout*)previewImagesLayoutForSize:(CGSize)size {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    CGSize previewSize = [self sizeForPreviewImagesInsideSize:size];
    layout.itemSize = previewSize;
    return layout;
}

- (UICollectionViewLayout*)collectionViewSizeLayout {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(72, 40);
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 8;
    return layout;
}



- (UICollectionViewLayout*)swatchImagesLayout {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(30, 30);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 10;
    return layout;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewImages.collectionViewLayout = [self previewImagesLayoutForSize:frame.size];
        self.swatchImages.collectionViewLayout = [self swatchImagesLayout];
        self.collectionViewSize.collectionViewLayout = [self collectionViewSizeLayout];
    });
    [self makeLayoutForSize:frame.size];
}

- (void)makeLayoutForSize:(CGSize)size {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewImages.collectionViewLayout = [self previewImagesLayoutForSize:size];
   
    CGSize previewSize = [self sizeForPreviewImagesInsideSize:size];
    CGSize contentSize = previewSize;
    contentSize.width *= [[self previewImagesItems] count];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewImages.contentSize = contentSize;
    });
    
    int titlePaddingLeft = 12;
    
    CGFloat contentRight = 0;
    if (IS_IPAD && size.width > size.height) {
        contentRight = (size.width) * 0.5 - 5 + self.elementTableViewWidth;
    } else {
        contentRight = previewSize.width;
    }
    
    NSLog(@"%s %f",__func__,contentRight);
    
    // Some shared constraints
    void (^makePriceSaleSubtitleAux)() = ^() {
        [self.subtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
            make.width.equalTo(@200);
            //            make.height.lessThanOrEqualTo(@24);
            make.left.equalTo(self.topBar.mas_left).offset(titlePaddingLeft);
        }];
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.subtitleLabel.mas_left);
            make.top.equalTo(self.subtitleLabel.mas_bottom).offset(2);
            make.width.lessThanOrEqualTo(@100);
            make.height.lessThanOrEqualTo(@25);
        }];
        [self.saleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_right).offset(5);
            make.top.equalTo(self.subtitleLabel.mas_bottom).offset(2);
            make.width.lessThanOrEqualTo(@100);
            make.height.lessThanOrEqualTo(@25);
        }];
        [self.auxPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.saleLabel.mas_left);
            make.right.lessThanOrEqualTo(@(contentRight - 100));
            make.top.equalTo(self.saleLabel.mas_bottom);
            make.height.lessThanOrEqualTo(@25);
        }];
    };
    void (^makeFeatures)() = ^() {
        [self.featuresLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.descriptionLabel.mas_left);
            make.right.equalTo(self.descriptionLabel.mas_right);
            make.top.equalTo(self.descriptionLabel.mas_bottom);
            make.height.greaterThanOrEqualTo(@15);
        }];
    };
    void (^makeShopWishlist)() = ^() {
        [self.shopButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.midBar.mas_right).offset(-10);
            make.width.equalTo(@110);
            make.bottom.equalTo(self.priceLabel.mas_bottom);
            make.height.equalTo(@40);
        }];
//                [self.addToWishlistButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.right.equalTo(@300);
//                    make.width.equalTo(@125);
//                    make.top.equalTo(@300);
//                    make.height.equalTo(@34);
//                }];
    };
    
    if (IS_IPAD && size.width > size.height) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:self.previewImages];
            [self addSubview:self.previewPageControl];
        });
        [self.previewImages mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat elementPanelWidth = self.elementTableViewWidth;
            make.top.equalTo(@70);
            make.left.equalTo(@(elementPanelWidth + 5));
            make.width.equalTo(@(previewSize.width));
            make.height.equalTo(@(previewSize.height));
        }];
        
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.previewImages.mas_right);
            make.top.equalTo(@0);
            make.right.equalTo(self.mas_right);
            //make.width.equalTo(@(contentRight));
            make.height.equalTo(self.mas_height);
        }];
        
        [self.previewPageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.previewImages);
            make.right.equalTo(self.previewImages);
            make.top.equalTo(self.previewImages.mas_bottom).offset(5);
            make.height.equalTo(@12);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@8);
            make.top.equalTo(@10);
            make.width.equalTo(@(contentRight - 5));
            make.height.greaterThanOrEqualTo(@25);
        }];
        makePriceSaleSubtitleAux();
        makeShopWishlist();
        [self.midBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceLabel.mas_bottom).offset(18);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.equalTo(@1);
        }];
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topBar.mas_left);
            make.right.equalTo(self.topBar.mas_right);
            make.top.equalTo(self.midBar.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@24);
        }];
        makeFeatures();
        [self.swatchImages mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.midBar.mas_left).offset(titlePaddingLeft);
            make.top.equalTo(self.midBar.mas_bottom).offset(12);
            make.width.equalTo(self.midBar.mas_width);
            make.height.equalTo(@40);
        }];
        [self.swatchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.swatchImages.mas_bottom).offset(5);
            make.left.equalTo(self.swatchImages.mas_left);
            make.width.greaterThanOrEqualTo(@100);
            make.height.lessThanOrEqualTo(@12);
        }];
        [self.sizesBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.greaterThanOrEqualTo(self.swatchLabel.mas_bottom).offset(12);
            make.height.equalTo(@1);
        }];
        [self.sizesHolder mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
            make.height.greaterThanOrEqualTo(@45);
        }];
        [self.collectionViewSize mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right).offset(0);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
        }];
        self.sizeCVHeight.constant = self.collectionViewSize.contentSize.height + self.collectionViewSize.contentInset.top + self.collectionViewSize.contentInset.bottom;
        [self.collectionViewSize addConstraint:self.sizeCVHeight];
        [self.detailsBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.collectionViewSize.mas_bottom);
            make.height.equalTo(@1);
        }];
        [self.descriptionTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.detailsBar.mas_bottom).offset(12);
            make.height.greaterThanOrEqualTo(@25);
        }];
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.descriptionTitleLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.top.greaterThanOrEqualTo(self.descriptionTitleLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@15);
        }];
        makeFeatures();
        [self.shippingBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.featuresLabel.mas_bottom).offset(12);
            make.height.equalTo(@1);
        }];
        [self.shippingTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.shippingBar.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@25);
        }];
        [self.shippingDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shippingTitleLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.top.greaterThanOrEqualTo(self.shippingTitleLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@15);
        }];
        [self.learnMoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shippingDetailLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.shippingDetailLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@25);
        }];
    } else {//if not in iPad landscape
        //set some global padding variables
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView addSubview:self.previewImages];
            [self.contentView addSubview:self.previewPageControl];
        });
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(self.elementTableViewWidth));
            make.top.equalTo(@(0));
            make.height.equalTo(self);
            make.width.equalTo(@(previewSize.width));
        }];
        [self.previewImages mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.left.equalTo(@0);
            make.width.equalTo(@(previewSize.width));
            make.height.equalTo(@(previewSize.height));
        }];
        [self.previewPageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.previewImages);
            make.top.equalTo(self.previewImages.mas_bottom).offset(5);
            make.height.equalTo(@12);
            make.width.equalTo(self.previewImages);
        }];
        [self.topBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.previewPageControl.mas_bottom).offset(10);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.equalTo(@1);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBar.mas_bottom).offset(5);
            make.left.equalTo(self.topBar.mas_left).offset(titlePaddingLeft);
            make.width.greaterThanOrEqualTo(@25);
            make.height.greaterThanOrEqualTo(@25);
        }];
        makePriceSaleSubtitleAux();
        makeShopWishlist();
        [self.midBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceLabel.mas_bottom).offset(18);
            make.left.equalTo(self.topBar.mas_left);
            make.right.equalTo(self.topBar.mas_right);
            make.height.equalTo(@1);
        }];
        [self.swatchImages mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.midBar.mas_left).offset(titlePaddingLeft);
            make.top.equalTo(self.midBar.mas_bottom).offset(12);
            make.width.equalTo(self.midBar.mas_width);
            make.height.equalTo(@40);
        }];
        [self.swatchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.swatchImages.mas_bottom).offset(5);
            make.left.equalTo(self.swatchImages.mas_left);
            make.width.greaterThanOrEqualTo(@100);
            make.height.lessThanOrEqualTo(@12);
        }];
        [self.sizesBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.greaterThanOrEqualTo(self.swatchLabel.mas_bottom).offset(12);
            make.top.greaterThanOrEqualTo(self.auxPriceLabel.mas_bottom).offset(12);
            make.height.equalTo(@1);
        }];
        [self.sizesHolder mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
            make.height.greaterThanOrEqualTo(@45);
        }];
        [self.collectionViewSize mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right).offset(0);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sizeCVHeight.constant = self.collectionViewSize.contentSize.height + self.collectionViewSize.contentInset.top + self.collectionViewSize.contentInset.bottom;
            [self.collectionViewSize addConstraint:self.sizeCVHeight];
        });
        [self.detailsBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.collectionViewSize.mas_bottom);
            make.height.equalTo(@1);
        }];
        [self.descriptionTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.detailsBar.mas_bottom).offset(12);
            make.height.greaterThanOrEqualTo(@25);
        }];
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.descriptionTitleLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.top.greaterThanOrEqualTo(self.descriptionTitleLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@15);
        }];
        makeFeatures();
        [self.shippingBar mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.featuresLabel.mas_bottom).offset(12);
            make.height.equalTo(@1);
        }];
        [self.shippingTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.shippingBar.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@25);
        }];
        [self.shippingDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shippingTitleLabel.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.top.greaterThanOrEqualTo(self.shippingTitleLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@15);
        }];
        [self.learnMoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shippingDetailLabel.mas_left);
            make.top.greaterThanOrEqualTo(self.shippingDetailLabel.mas_bottom).offset(5);
            make.height.greaterThanOrEqualTo(@25);
        }];
        //        [self.btmBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.featuresLabel.mas_bottom).offset(5);
        //            make.left.width.height.equalTo(self.topBar);
        //        }];
        
    }
     });
    //self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self sizeContent];
}

- (void)sizeContent {
    CGRect frame = CGRectZero;
    for (UIView* view in self.contentView.subviews) {
        CGRect viewFrame = view.frame;
        if (viewFrame.size.width > 866) {
            NSLog(@"%s",__func__);
        }
        
        frame = CGRectUnion(frame, view.frame);
    }
    frame.origin = CGPointZero;
    frame.size.height += 50;
    if (frame.size.width <= 0 || frame.size.height <= 0) {
        return;
    }
    
    //remove the width for the left hand element view in the ipad
    frame.size.width = self.frame.size.width - self.elementTableViewWidth;
    
    //if we're in iPad landscape mode, we should also subtract the width for the preview images
    
    //Remove t
    CGFloat contentRight = 0;
    if (IS_IPAD && IS_LANDSCAPE) {
        CGSize previewSize = [self sizeForPreviewImagesInsideSize:self.frame.size];
        contentRight = previewSize.width + 5;
    }
    frame.size.width -= contentRight;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentView.frame = frame;
    });
    
    //remove the width for the left hand element view in the ipad
    CGSize scrollSize = CGSizeMake(frame.size.width, frame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = scrollSize;
    });
}


#pragma mark - UICollectionViewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.previewImages) {
        return [[self previewImagesItems] count];
    }
    if (collectionView == self.swatchImages) {
        return [[self swatchImagesItems] count];
    }
    if (collectionView == self.collectionViewSize) {
        return [[self sizeImages] count];
    }
    
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.previewImages) {
        return [self cellForPreviewImageAtIndexPath:indexPath];
    }
    
    //return cell for the swatch object
    if (collectionView == self.swatchImages) {
        return [self cellForSwatchImageAtIndexPath:indexPath];
    }
    
    //return cell for the size object
    if (collectionView == self.collectionViewSize) {
        return [self cellForCollectionViewSizeAtIndexPath:indexPath];
    }
    
    return nil;
}

- (UICollectionViewCell*)cellForPreviewImageAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [self.previewImages dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
    UIImageView* imageView = [cell contentViewImageViewWithIdentifier:@"imageView"];
    UIActivityIndicatorView* indicator = [cell contentViewActivityIndicatorWithIdentifier:@"indicator"];
    NSURL* url = [[self previewImagesItems] objectAtIndex:indexPath.row];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = nil;
        [indicator startAnimating];
    });
    @weakify(indicator);
    @weakify(imageView);
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        @strongify(indicator);
        @strongify(imageView);
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            imageView.image = image;
        });
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];
    
    return cell;
}


- (UICollectionViewCell*)cellForCollectionViewSizeAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [self.collectionViewSize dequeueReusableCellWithReuseIdentifier:@"size" forIndexPath:indexPath];
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundView.backgroundColor = [UIColor colorWithWhite:0.72 alpha:1.0];
    });
    
    
    SizeModel* size = [[self sizeImages] objectAtIndex:indexPath.row];
    UILabel* sizeLabel = [cell contentViewLabelWithIdentifier:@"sizeLabel"];
    dispatch_async(dispatch_get_main_queue(), ^{
        sizeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        sizeLabel.textColor = [UIColor colorWithRed:(53.0f/255.0f) green:(53.0f/255.0f) blue:(53.0f/255.0f) alpha:1.0];
        sizeLabel.text = size.name;
    });
    
    return cell;
}

- (UICollectionViewCell*)cellForSwatchImageAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [self.swatchImages dequeueReusableCellWithReuseIdentifier:@"swatch" forIndexPath:indexPath];
    UIImageView* imageView = [cell contentViewImageViewWithIdentifier:@"imageView"];
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 0;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    });
    
    
    //create a small light border for when the cell is not selected
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.92 green:0.96 blue:0.90 alpha:1];
    });
    //create 'thickness' by setting constraints
    [cell.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(imageView).offset(-1);
        make.width.and.height.equalTo(imageView).offset(2);
    }];
    
    
    //create the background view
    //for when the swatch is selected
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.02 green:0.16 blue:0.10 alpha:1];
        cell.selectedBackgroundView.layer.cornerRadius = 0;
    });
    //create 'thickness' by setting constraints
    [cell.selectedBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(imageView).offset(-2);
        make.width.and.height.equalTo(imageView).offset(4);
    }];
    
    UIActivityIndicatorView* indicator = [cell contentViewActivityIndicatorWithIdentifier:@"indicator"];
    SwatchModel* swatch = [[self swatchImagesItems] objectAtIndex:indexPath.row];
    NSURL* url = swatch.imageURL;
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        [indicator startAnimating];
    });
    @weakify(indicator);
    @weakify(imageView);
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        @strongify(indicator);
        @strongify(imageView);
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            imageView.image = image;
        });
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.previewImages) {
        NSUInteger ndx = self.previewImages.contentOffset.x / self.previewImages.bounds.size.width;
        self.previewPageControl.currentPage = ndx;
        self.previewPageControl.updateWithDesign1;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.swatchImages) {
        [self onProductUpdate];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.previewImages) {
        //this is causing disappearing views SYN-3005
//        UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
//        [imageView cancelImageRequestOperation];
//        imageView.image = nil;
    }
}


#pragma mark - Selecting a Variant

- (void)selectVariantAtIndex:(NSUInteger)index {
    if (index >= [self.swatchImagesItems count]) {
        [self onProductUpdate];
        return;
    }
    NSIndexPath* ndx = [NSIndexPath indexPathForRow:index inSection:0];
    [self.swatchImages selectItemAtIndexPath:ndx animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
    [self collectionView:self.swatchImages didSelectItemAtIndexPath:ndx];
}

#pragma mark - Updating the Product

- (void)setProductGroupModel:(ProductGroupModel *)productGroupModel {
    _productGroupModel = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.swatchImages reloadData];
    });
    [self onProductUpdate];
    NSString* test = productGroupModel.syndecaCTATitle;
    NSString* test2 = productGroupModel.productDescription;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _productGroupModel = productGroupModel;
        [self.swatchImages reloadData];
    });
    [self.collectionViewSize reloadData];
    [self selectVariantAtIndex:0];
}

- (void)onProductUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewImages reloadData];
        [self.collectionViewSize reloadData];
    
    
    self.previewPageControl.currentPage = 0;
    self.previewPageControl.numberOfPages = [[self previewImagesItems] count];
    self.previewPageControl.updateWithDesign1;
    
    self.titleLabel.attributedText = [self titleAttributedText];
    self.swatchLabel.attributedText = [self swatchAttributedText];
//    self.swatchLabel.text = @"Color: Blank";
    self.priceLabel.attributedText = [self priceAttributedText];
    self.saleLabel.attributedText = [self saleAttributedText];
    self.auxPriceLabel.attributedText = [self auxPriceAttributedText];
    self.subtitleLabel.attributedText = [self subtitleAttributedText];
    self.descriptionLabel.attributedText = [self descriptionAttributedText];
    self.descriptionTitleLabel.text = @"Details:";
    self.featuresLabel.attributedText = [self featuresAttributedText];
    
    self.shippingTitleLabel.text = @"Shipping & Returns";
    self.shippingDetailLabel.text = @"Free shipping. Free returns. All the time. Purchases made online can also be returned or exchanaged at any Nordstrom store, free of charge.";
    self.learnMoreLabel.attributedText = [self learnMoreAttributedText];
    
    
    // resets
    [self.scrollView scrollRectToVisible:CGRectZero animated:NO];
    //self.scrollView.contentOffset = CGPointZero;
    [self.previewImages scrollRectToVisible:CGRectZero animated:NO];
    //self.previewImages.contentOffset = CGPointZero;
    ProductGroupModel* productGroupModel = self.productGroupModel;
    BOOL hasURL = self.productGroupModel.url1 || productGroupModel.url1_shareurl;
    
    if (productGroupModel.catalog.extensions.shoppingEnabled && hasURL) {
        self.shopButton.hidden = NO;
        //self.pinterestButton.hidden = NO;
    } else {
        self.shopButton.hidden = YES;
        //self.pinterestButton.hidden = YES;
    }
    
    BOOL hasCustomCTA = (self.productGroupModel.syndecaCTATitle > 0);
    
    if(hasCustomCTA == true){
        
        self.shopButton.titleLabel.numberOfLines = 1;
        self.shopButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        // self.shopButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
        
        [self.shopButton setTitle:self.productGroupModel.syndecaCTATitle forState:UIControlStateNormal];
    }
    else{
        //We keep the current label
    }
    
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIViewHelper screenSize];
    }
    [self makeLayoutForSize:size];
    [self removeSizeInformation];
    [self removeShippingInformation];
        
        self.descriptionTitleLabel.alpha = 1;
        self.featuresLabel.alpha = 1;
    if([self.featuresLabel.attributedText.string isEqualToString:@"" ] && self.productGroupModel != nil){
        [self removeDetailInformation];
    }
    
    
    if (!productGroupModel) {
        return;
    }
    
        });
    [self.delegate updateHeartTabBarItem];
}

- (void)updateConstraints {
    [super updateConstraints];
    [[[RACSignal empty] delay:0.001] subscribeCompleted:^{
        [self setNeedsLayout];
    }];
}

#pragma mark - Getters

- (ProductEntityModel*)selectedProduct {
    NSUInteger ndx = NSUIntegerMax;
    NSArray* paths = [self.swatchImages indexPathsForSelectedItems];
    if ([paths count] < 1) {
        ndx = 0;
    } else {
        NSIndexPath* path = [paths firstObject];
        ndx = path.row;
    }
    
    NSArray* k = _productGroupModel.entities;
    if (_productGroupModel && [_productGroupModel.entities count]) {
        //        return _productGroupModel;
        return [_productGroupModel.entities objectAtIndex:ndx];
    }
    
    return nil;
}

- (SwatchModel*)selectedSwatch{
    
    if([self.productGroupModel.swatches count] == 0){
        return [[SwatchModel alloc] init];
    }
    
    
    NSUInteger ndx = NSUIntegerMax;
    NSArray* paths = [self.swatchImages indexPathsForSelectedItems];
    if ([paths count] < 1) {
        ndx = 0;
    } else {
        NSIndexPath* path = [paths firstObject];
        ndx = path.row;
    }
    
    return [self.productGroupModel.swatches objectAtIndex:ndx];
}
- (NSUInteger)selectedProductIndex {
    NSUInteger ndx = NSUIntegerMax;
    NSArray* paths = [self.swatchImages indexPathsForSelectedItems];
    if ([paths count] < 1) {
        ndx = 0;
    } else {
        NSIndexPath* path = [paths firstObject];
        ndx = path.row;
    }
    
    return ndx;
}

- (ProductGroupModel*)productGroupModel {
    return _productGroupModel;
}

- (NSArray*)previewImagesItems {
    ProductEntityModel* pm = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
    NSArray* a = @[];
    if (pm.previewURL) {
        a = [a arrayByAddingObject:pm.previewURL];
    }
    if (pm.altImageURLs) {
        a = [a arrayByAddingObjectsFromArray:pm.altImageURLs];
    }
    return a;
}

- (NSArray*)swatchImagesItems {
    return _productGroupModel.swatches;
}

- (NSArray*)sizeImages{
    NSArray* sizes = self.productGroupModel.sizes;
    NSArray* ss = self.productGroupModel.swatches;
    NSUInteger i = [self selectedProductIndex];
    NSArray* returnVals = [[NSArray alloc] init];
    SwatchModel* s = [self selectedSwatch];
        NSString* colorName = s.name;
        for (SizeModel *szmodel in sizes) {
            NSString* thisString = szmodel.colorFamily;
            
            if([thisString isEqualToString:colorName]){
                returnVals = [returnVals arrayByAddingObject:szmodel];
            }
        }
    
    return returnVals;
    
}

- (NSAttributedString*)swatchAttributedText {
    NSArray* ss = self.productGroupModel.swatches;
    NSUInteger i = [self selectedProductIndex];
    //the NSUInteger will return nil if give 0
    //however, we need to be able to use the index of 0
    //so we must convert i to an object type if we want to check for nil
//    if (ss && [ss count] && i && [ss count] > i) {
    if (ss && [ss count] && [ss count] > i) {
        SwatchModel* s = [ss objectAtIndex:i];
//        NSString* str = @"<font color=\"#333\"><b>color: &nbsp;</b></font>"
//        @"<font color=\"#528fc9\">%@</font>";
        NSString* str = @"Color: %@";
        NSString* html = [NSString stringWithFormat:str, s.name];
        return [self.swatchLabel attributedStringFromString:html];
//        return [self.swatchLabel attributedStringFromHtml:html];
    }
    return nil;
}

- (NSAttributedString*)featuresAttributedText {
    ProductEntityModel* pm = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
    NSArray* features = pm.features;
    
    
    if (features == nil || [features count] == 0) {
        return [self.featuresLabel attributedStringFromHtml:@""];
    }
    
    NSArray* strs = @[];
    for (NSString* feature in features) {
        strs = [strs arrayByAddingObject:[NSString stringWithFormat:@"<li>%@</li>",feature]];
    }
    NSString* html = [NSString stringWithFormat:@"<ul style='margin-top:0;'>%@</ul>",[strs componentsJoinedByString:@""]];
    return [self.featuresLabel attributedStringFromHtml:html];
}

- (NSAttributedString*)subtitleAttributedText {
    ProductEntityModel* pm = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
    if (pm != nil && pm.styleNum != nil) {
        return [self.subtitleLabel attributedStringFromString:pm.styleNum];
    }
    return nil;
}

- (NSAttributedString*)auxPriceAttributedText {
    ProductEntityModel* pm = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
    NSString* s = pm.promoMessage;
    if (s != nil) {
        return [[NSAttributedString alloc] initWithString:s attributes:@{}];
    }
    return nil;
}

- (NSAttributedString*)descriptionAttributedText {
    NSString* desc = self.productGroupModel.productDescription;
    NSAttributedString* features = [self featuresAttributedText];
    NSAttributedString* emptyString = [[NSAttributedString alloc] initWithString:@"" ];
    if (desc) {
        return [self.descriptionLabel attributedStringFromHtml:desc];
    } else if (![features isEqualToAttributedString:emptyString]) {
        return [self.descriptionLabel attributedStringFromHtml:@"details"];
    }
    return emptyString;
}

- (BOOL)isSale {
    CGFloat pf = self.productGroupModel.priceFloat;
    CGFloat sf = self.productGroupModel.priceSaleFloat;
    return (sf != 0.0 && sf < pf);
}

- (NSString*)currencyStringFrom:(NSNumber*)n {
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    f.locale = [NLS nls].locale;
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    return [f stringFromNumber:n];
}


- (NSAttributedString*)saleAttributedText {
    CGFloat salef = self.productGroupModel.priceSaleFloat;
    NSString* html = @"";
    if ([self isSale]) {
        NSNumber* n = [NSNumber numberWithFloat:salef];
        NSString* s = [self currencyStringFrom:n];
        s = [@"Now " stringByAppendingString:s];
        html = [NSString stringWithFormat:@"<font color=\"#f00\"><b>%@</b></font>",s];
    }
    return [self.saleLabel attributedStringFromHtml:html];
}

- (NSAttributedString*)priceAttributedText {
    CGFloat price = self.productGroupModel.priceFloat;
    NSString* priceStr = [self currencyStringFrom:[NSNumber numberWithFloat:price]];
    
    if ([self isSale]) {
        return [[NSAttributedString alloc] initWithString:priceStr attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    }
    
    return [[NSAttributedString alloc] initWithString:priceStr attributes:@{}];
}

- (NSAttributedString*)titleAttributedText {
    if (self.productGroupModel.title) {
        NSString *title = self.productGroupModel.title;
        return [self.titleLabel attributedStringFromHtml:self.productGroupModel.title];
    }
    return nil;
}

- (NSAttributedString*)learnMoreAttributedText {
    return [self.learnMoreLabel underLineBoldAttributedStringFromHTML:@"Learn More"];
}


- (void)removeShippingInformation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.shippingBar mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.top.equalTo(self.featuresLabel.mas_bottom).offset(0);
        make.height.equalTo(@0);
    }];
    [self.shippingTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceLabel.mas_left);
        make.top.greaterThanOrEqualTo(self.shippingBar.mas_bottom).offset(0);
        make.height.equalTo(@0);
    }];
    [self.shippingDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shippingTitleLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.top.greaterThanOrEqualTo(self.shippingTitleLabel.mas_bottom).offset(0);
        make.height.equalTo(@0);
    }];
    [self.learnMoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.shippingDetailLabel.mas_left);
        make.top.greaterThanOrEqualTo(self.shippingDetailLabel.mas_bottom).offset(0);
        make.height.equalTo(@0);
    }];
    
    
        self.shippingDetailLabel.alpha = 0;
        self.shippingBar.alpha = 0;
        self.shippingTitleLabel.alpha = 0;
    });
}

- (void)removeSizeInformation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sizesHolder mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
            make.height.greaterThanOrEqualTo(@0);
        }];
        [self.collectionViewSize mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sizesBar.mas_left);
            make.right.equalTo(self.sizesBar.mas_right).offset(0);
            make.top.greaterThanOrEqualTo(self.sizesBar.mas_bottom);
        }];
    
        self.sizeCVHeight.constant = 0;
        [self.collectionViewSize updateConstraints];
        
        self.sizesHolder.alpha = 0;
        self.sizesBar.alpha = 0;
        self.collectionViewSize.alpha = 0;
    });
    
    
}

- (void)removeDetailInformation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.descriptionTitleLabel.alpha = 0;
        self.featuresLabel.alpha = 0;
    });
}

#pragma mark - Responding to Button Taps

- (void)didTapAddToWishlistButton:(id)tap {
    ShoppingCart* cart = [[ShoppingCart alloc] init];
    ProductEntityModel* product = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
    ProductGroupModel* pg = self.productGroupModel;
    ProductEntityModel* test = pg.firstEntity;
    [cart addItem:pg inQuantity:1];
    if (self.delegate) {
        ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
        result.result = cart;
        result.resultType = ProductDetailViewResultTypeWishlist;
        [self.delegate productDetailView:self didSelectResult:result];
    }
    [FIRTrackProxy sharedProxy].catalogModel = self.productGroupModel.catalog;
    [[FIRTrackProxy sharedProxy] trackAddWishListGroup:pg];
    
//    self.addToWishlistButton.userInteractionEnabled = NO;
    
    
//    
//    // Animate some updates
//    [self.addToWishlistButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"..."] forState:UIControlStateNormal];
//    [UIView animateWithDuration:0.5 animations:^{
//        self.addToWishlistButton.alpha = 0.75;
//    } completion:^(BOOL finished) {
//        NSString* success = [[NLS nls] stringFor:@"product.addWishlistSuccess" default:@"  added :)"];
//        [self.addToWishlistButton setAttributedTitle:[[NSAttributedString alloc] initWithString:success] forState:UIControlStateNormal];
//        [UIView animateWithDuration:1 animations:^{
//            self.addToWishlistButton.alpha = 1;
//        } completion:^(BOOL finished) {
//            [self.addToWishlistButton setTitle:nil forState:UIControlStateNormal];
//            NSString* reset = [[NLS nls] stringFor:@"product.addWishlistText"
//                                           default:@"  add to wishlist"];
//            [self.addToWishlistButton setAttributedTitle:[[NSAttributedString alloc] initWithString:reset]
//                                                forState:UIControlStateNormal];
//            self.addToWishlistButton.userInteractionEnabled = YES;
//        }];
//    }];
}

- (void)didTapShopButton:(id)tap {
    if (self.delegate) {
        ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
        result.result = [MasterConfiguration choose:self.selectedProduct or:self.productGroupModel.firstEntity];
        result.resultType = ProductDetailViewResultTypeShopNow;
        [self.delegate productDetailView:self didSelectResult:result];
    }
    
    [[FIRTrackProxy sharedProxy] trackTapShopNow];
}

@end
