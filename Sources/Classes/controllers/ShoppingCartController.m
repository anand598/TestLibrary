//
//  AddToBagScreenController.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ShoppingCartController.h"
#import "MasterConfiguration.h"
#import "NLS.h"
#import "FIRTrackProxy.h"
#import "SyndecaRevealViewController.h"
#import "Icons.h"
#import "ProductDetailViewController.h"
#import "UIViewHelper.h"
#import <Masonry/Masonry.h>
@interface ShoppingCartController ()


@property (readwrite) ProductDetailViewController* productDetailController;
@property (readwrite) NSArray* products;
@property (readwrite) NSArray* pages;
@end

@implementation ShoppingCartController

- (void)loadView {
    self.shoppingCartScreen = [[ShoppingCartScreenView alloc] initWithFrame:CGRectZero];
    self.shoppingCartScreen.shoppingCartDelegate = self;
    self.shoppingCartScreen.productDetailViewDelegate = self;
    self.view = self.shoppingCartScreen;
    [self didUpdateShoppingCart:self.shoppingCartScreen.shoppingCart];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITabBarItem* cartItem = [[UITabBarItem alloc] initWithTitle:[[NLS nls] stringFor:@"nav.cart" default:[MasterConfiguration sharedConfiguration].bagName]
                                                           image:[MasterConfiguration sharedConfiguration].bagIcon
                                                             tag:0];
    self.tabBarItem = cartItem;
    
    
    
    
    
    
    self.resultsLabel = [[UILabel alloc] init];
    self.resultsLabel.textAlignment = NSTextAlignmentCenter;
    self.resultsLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:self.resultsLabel];
    [self.resultsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@64);
        make.width.equalTo(self.view);
        make.height.greaterThanOrEqualTo(@12);
    }];
    
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didUpdateShoppingCart:self.shoppingCartScreen.shoppingCart];
    [self.shoppingCartScreen.productsCollectionView reloadData];
        SyndecaRevealViewController *revealController = self.revealViewController;
        [self.view addGestureRecognizer:revealController.tapGestureRecognizer];
    [self setNavigationItems];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setNavigationItems {
    
    if(!self.navigationController){
        return;
    }
    
    self.navigationItem.titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    SyndecaRevealViewController* revealController = [[SyndecaRevealViewController alloc] revealViewController];
    //Add a custom image hamburger button
    UIImage *hamButtonImage = [Icons sharedIcons].hamburgerMenuImage();
    UIButton* hamButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [hamButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
    [hamButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    hamButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:hamButton];
    //        self.navigationItem.leftBarButtonItem = hamBarButton;
    self.navigationItem.leftBarButtonItem = hamBarButton;

//    
//    self.navigationItem.titleView = nil;
//    self.navigationItem.leftBarButtonItems = nil;
//    self.navigationItem.rightBarButtonItems = nil;
//    
//    
//    
//    NSArray* rightItems = @[];
//    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
//    UIImage *searchImage = [[UIImage imageNamed:@"searchIcon.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearch:)];
//    UIBarButtonItem* indicator = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
//    rightItems = [rightItems arrayByAddingObject:search];
//    rightItems = [rightItems arrayByAddingObject:indicator];
//    
//    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
//    
//    //Add a custom image hamburger button
//    UIImage *hamButtonImage = [Icons sharedIcons].hamburgerMenuImage();
//    UIButton* hamButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 20)];
//    [hamButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
////    [hamButton addTarget:self.delegate action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//    hamButton.adjustsImageWhenHighlighted = NO;
//    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:hamButton];
//    
//    
//    self.navigationItem.leftBarButtonItem = hamBarButton;
//    self.navigationItem.titleView = titleView;
//    self.navigationItem.rightBarButtonItems = rightItems;
    
}

#pragma mark - Favoriting
-(BOOL)checkIfCartContainsItem:(ProductGroupModel*)item{
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(checkIfCartContainsItem:)]) {
        return [self.productDetailViewDelegate checkIfCartContainsItem:item];
    }
    return false;
}

#pragma mark - Handling selection results in child ProductDetailView (handling wishlist selection bubbling for tabbaritem badges)

- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(productDetailView:didSelectResult:)]) {
        [self.productDetailViewDelegate productDetailView:view didSelectResult:result];
        [self.shoppingCartScreen.productsCollectionView reloadData];
    }
}


-(void)didPressBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didUpdateShoppingCart:(ShoppingCart *)shoppingCart {
    if ([shoppingCart totalQuantityOfItems]) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)[shoppingCart totalQuantityOfItems]];
    } else {
        self.tabBarItem.badgeValue = nil;
    }
}

-(void)didSelectProductForDetail:(ProductGroupModel*)product{

//    PageModel* page = [self.pages objectAtIndex:indexPath.row];
    
    
    self.productDetailController = [[ProductDetailViewController alloc] initWithPageModel:nil andProductGroupModel:product];
    self.productDetailController.productDetailViewDelegate = self;
    self.productDetailController.isFromSearchController = true;
    if(!self.navigationController){
        [self presentViewController:self.productDetailController animated:YES completion:nil];
    } else{
        [self.navigationController pushViewController:self.productDetailController animated:YES];
    }
    
}

#pragma mark - Setters and Getters
-(void)setShouldShowBackButton:(BOOL)shouldShowBackButton{
  //  self.shouldShowBackButton = shouldShowBackButton;
    
    if(shouldShowBackButton == true){
        UIImage *backButtonImage = [Icons sharedIcons].backButtonImage();
        UIImageView* backButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButtonImageView setImage:backButtonImage];
        [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
    self.navigationItem.leftBarButtonItem = back;
    
    [self.view layoutIfNeeded];
    }

}

//pass down to the view child
-(void)setWillHaveTabBar:(BOOL)willHaveTabBar{
    self.shoppingCartScreen.willHaveTabBar = willHaveTabBar;
}

-(BOOL)willHaveTabBar{
    return self.shoppingCartScreen.willHaveTabBar;
}

@end
