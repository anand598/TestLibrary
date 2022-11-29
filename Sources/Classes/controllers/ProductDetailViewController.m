//
//  ProductDetailViewController.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "WebViewController.h"
#import "PDPWebController.h"
#import "ShareProxy.h"
#import "FIRTrackProxy.h"
#import "MasterConfiguration.h"
#import "UIViewHelper.h"
#import "Icons.h"
#import "NLS.h"
//#import <HBHandlebars/HBHandlebars.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface ProductDetailViewController ()

@property (readwrite) PageModel* pageModel;
@property (readwrite) ProductGroupModel* productGroupModel;
@property (readwrite) VariantModel* variantModel;
@property (readwrite) ProductDetailView* productDetailView;
@property (readwrite) ShareProxy* shareProxy;
@property (readwrite) UIActivityViewController* shareViewController;

@property (readwrite) UIPopoverController* popOverController;

@property (readwrite) UIBarButtonItem* shareRightBarButton;
@property (readwrite) UIBarButtonItem* heartRightBarButton;

@end

@implementation ProductDetailViewController

- (id)initWithPageModel:(PageModel *)pageModel andProductGroupModel:(ProductGroupModel *)productGroupModel andVariantModel:(VariantModel*)variantModel {
    self = [super init];
    if (self) {
        if (variantModel != nil && productGroupModel != nil && ![variantModel.productGroup.ID isEqualToString:productGroupModel.ID]) {
            @throw [[NSException alloc] initWithName:@"Product and Variant mismatch"
                                              reason:@"Cannot instantiate a ProductDetailView with mismatched ProductModel and VariantModel"
                                            userInfo:nil];
        }
        self.pageModel = pageModel;
        self.productGroupModel = productGroupModel;
        self.variantModel = variantModel;
    }
    return self;
}
  
- (id)initWithPageModel:(PageModel *)pageModel andProductGroupModel:(ProductGroupModel *)productGroupModel {
    return [self initWithPageModel:pageModel andProductGroupModel:productGroupModel andVariantModel:nil];
}

#pragma mark - Building the view

- (void)loadView {
    self.productDetailView = [self newProductDetailView];
    if (IS_IPAD && self.isFromSearchController == false) {
        self.productDetailView.elementTableViewWidth = [MasterConfiguration sharedConfiguration].productCellWidth;
    }
    self.view = self.productDetailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Make sure we have product share urls before trying to share.
    // @see https://synapsegroup.jira.com/browse/SYNIOS-242
    ProductGroupModel* pm = self.productGroupModel;
    if (self.pageModel.catalog.extensions.sharingEnabled && pm.url1_shareurl) {
        
        //Create the share tab bar button
        self.shareRightBarButton = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                               target:self
                               action:@selector(shareProduct)];
        self.shareRightBarButton.accessibilityLabel = @"item-share-product";
        
//        This overwrites the global tab bar icon color settings.
//        self.shareRightBarButton.tintColor = [UIColor blackColor];
        
        self.navigationItem.rightBarButtonItem = self.shareRightBarButton;
        [self updateHeartTabBarItem];
    }
    
    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    self.navigationItem.titleView = titleView;
    
    

    
    //add a just back button
    UIImage *backButtonImage = [Icons sharedIcons].backButtonImage();
    UIImageView* backButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButtonImageView setImage:backButtonImage];
    [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
    self.navigationItem.leftBarButtonItem = back;

    
    if (self.variantModel) {
        [self.productDetailView selectVariantAtIndex:[self.variantModel indexInProductGroup]];
    } else {
        [self.productDetailView selectVariantAtIndex:0];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
//    CGSize size = self.detailView.bounds.size;
//    if (CGSizeEqualToSize(size, CGSizeZero)) {
//        size = [UIViewHelper screenSize];
//    }
//    [self.detailView makeLayoutForSize:size];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.detailView onProductUpdate];
    if (self.pageModel) {
        [FIRTrackProxy sharedProxy].pageModels = @[self.pageModel];
        
        if(self.productGroupModel){
//                ProductGroupModel* detailViewGroupModel = self.detailView.productGroupModel;
                [FIRTrackProxy sharedProxy].productModel = self.productGroupModel;
                [[FIRTrackProxy sharedProxy] trackViewProduct];
        }
    }
}

- (ProductDetailView*)newProductDetailView {
    ProductDetailView* v = [[[ProductDetailView DIClass] alloc] initWithFrame:CGRectZero];
    v.delegate = self;
    v.productGroupModel = self.productGroupModel;
    
    if (self.tabBarController) {
        v.tabBarHeightAdjustment = 44;
    }
    return v;
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.detailView makeLayoutForSize:size];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

#pragma mark - Providing the view

- (ProductDetailView*)detailView {
    return self.productDetailView;
}

#pragma mark - Reloading the Product

- (void)reloadDetailViewWithProductGroupModel:(ProductGroupModel*)productGroupModel andVariantIndex:(NSUInteger)ndx {
    [[self detailView] setProductGroupModel:productGroupModel];
    [[self detailView] selectVariantAtIndex:ndx];
}

#pragma mark - Handling selection results

- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    switch (result.resultType) {
        case ProductDetailViewResultTypeShopNow: {
            // SYN-1264
            // Check to make sure the latest entity exists, or fall back to the general
            // product model.
            ProductEntityModel* m = [MasterConfiguration choose:self.productDetailView.selectedProduct or:self.productGroupModel.firstEntity];
            
            if(m == nil){
                m = [MasterConfiguration choose: self.productDetailView.selectedProduct or:self.productGroupModel];
            }
            NSURL* u = m.url1;
            u = m.url1_tracking;
            NSURLRequest* req = [NSURLRequest requestWithURL:u];
            PDPWebController* c = [[PDPWebController alloc] initWithRequest:req];
            c.productGroupModel = m.parent;
            c.isFromSearchController = true;
            [c.view layoutIfNeeded];
            [self.navigationController pushViewController:c animated:YES];
            break;
        }
            
        case ProductDetailViewResultTypePinterest: {
            NSURL* url = (NSURL*)result.result;
            WebViewController *c = [[WebViewController alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
            c.shouldReloadOnViewDidAppear = true;
            c.shouldShowBackButton = true;
            [self.navigationController pushViewController:c animated:YES];
            break;
        }
            
        default: {
            if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(productDetailView:didSelectResult:)]) {
                [self.productDetailViewDelegate productDetailView:view didSelectResult:result];
            }
            break;
        }
    }
}

#pragma mark - Favoriting/Heart
- (void)updateHeartTabBarItem{
    
    
    //load in tab bar images and custom views
    //Add a custom image heart button
    UIImage *heartButtonImage = [Icons sharedIcons].heartIconEmptyImage();
    if([self.productDetailViewDelegate checkIfCartContainsItem:self.productDetailView.productGroupModel]){
        heartButtonImage = [Icons sharedIcons].heartIconImage();
    }
    UIButton* heartButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [heartButton setBackgroundImage:heartButtonImage forState:UIControlStateNormal];
    [heartButton addTarget:self action:@selector(heartProduct) forControlEvents:UIControlEventTouchUpInside];
    heartButton.adjustsImageWhenHighlighted = NO;
    self.heartRightBarButton = [[UIBarButtonItem alloc] initWithCustomView:heartButton];
    self.heartRightBarButton.accessibilityLabel = @"item-heart-product";
    
    if(self.shareRightBarButton != nil){
        self.navigationItem.rightBarButtonItems = @[self.heartRightBarButton, self.shareRightBarButton];
    }
    

    
}
- (void)heartProduct{
    
    
    ShoppingCartController* shoppingCartController = [self newWishlistController];
    shoppingCartController.view.backgroundColor = [UIColor whiteColor];
    shoppingCartController.shouldShowBackButton = true;
    shoppingCartController.willHaveTabBar = true;
    [shoppingCartController.view layoutIfNeeded];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shoppingCartController];
    
//    [self.navigationController pushViewController:shoppingCartController animated:YES];
//
    BOOL value = true;
    
    if([self.productDetailViewDelegate respondsToSelector:@selector(checkIfCartContainsItem:)]){
        value = [self.productDetailViewDelegate checkIfCartContainsItem:self.productGroupModel];
    }
    if(value == true){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton* backButton = (UIButton *)self.heartRightBarButton.customView;
            [backButton setBackgroundImage:[Icons sharedIcons].heartIconEmptyImage() forState:UIControlStateNormal];
            [self.productDetailView didTapAddToWishlistButton:nil];
        });
        
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton* backButton = (UIButton *)self.heartRightBarButton.customView;
            [backButton setBackgroundImage:[Icons sharedIcons].heartIconImage() forState:UIControlStateNormal];
            [self.productDetailView didTapAddToWishlistButton:nil];
        });
    }
    
    
}

#pragma mark - Wishlist Controller

- (ShoppingCartController*)newWishlistController {
    
    self.mailController     = [[MFMailComposeViewController alloc] init];
    self.mailController.mailComposeDelegate = self;
    
    @weakify(self);
    ShoppingCartController* screen = [[ShoppingCartController alloc] init];
    NSString* wishlistStr = [[NLS nls] stringFor:@"wishlist.title" default:@"*wishlist title*"];
    screen.tabBarItem.title = wishlistStr;
    screen.tabBarItem.image = [Icons sharedIcons].heartIconImage();
    screen.tabBarItem.accessibilityLabel = @"wishlist";
    screen.shoppingCartScreen.titleLabel.text = wishlistStr;
    [screen.shoppingCartScreen.exportButton
     setTitle:[[NLS nls] stringFor:@"wishlist.shareEmailText"
                           default:@"*shareEmailText"]
     forState:UIControlStateNormal];
    screen.shoppingCartScreen.emptyBagLabel.text = [[NLS nls]
                                                    stringFor:@"wishlist.emptyText"
                                                    default:@"Your wish list is currently empty."];
    
    // TODO: Move shopping cart export aciton into MasterConfiguration.
    screen.shoppingCartScreen.exportAction = ^(ShoppingCart* cart) {
        @strongify(self);
        
        // TODO: Change this so Mary Kay messaging isn't in the SDK.
        [self.mailController setSubject:[@"Mary Kay -" stringByAppendingString:wishlistStr]];
        NSString* wishpath = [[NSBundle mainBundle] pathForResource:@"wishlist" ofType:@"html"];
        NSString* wishtmpl = [[NSString alloc] initWithContentsOfFile:wishpath
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
        NSArray* products = @[];
        for (ProductGroupModel* pm in [cart array]) {
            NSString* dollars = [NSString stringWithFormat:@"%i", (int)pm.priceFloat];
            NSInteger cent = (int)(pm.priceFloat - (int)pm.priceFloat) * 100;
            NSString* cents = [NSString stringWithFormat:@"%li", (long)cent];
            if (cent < 10) {
                cents = [@"0" stringByAppendingString:cents];
            }
            
            products = [products arrayByAddingObject:@{ @"src" : [pm.previewURL absoluteString],
                                                        @"title" : pm.title,
                                                        @"name" : pm.name,
                                                        @"quantity": @([cart quantityOfItem:pm]),
                                                        @"dollars" : dollars,
                                                        @"cents" : cents}];
        }
        CGFloat total = [cart totalPrice];
        NSString* dollars = [NSString stringWithFormat:@"%i", (int)total];
        NSInteger cent = (int)(total - (int)total) * 100;
        NSString* cents = [NSString stringWithFormat:@"%li", (long)cent];
        if (cent < 10) {
            cents = [@"0" stringByAppendingString:cents];
        }

        NSString* wishlist = @"";
//        [HBHandlebars renderTemplateString:wishtmpl
//                                                    withContext:@{ @"products" : products,
//                                                                   @"totalDollars" : dollars,
//                                                                   @"totalCents" : cents}
//                                                          error:NULL];
        [self.mailController setMessageBody:wishlist isHTML:YES];
        
        [self presentViewController:self.mailController animated:YES completion:^{}];
    };
    
    [screen.view layoutIfNeeded];
    return screen;
}

#pragma mark - Sharing

- (void)shareProduct {
    ShareProxy* shareProxy = [[ShareProxy sharedProxy] newShareProxy];
   // ProductEntityModel* pm = [MasterConfiguration choose:self.productDetailView.selectedProduct or:self.productGroupModel];

    NSArray* items = @[];
    
   // self.shareProxy = shareProxy;
    
   // if(_pageModel){
        items = [shareProxy itemsFromShareable:self.productGroupModel];
        self.shareViewController = [shareProxy newShareViewControllerWithItems:items];
   // }
    
    if (IS_IPAD) {
        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.shareViewController];
        self.popOverController.delegate = self;
        [self.popOverController presentPopoverFromBarButtonItem:self.shareRightBarButton
                                       permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController presentViewController:self.shareViewController animated:YES completion:^{ }];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

-(void)didPressBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
