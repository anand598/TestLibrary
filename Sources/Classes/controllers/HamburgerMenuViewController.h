//
//  HamburgerMenuViewController.h
//  Pods
//
//  Created by Rijul Gupta on 3/10/17.
//
//
#import <UIKit/UIKit.h>
#import <SyndecaSDK/ShoppingCartController.h>
#import <SyndecaSDK/SyndecaTabBarController.h>
#import <SyndecaSDK/ProductGroupModel.h>
#import <MessageUI/MessageUI.h>


@interface HamburgerMenuViewController : UIViewController <DependencyInjection, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) UITableView *rearTableView;
@property (nonatomic, retain) UIView *syndecaFooterView;
@property (readwrite) MFMailComposeViewController* mailController;
@property (readwrite) SyndecaTabBarController* syndecaTabBarController;

- (void)sendEmail:(NSString *)headline;
- (void)didPressHeaderView:(id)sender;

#pragma mark Factories
- (ShoppingCartController*)newWishlistController;
- (ScanShopViewController*)newScanShopController;

@end
