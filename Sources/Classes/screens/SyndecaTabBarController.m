//
//  SyndecaTabBarController.m
//  Syndeca iOS SDK
//
//  Created by Schell on 4/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//
//THIS IS THE MAIN SYNDECA NAVIGATION CONTROLLER

#import "SyndecaTabBarController.h"
#import "SyndecaRevealViewController.h"
#import "CatalogViewController.h"
#import "UIViewHelper.h"
#import "MasterConfiguration.h"
#import "FIRTrackProxy.h"
#import "WebViewController.h"
#import "Icons.h"
#import "NLS.h"
#import "ExternalLinkParams.h"
#import "FetchProxy.h"
#import "CatalogLinkDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "OfflineProxy.h"

@interface SyndecaTabBarController ()
/** Used to skip to a specific page after loading a catalog */
@property (readwrite) NSString* catalogLinkPage;
/** A stack of CatalogViewController that represent previous catalogs that have referred the user to the current catalog and page */
@property (readwrite) NSMutableArray* linkedCatalogStack;
@property (readwrite) UIActivityIndicatorView* indicatorView;

@end

@implementation SyndecaTabBarController

#pragma mark - Class Methods

static SyndecaTabBarController* __sharedController = nil;
+ (SyndecaTabBarController*)sharedController {
    if (! __sharedController) {
        __sharedController = [[SyndecaTabBarController alloc] init];
    }
    return __sharedController;
}

+ (void)setSharedController:(SyndecaTabBarController*)sharedController {
    __sharedController = sharedController;
}

#pragma mark - Defaults

- (UIActivityIndicatorView*)newIndicatorView {
    UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    return indicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.suspendReloadingPublications = NO;
    self.delegate = self;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.trackingPanel      = [[TrackingPanel alloc] init];
    self.rootPublicationController = [self newRootPublicationController];
    self.catalogController  = [self newCatalogController];
    self.guideController    = [self newGuideController];
    self.addToBagController = [self newAddToBagController];
    self.wishlistController = [self newWishlistController];
    self.wishlistController.willHaveTabBar = YES;
    self.webFavoritesController = [self newWebFavoritesController];
    self.webController      = [self newWebController];
    self.tocController      = [self newTOCController];
    self.scanShopController = [self newScanShopController];
    self.mailController     = [[MFMailComposeViewController alloc] init];
    self.mailController.mailComposeDelegate = self;

//WKProcessPool is vital to making sure webviews work - add to cart, favorites, saving data, etc.
    WKProcessPool* processPool = [[WKProcessPool alloc] init];
    self.processPool = processPool;

    UITableView *view = (UITableView *)self.moreNavigationController.topViewController.view;
    self.originalTabBarMoreControllerTableViewDelegate = view.delegate;
    view.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        [self.tabBar.standardAppearance configureWithOpaqueBackground];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    We must add a gesture recognizer to our "hamburger menu" reveal setup to allow for user interaction.
    SyndecaRevealViewController *revealController = self.revealViewController;
    [self.view addGestureRecognizer:revealController.tapGestureRecognizer];

    // When returning from the camera or other system view, this can cause a panic,
    // so we say not to load if we know that the user is using the camera.
    bool shouldLoad = self.suspendReloadingPublications == NO
      && (self.selectedViewController == nil || self.selectedViewController == self.rootPublicationController)
      && self.shouldShowGuide == NO;
    if (shouldLoad) {
        [self loadRootPublication];
    }

    self.suspendReloadingPublications = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Factories

- (ScanShopViewController*)newScanShopController {
    ScanShopViewController* retVal = [[[ScanShopViewController DIClass] alloc] init];
    return retVal;
}

- (ShoppingCartController*)newAddToBagController {
    ShoppingCartController* screen = [[ShoppingCartController alloc] init];
    screen.shoppingCartScreen.exportAction = ^(ShoppingCart* cart) {
        [self exportItemsFrom:cart];
    };
    return screen;
}


- (ShoppingCartController*)newWishlistController {
    @weakify(self);

    ShoppingCartController* screen = [[ShoppingCartController alloc] init];
    screen.willHaveTabBar = true;
    screen.productDetailViewDelegate = self;
    NSString* wishlistStr = [[NLS nls] stringFor:@"wishlist.title" default:@"*wishlist title*"];
    wishlistStr = @"Favorites";
    screen.tabBarItem.title = wishlistStr;
    screen.tabBarItem.image = [Icons sharedIcons].heartIconEmptyImage();
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

        NSString* wishlist =@"";
        [self.mailController setMessageBody:wishlist isHTML:YES];
        [self presentViewController:self.mailController animated:YES completion:^{}];
    };

    [screen.view layoutIfNeeded];
    return screen;
}

- (GuideViewController*)newGuideController {
    GuideViewController* g = [[GuideViewController alloc] init];
    g.itemSelectionDelegate = self;
    g.productDetailViewDelegate = self;
    return g;
}


- (CatalogViewController*)newRootPublicationController {
    CatalogViewController* c = [[CatalogViewController alloc] init];
    c.productDetailViewDelegate = self;
    c.catalogLinkDelegate = self;
    c.pagesController.leftButtonItemType = LeftButtonItemType_Hamburger;
    c.tabBarItem = [c homeTabBarItem];
    return c;
}

- (CatalogViewController*)newCatalogController {
    CatalogViewController* c = [[CatalogViewController alloc] init];
    c.productDetailViewDelegate = self;
    c.catalogLinkDelegate = self;
    c.pagesController.leftButtonItemType = LeftButtonItemType_Back;
    c.tabBarItem = [c pageTabBarItem];
    return c;
}

- (TOCController*)newTOCController {
    TOCController* toc = [[TOCController alloc] init];
    toc.itemSelectionDelegate = self;
    return toc;
}

- (WebNavigationController*)newWebController {
    NSURL* url = nil;
    if (IS_IPAD) {
        url = [MasterConfiguration sharedConfiguration].padBagUrl;
    } else {
        url = [MasterConfiguration sharedConfiguration].phoneBagUrl;
    }
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    WebViewController* wvc = [[WebViewController alloc] initWithRequest:req];
    wvc.shouldReloadOnViewDidAppear = true;
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    nc.tabBarItem = [[UITabBarItem alloc] initWithTitle:[MasterConfiguration sharedConfiguration].bagName image:[Icons sharedIcons].bagIconImage() tag:4];
    nc.tabBarItem.accessibilityLabel = @"web";
    return nc;
}

- (WebNavigationController*)newWebFavoritesController {
    NSURL* url = nil;
    if (IS_IPAD) {
        url = [MasterConfiguration sharedConfiguration].padBagUrl;
    } else {
        url = [MasterConfiguration sharedConfiguration].phoneBagUrl;
    }
    url = [NSURL URLWithString:@"https://www.chicos.com/store/checkout/cart.jsp"];
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    WebViewController* wvc = [[WebViewController alloc] initWithRequest:req];
    wvc.shouldReloadOnViewDidAppear = true;
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    nc.tabBarItem.title = @"Favorites";
    nc.tabBarItem.image = [Icons sharedIcons].heartIconImage();
    nc.tabBarItem.accessibilityLabel = @"web-favorites";
    return nc;
}

- (WebNavigationController*)newWebRequstQuoteControllers {
    NSURL* url = nil;
    url = [NSURL URLWithString:@"https://www.chicos.com/store/checkout/cart.jsp"];
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    WebViewController* wvc = [[WebViewController alloc] initWithRequest:req];
    wvc.shouldReloadOnViewDidAppear = true;
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    nc.tabBarItem.title = @"Favorites";
    nc.tabBarItem.image = [Icons sharedIcons].heartIconImage();
    nc.tabBarItem.accessibilityLabel = @"web-favorites";
    return nc;
}

#pragma mark - Convenience getters

- (NSArray*)allControllers {
    NSArray* cs = @[self.rootPublicationController, self.catalogController, self.wishlistController, self.tocController, self.webController];

    if (IS_DEBUG_ONLY) {
        cs = [@[self.trackingPanel] arrayByAddingObjectsFromArray:cs];
    }

    // Add the scan controller if we have an api key and secret
    if ([self.scanShopController scanShopAPIKey] != nil && [self.scanShopController scanShopAPISecret] != nil) {
        cs = [cs arrayByAddingObject:self.scanShopController];
    }

    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        cs = @[self.scanShopController];
    }
    return cs;
}

- (NSArray*)allControllersLessCatalog {
    NSMutableArray* cs = [[NSMutableArray alloc] initWithArray:[self allControllers]];
    [cs removeObject:self.catalogController];
    return [NSArray arrayWithArray:cs];
}


#pragma mark - UITabBarDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    int k = indexPath.row + 4;
    UITabBarItem* tabBarItem = self.viewControllers[k].tabBarItem;
    NSString* item = tabBarItem.title;
    if (item) {
        [[FIRTrackProxy sharedProxy] trackNavTap:item];
    }
    [self.originalTabBarMoreControllerTableViewDelegate tableView: tableView didSelectRowAtIndexPath: indexPath];

}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSString* title = item.title;
    if (title) {
        [[FIRTrackProxy sharedProxy] trackNavTap:title];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSString* item = viewController.tabBarItem.title;
    if (item) {
        [[FIRTrackProxy sharedProxy] trackNavTap:item];
    }

    if ([viewController isEqual:self.rootPublicationController]) {
        if (self.linkedCatalogStack && [self.linkedCatalogStack count]) {
            [self returnFromPublication];
        }
    } else if ([viewController isEqual:self.webController]) {
        UINavigationController* nc = [self newWebController];
        self.webController.viewControllers = nc.viewControllers;
    } else if ([[viewController class] isSubclassOfClass:[ScanShopViewController class]]) {
        NSAssert(viewController == self.scanShopController, @"selected scan shop view controller is not scanShopController");
    } else if ([viewController isEqual:self.tocController]) {
        [self.tocController loadPages:self.catalogController.catalogModel.pageModels];
        PageModel* page = self.catalogController.leftPageView.pageModel;
        [self.tocController showPageWithModel:page];
    }

}

#pragma mark - Loading a catalog
//Called by the itemSelectionDelegate, opens a catalog with an issue model. An issue model will contain catalog information. This is what get's called when a user selects an issue from the home page.
- (void)loadIssueWithModel:(IssueModel*)issueModel {
    [self loadIssueWithModel:issueModel andPage:nil];
}

- (void)loadIssueWithModel:(IssueModel*)issueModel andPage:(NSString*)page {
    self.catalogLinkPage = page;
    [self.catalogController setHasOnPageElementPanel:YES];
    [self setViewControllers:[self allControllers] animated:YES];
    [self.catalogController loadIssueWithModel:issueModel onComplete:^(CatalogModel *catalog) {
        [self.tocController loadPages:catalog.pageModels];
        [self.catalogController.pagesController setNavigationItems];
        if (self.catalogLinkPage != nil) {
            for (PageModel* pageModel in [catalog pageModels]) {
                if ([[pageModel pageNumberAsString] isEqualToString: self.catalogLinkPage]) {
                    NSUInteger pageNumber = [pageModel number];
                    if (pageNumber > 0) {
                        // openPage expects an index, not the page number
                        pageNumber = pageNumber - 1;
                    }
                    [self.catalogController openPage:pageNumber];
                    break;
                }
            }
        }
        self.catalogLinkPage = nil;
    }];
    self.selectedViewController = self.catalogController;
}

#pragma mark - Showing a loaded catalog
//Called by the didSelectResult method. Most often used to open a catalog from a page model that contains a valid catalog model.
- (void)showCatalog:(CatalogModel*)catalog {
    self.catalogController = [self newCatalogController];
    [self.catalogController setCatalogModel:catalog];

    [self setViewControllers:[self allControllers] animated:YES];
    self.selectedViewController = self.catalogController;
}

#pragma mark - Showing a page of the current catalog
//Called by the didSelectResult method. Called when a user selects a page number to be opened within the current catalog. This is an internal method only used by our tabbar.
- (void)inCurrentCatalogOpenPage:(NSInteger)index {
    self.viewControllers = [self allControllers];
    self.selectedViewController = self.catalogController;
    NSInteger ndx = index;
    // Constrain the index to left pages when showing spreads with a cover.
    if (IS_LANDSCAPE && !self.catalogController.catalogModel.extensions.usesSinglePages && (ndx > 0) && ((ndx % 2) == 0) && self.catalogController.catalogModel.extensions.hasCover) {
        ndx -= 1;
    }
    [self.catalogController openPage:ndx];
}

//Called by the didSelectResult method. Called when a user selects a page to be opened within the current catalog. This is an internal method only used by our tabbar.
- (void)inCurrentCatalogOpenPageWithModel:(PageModel*)page {
    CatalogModel* c = self.catalogController.catalogModel;
    NSArray* pages = c.pageModels;
    for (PageModel* pm in pages) {
        if ([pm.ID isEqualToString:page.ID]) {
            NSInteger i = [pages indexOfObject:pm];
            [self inCurrentCatalogOpenPage:i];
        }
    }
}

#pragma mark - Resetting
//This is called when a user selects the home button. We can controll the starting items in the tab bar here.
- (void)resetToGuide {
    NSArray* cs;
    if (IS_DEBUG_ONLY) {
        cs = @[self.trackingPanel, self.rootPublicationController];
    } else {
        cs = @[self.rootPublicationController];
    }


    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if(config.isShopCatalogs == true){
        cs = @[self.scanShopController];
        [self setViewControllers:cs animated:YES];
        self.selectedViewController = self.scanShopController;
    } else {
        [self setViewControllers:cs animated:YES];
        self.selectedViewController = self.rootPublicationController;
    }
}

- (void)loadRootPublication {
    self.indicatorView = [self newIndicatorView];
    self.indicatorView.center = self.rootPublicationController.view.center;
    [self.rootPublicationController.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    // We have to clear the cache so that remapping can occur.
    [FetchProxy clearProductModelCache];

    OfflineProxy* proxy = [[OfflineProxy alloc] init];
    [OfflineProxy setSharedProxy:proxy];

    @weakify(self);
    [[[FetchProxy fetchGuideModel] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(GuideModel* x) {
        @strongify(self);
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
        if(x.issueModels.count == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Publications Available"
                                                            message:@"Sorry, there are no publications available at this time. Please check back soon."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSArray* issues = [x issueModels];
            IssueModel* issue = [issues firstObject];
            [self setViewControllers:[self allControllersLessCatalog] animated:YES];
            [self.rootPublicationController loadIssueWithModel:issue];
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Publications Available"
                                                        message:@"Sorry, there was a network error."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];

    } completed:^{
        @strongify(self);
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        self.indicatorView = nil;
    }];
}

#pragma mark - Layout
- (CGRect)frameForToolbarContainer {
    CGRect frame = CGRectZero;
    frame.origin.y = 20;
    frame.size = [UIViewHelper screenSize];
    frame.size.height = 43;
    return frame;
}

- (CGRect)frameForToolbar {
    CGRect frame = CGRectZero;
    frame.origin.y = -1;
    frame.size = [UIViewHelper screenSize];
    frame.size.height = 44;
    return frame;
}

- (CGRect)frameForFauxbar {
    CGRect frame = CGRectZero;
    frame.origin.y = 0;
    frame.size = [UIViewHelper screenSize];
    frame.size.height = 20;
    return frame;
}

- (void)viewDidLayoutSubviews {
    self.toolbarContainer.frame = [self frameForToolbarContainer];
}

#pragma mark - Rotation
//We only allow rotation on iPad devices
- (BOOL)shouldAutorotate {
    return IS_IPAD;
}

#pragma mark - Cart

- (void)exportItemsFrom:(ShoppingCart*)cart {
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"Hey!"
                          message:@"This function is not set up for your app! "
                                  @"If you would like to use this function please "
                                  @"contact your friendly developer."
                          delegate:nil
                          cancelButtonTitle:@"Okay. I love that guy."
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - MailCompose Delegation
//Can compose an in-app email
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    NSLog(@"%s %i %@",__func__,result,error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self.mailController = [[MFMailComposeViewController alloc] init];
            self.mailController.mailComposeDelegate = self;
        }];
    });
}

#pragma mark - User Selection
//This is called when a user selects a page from a catalog or a catalog from a guide model. Will either then load that issue or open the page in the corresponding view controller.
- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    if (container == self.tocController && selection.selectionType == ItemSelectionTypePage) {
        PageModel* page = (PageModel*)selection.selection;
        [self inCurrentCatalogOpenPage:page.index];
    } else if (container == self.rootPublicationController && selection.selectionType == ItemSelectionTypePage){
        dispatch_async(dispatch_get_main_queue(), ^{
            PageModel* page = (PageModel*)selection.selection;
            [self showCatalog:page.catalog];
            [self inCurrentCatalogOpenPageWithModel:page];
        });
    } else if (container == self.guideController && selection.selectionType == ItemSelectionTypeIssue) {
        IssueModel* issue = (IssueModel*)selection.selection;
        [self loadIssueWithModel:issue];
    } else if ( selection.selectionType == ItemSelectionTypeLink) {
        ElementLinkModel* link = (ElementLinkModel*)selection.selection;
        if (link.linkType == LinkTypeExternal) {
            UrlModel* testUrl = link.URL;
            if ([testUrl isCatalogLink]) {
                // first get the catalog and the page of the catalog to link to
                NSString* catalog = [testUrl catalog];
                NSString* page = [testUrl page];
                [self linkToCatalog:catalog page:page];
            }
        }
    }
}

#pragma mark ScanShopResultsDelegate stuff

- (void)didDismissResultsController:(id)controller {}

//Called specifically when a user selects a product presented in the scan shop flow.
- (void)didSelectResult:(ScanShopResult *)result inResultController:(id)controller {
    switch (result.resultType) {
        case ScanShopResultTypePage: {
            dispatch_async(dispatch_get_main_queue(), ^{
                PageModel* page = result.page;
                [self showCatalog:page.catalog];
                [self inCurrentCatalogOpenPageWithModel:page];
            });
            break;
        }

        case ScanShopResultTypeLink: {
            dispatch_async(dispatch_get_main_queue(), ^{
            ElementLinkModel* link = (ElementLinkModel*)result.result;
            [self showCatalog:result.page.catalog];
            [self inCurrentCatalogOpenPageWithModel:result.page];
            });
            break;
        }

        default:
            break;
    }
}

#pragma mark ProductDetailViewSelection (updating the wishlist with product detail selection)
- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    if (result.resultType == ProductDetailViewResultTypeWishlist) {
        ShoppingCart* cart = (ShoppingCart*)result.result;

        BOOL shouldAddItem = true;
        for (id<HasID> item in [cart array]) {
            if([self checkIfCartContainsItem:item] == true){
                shouldAddItem = false;
            }
        }


        if(shouldAddItem == true){
             [self.wishlistController.shoppingCartScreen.shoppingCart addItemsFromCart:cart];
        }else{
            for (id<HasID> item in [cart array]) {
                if([self checkIfCartContainsItem:item] == true){
                    [self.wishlistController.shoppingCartScreen.shoppingCart removeItem:item];

                }
            }
        }
        [self.wishlistController didUpdateShoppingCart:self.wishlistController.shoppingCartScreen.shoppingCart];

    }
}

-(BOOL)checkIfCartContainsItem:(ProductGroupModel*)item {
    BOOL value = [self.wishlistController.shoppingCartScreen.shoppingCart itemIsFavorited:item];
    return value;
}

#pragma mark - Catalog link delegate

- (void)linkToCatalog:(NSString*)catalog page:(NSString*)page {
    // then find the issue model that matches the catalog name
    GuideModel* guide = [self.rootPublicationController catalogModel].guide;
    for (IssueModel* issue in [guide issueModels]) {
        if ([[issue key] isEqualToString: catalog]) {
            if (self.linkedCatalogStack == nil) {
                self.linkedCatalogStack = [[NSMutableArray alloc] init];
            }
            if ([self.catalogController catalogModel] != nil) {
                [self.linkedCatalogStack addObject:self.catalogController];
            }
            self.catalogController = [self newCatalogController];
            self.viewControllers = [self allControllers];
            self.suspendReloadingPublications = YES;
            [self loadIssueWithModel:issue andPage:page];
        }
    }
}

- (void)returnFromPublication {
    if (self.linkedCatalogStack && [self.linkedCatalogStack count]) {
        [self.linkedCatalogStack removeLastObject];
    }
    CatalogViewController* previousCatalog = [self.linkedCatalogStack lastObject];
    if (previousCatalog != nil) {
        self.viewControllers = [self allControllers];
        self.catalogController = previousCatalog;
        self.selectedViewController = self.catalogController;
    } else {
        self.selectedViewController = self.rootPublicationController;
        self.viewControllers = [self allControllersLessCatalog];
        self.catalogController = [self newCatalogController];
        self.suspendReloadingPublications = NO;
    }
}

- (void)returnToRootPublication {
    self.linkedCatalogStack = nil;
    self.selectedViewController = self.rootPublicationController;
    self.viewControllers = [self allControllersLessCatalog];
    self.catalogController = [self newCatalogController];
    self.suspendReloadingPublications = NO;
}

@end
