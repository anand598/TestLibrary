//
//  MasterConfiguration.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/12/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "MasterConfiguration.h"
#import "SyndecaTabBarController.h"
#import "ProductDetailView.h"
#import "ProductCellView.h"
#import "SortsAndFilters.h"
#import "Icons.h"
#import "UIViewHelper.h"
#import "UIImageView+Offline.h"
#import "NSDictionary+AsObjectOrNil.h"

@implementation MasterConfiguration

#pragma mark Utilities

SYNTHESIZE_DI

+ (id)choose:(id)item1 or:(id)item2 {
    return item1 ? item1 : item2;
}

+ (id)choose:(id)item1 or:(id)item2 or:(id)item3 {
    return item1 ? item1 : item2 ? item2 : item3;
}

#pragma mark - Config

- (id)init {
    self = [super init];
    if (self) {
        // This is default configuration.
        self.toolbarLogo = [UIImage imageNamed:@"syndeca"];
        
        [self configureTOCValues];
        [self configureProductPanelValues];
        
        self.bagIcon = [Icons sharedIcons].bagIconImage();
        self.bagName = @"Bag";
        self.webViewInsets = UIEdgeInsetsMake(64, 0, 52, 0);
        
        //self.shopNowAction = ^(ProductDetailView* view) {
        //    // SYN-1264
        //    // Check to make sure the latest entity exists, or fall back to the general
        //    // product model.
        //    ProductModel* e = view.selectedProduct;
        //    ProductModel* p = view.productModel;
        //    ProductModel* m = [MasterConfiguration choose:e or:p];
        //    NSURLRequest* req = [NSURLRequest requestWithURL:m.url1];
        //    [[SyndecaTabBarController sharedController] visitURL:req];
        //};
        
        self.clientName = @"Synapse Group";
        self.clientFeedbackEmailSubject = @"Feedback";
        self.catalogHasSearch = NO;
        self.skipToFeaturedCatalog = NO;
        self.shouldShowWebPDP = NO;
        
        // SYNIOS-185: Email share needs subject text.
        self.emailShareSubject = @"I saw this and thought of you.";
        // SYNIOS-185: Must send standardized keys for our platform.
        self.shareTypeToShareKey = @{UIActivityTypeMail : @"email",
                                     UIActivityTypePostToFacebook : @"facebook",
                                     UIActivityTypePostToTwitter : @"twitter",
                                     UIActivityTypeMessage : @"message"};
        
        
        
        //SYN-2693
        self.snapPhotoDialogue1 = @"We haven't recognized anything yet.";
        self.snapPhotoDialogue2 = @"How about we snap a picture instead?";
        self.scanRate = 0.500;
        self.interstitialTimeToShow = 7;
        self.interstitialTimeToHide = 4;
        self.shouldShowContinuousScan = true;
        
        self.scanInterstitialLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        self.scanInterstitialLabelFontiPad = [UIFont fontWithName:@"HelveticaNeue" size:28.0];
        
        WKProcessPool* processPool = [[WKProcessPool alloc] init];
        self.globalProcessPool = processPool;
    }
    return self;
}

static MasterConfiguration* __sharedConfiguration = nil;
+ (MasterConfiguration*)sharedConfiguration {
    if (! __sharedConfiguration) {
        __sharedConfiguration = [[MasterConfiguration alloc] init];
    }
    return __sharedConfiguration;
}

+ (void)setSharedConfiguration:(MasterConfiguration*)config {
    __sharedConfiguration = config;
}

#pragma mark - Tint

- (UIColor*)tabBarTintColor {
    return [UIColor lightGrayColor];
}

- (UIColor*)cancelButtonColor {
    return [UIColor colorWithRed:(237.0/255.0) green:(0.0/255.0) blue:(140.0/255.0) alpha:1.0];
}

- (UIColor*)scanShopResultsTitleViewLabelColor{
    return [UIColor grayColor];
}

#pragma mark - Navigation Bar

- (UIView*)navigationBarTitleView {
    UIImage* logo = self.toolbarLogo;
    UIImageView* view = [[UIImageView alloc] initWithImage:logo];
    view.contentMode = UIViewContentModeScaleAspectFit;
    if (logo.size.height > 44) {
        CGRect frame = CGRectZero;
        frame.size = logo.size;
        frame.size.height = 44;
        frame.size.width = (frame.size.width - 60.0);
        view.frame = frame;
        view.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    int padding = 54.0;
    [view setFrame:CGRectMake(view.frame.origin.x, 7.0, view.frame.size.width - 44.0, view.frame.size.height)];
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height + padding)];
    [containerView addSubview:view];
    return containerView;
}

#pragma mark - Table of Contents

- (void)configureTOCValues {
    self.tocBackgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    self.tocPageLabelColor = [UIColor darkGrayColor];
    self.tocPageHighlightColor = [UIColor colorWithRed:0 green:127.0/255.0 blue:254.0/255.0 alpha:1];
}

#pragma mark - Sharing

- (NSString*)changeShareTypeToShareKey:(NSString *)type {
    NSString* key = [self.shareTypeToShareKey stringByKey:type];
    if (!key) {
        return type;
    }
    return key;
}

#pragma mark - Product Panel

- (void)configureProductPanelValues {
    self.productPanelPadding = 8;
    self.productPanelBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.productPanelSeparatorColor = [UIColor clearColor];
    self.productPanelContentInset = UIEdgeInsetsMake(-1, 0, 84, 0);
    self.productCellWidth = 180;
    self.productCellHeight = 300;
//    self.productCellWidth = 158;
//    self.productCellHeight = 206;
    //self.productCellImageFrame = ^ CGRect (ProductCellView* cellView) {
    //    return CGRectMake(10, 10, 122, 122);
    //};
    //self.productCellTitleFrame = ^ CGRect (ProductCellView* cellView) {
    //    return CGRectMake(10, 132, 122, 35);
    //};
    //self.productCellSubtitleFrame = ^ CGRect (ProductCellView* cellView) {
    //    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    //    CGRect title = config.productCellTitleFrame(cellView);
    //    title.origin.y = CGRectGetMaxY(title);
    //    title.size.height = 25;
    //    return title;
    //};
    
   // text color //125 125 125
    self.productItemSubtitleNumLines = 1;
    self.productCellImageContentMode = UIViewContentModeScaleAspectFit;
    self.productCellTitleAlignment = NSTextAlignmentLeft;
    self.productCellTitleTextColor = [UIColor darkGrayColor];
    self.productCellTitleTextHighlightColor = [UIColor whiteColor];
    self.productPanelBackgroundColor = [[UIColor whiteColor]
                                        colorWithAlphaComponent:0.5];
    self.toggleVerticalProductsBackgroundColor = [[UIColor whiteColor]
                                                  colorWithAlphaComponent:0.9];
    self.toggleVerticalProductsLabelColor = [UIColor darkTextColor];
    self.productCellTopBackgroundColor = [[UIColor whiteColor]
                                          colorWithAlphaComponent:0.9];
    self.productCellTopBorderColor = [UIColor colorWithRed:(201.0/255.0)
                                                     green:(201.0/255.0)
                                                      blue:(201.0/255.0)
                                                     alpha:1.0];
    self.productCellBottomBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.9];
    self.productCellHighlightTopBackgroundColor = [UIColor whiteColor];
    self.productCellHighlightTopBorderColor = [UIColor colorWithRed:(4.0/255.0) green:(173.0/255.0) blue:(255.0/255.0) alpha:1.0];
    self.productCellHighlightBottomBackgroundColor = [UIColor colorWithRed:0.12 green:0.52 blue:0.76 alpha:1];
    self.generatePagePanelState = ^ PagePanelState* (NSArray* productsByPage, NSArray* pageModels) {
        
        return [SortsAndFilters generatePagePanelStateFromProducts:productsByPage andPages:pageModels];
    };
    
    self.generateFilteredPagePanelState = ^ PagePanelState* (NSArray* productsByPage, NSArray* pageModels) {
        
        PagePanelState* first = [SortsAndFilters generateFilteredPagePanelStateFromProducts:productsByPage andPages:pageModels];
        return first;
    };
    
    
    
//    Spcaing for a banner image height to present information to the user
//    self.iPhoneBannerImageHeight = 72;
//    self.iPadBannerImageHeight = 150;
//    self.iPhoneBannerImageTop = 72;
//    self.iPadBannerImageTop = 72;
    
//    Spacing for if the banner image height is 0
    self.iPhoneBannerImageHeight = 0;
    self.iPadBannerImageHeight = 0;
    self.iPhoneBannerImageTop = 12;
    self.iPadBannerImageTop = 12;
    
    self.verticalPublicationsLayoutHeightOffset = -26;
    
}

@end
