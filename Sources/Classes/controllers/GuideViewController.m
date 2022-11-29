//
//  GuideViewController.m
//  Pods
//
//  Created by Schell Scivally on 4/11/16.
//
//

#import "GuideViewController.h"
#import "UINavigationController+CompletionHandler.h"
#import "PublicationCollectionViewController.h"
#import "SearchViewController.h"
#import "NLS.h"
#import "Icons.h"
#import "Fonts.h"
#import "FIRTrackProxy.h"
#import "FetchProxy.h"
#import "OfflineProxy.h"
#import "UIViewHelper.h"
#import "MasterConfiguration.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface GuideViewController ()

@property (readwrite) UILabel* shopCatalogsLabel;
@property (readwrite) UIActivityIndicatorView* indicatorView;

@end

@implementation GuideViewController


- (id)init {
    self = [super init];
    if (self) {
        self.guideModel = nil;
        self.guideLayout = GuideLayout_Automatic;
        _isLoaded = NO;
        _isLoading = NO;
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isLoaded {
    return _isLoaded;
}

- (BOOL)isLoading {
    return _isLoading;
}

- (UICollectionViewFlowLayout*)publicationsLayout {
    CGSize size = self.view.frame.size;
    //set up the publications layout for iPad devices in portrait
    //we want to show three catalogs in each row, so we divide the screen width/3.0 and subtract an offset. We then just adjust the height by a ratio - the vertical scrolling counteracts the banner bar offset
    CGFloat cols = 3.0;
    if (IS_IPHONE) {
        cols = 2.0;
    }
    CGSize iPadPortraitSize = CGSizeMake(self.view.frame.size.width/cols-9, 1);
    iPadPortraitSize.height = iPadPortraitSize.width*(4.0/3.0) + 28;
    if(self.guideLayout == GuideLayout_Grid || (self.guideLayout == GuideLayout_Automatic && IS_IPAD)) {
        UICollectionViewFlowLayout* iPadPortraitLayout = [[UICollectionViewFlowLayout alloc] init];
        iPadPortraitLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        iPadPortraitLayout.itemSize = iPadPortraitSize;
        iPadPortraitLayout.minimumLineSpacing = 12;
        iPadPortraitLayout.minimumInteritemSpacing = 9;
        return iPadPortraitLayout;
    }

    //set up the publications layout for iPhone devices
    //we subtract 150 pixels for the top banner and Title
    //these are set in the master config
    size.height -= 180;
    
    //subtract the right and left padding from the width
    size.width -= 20;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = size;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;

    if(self.shouldShowVerticalPublicationsLayout){
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        size.height = self.view.frame.size.width;
        
        CGFloat verticalPublicationsLayoutHeightOffset = [[MasterConfiguration sharedConfiguration] verticalPublicationsLayoutHeightOffset];
        size.height += verticalPublicationsLayoutHeightOffset;
        layout.itemSize = size;
        layout.minimumLineSpacing = 32;
        layout.minimumInteritemSpacing = 32;
    }
    
    return layout;
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSArray* ndxes = [self.publicationsController.collectionView.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath* ndx = [ndxes firstObject];
    NSLog(@"%s %@",__func__,ndx);
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.publicationsController.collectionView setCollectionViewLayout:[self publicationsLayout]];
        [self.publicationsController.collectionView scrollToItemAtIndexPath:ndx atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {}];
}

#pragma mark - Loading

- (void)viewDidLoad {
    self.shouldShowVerticalPublicationsLayout = YES;
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0, 0, 40, 40);
    
    self.publicationsController = [[PublicationCollectionViewController alloc] initWithCollectionViewLayout:[self publicationsLayout]];
    self.publicationsController.collectionView.contentInset =  UIEdgeInsetsMake(25,0,0,0);
    self.publicationsController.itemSelectionDelegate = self;
    self.publicationsController.collectionView.pagingEnabled = NO;
    if (IS_IPHONE && self.guideLayout == GuideLayout_Grid) {
        self.publicationsController.titleFont = [Fonts fontType:FontTypeNormal withSize:FontSizeMedium];
    }
    if(self.shouldShowVerticalPublicationsLayout){
        [self.publicationsController setVerticalLayout];
    }
    
    
    //fixes disappearing cell bugs in iOS 10 +
    if([self.publicationsController.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]){
        [self.publicationsController.collectionView setPrefetchingEnabled:NO];
    }
    
    [self setViewControllers:@[self.publicationsController] animated:YES];
    
    NSString* home = [[NLS nls] stringFor:@"nav.home" default:@"Home"];
    UITabBarItem* guideItem = [[UITabBarItem alloc] initWithTitle:home
                                                            image:[Icons sharedIcons].homeIconImage()
                                                              tag:0];
    guideItem.accessibilityLabel = @"home";
    self.tabBarItem = guideItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.publicationsController.collectionView.collectionViewLayout = [self publicationsLayout];
    CGPoint offset = self.publicationsController.collectionView.contentOffset;
    offset.x = 0;
    self.publicationsController.collectionView.contentOffset = offset;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self setNavigationItems];
    if (![self isLoading]) {
        //[self reloadGuide];
        [self shouldReloadGuide];
    }
}


#pragma mark - Navigation Items

- (void)setNavigationItems {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.publicationsController.navigationItem.titleView = nil;
        self.publicationsController.navigationItem.leftBarButtonItems = nil;
        self.publicationsController.navigationItem.rightBarButtonItems = nil;
    });
    
    //    
    //    SearchViewController* c = [[SearchViewController alloc] initWithCollectionViewLayout:layout];
    //    c.productDetailViewDelegate = self;
    //    c.itemSelectionDelegate = self;
    //    c.issueModels = self.guideModel.issueModels;
    //    IssueModel* issue = self.guideModel.issueModels.firstObject;
    //    ItemSelection* selection = [[ItemSelection alloc] init];
    //    selection.selection = issue;
    //    selection.selectionType = ItemSelectionTypeIssue;
    //    
    
    
    NSArray* rightItems = @[];
    UIImage *searchImage = [Icons sharedIcons].searchIconImage();
    //    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearch:)];
    //    [search setImageInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
    UIButton* searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [searchButton setBackgroundImage:searchImage forState:UIControlStateNormal];
    [searchButton addTarget:self.delegate action:@selector(showSearch:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem* searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    rightItems = [rightItems arrayByAddingObject:searchBarButton];
    
    
    
    UIBarButtonItem* indicator = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    
    
    //    rightItems = [rightItems arrayByAddingObject:indicator];
    
    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    
    //Add a custom image hamburger button
    UIImage *hamButtonImage = [Icons sharedIcons].hamburgerMenuImage();
    UIButton* hamButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -20, 28, 28)];
    [hamButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
    [hamButton addTarget:self.delegate action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    hamButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:hamButton];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.publicationsController.navigationItem.leftBarButtonItem = hamBarButton;
        self.publicationsController.navigationItem.titleView = titleView;
        self.publicationsController.navigationItem.rightBarButtonItems = rightItems;
        [self.publicationsController.navigationController.navigationBar setTranslucent:NO];
    });
    
    
}

- (BOOL)shouldReloadGuide{
    if(self.guideModel.issueModels == nil){
        [self reloadGuide];
        return true;
    }
    [[[FetchProxy fetchGuideHeader] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(RACTuple* x) {
        
        //We get the HEAD Response
        NSHTTPURLResponse *response2 = x.first;
        
        //We parse this value to find the last modified date
        NSDictionary *dictionary = [response2 allHeaderFields];
        NSString *lastUpdated = [dictionary valueForKey:@"Last-Modified"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
        
        NSDate *lastUpdatedServer = [formatter dateFromString:lastUpdated];
        
        //We get the last time we reloaded data
        NSDate *lastReloadedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"reloadCatalogDate"];
        
        
        //If there is no value for our stored date, we reload the data and set today's date as the most recent reload date.
        if(!lastReloadedDate){
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"reloadCatalogDate"];
            [self reloadGuide];
            return;
        }
        
        
        //If the last time the catalog was updated is later then the last time we reloaded date, then we need to reload the catalog
        
        if([lastUpdatedServer compare:lastReloadedDate] == NSOrderedDescending){
            [self reloadGuide];
        }
        
        
        
        //Otherwise, we do nothing
        NSLog(@"DID JUST LOAD!");
        
        
    } error:^(NSError *error) {
        //If there is any error, we reload the catalog
        NSLog(@"RELOAD GUIDE ERROR");
        NSLog(@"%@", error);
        [self reloadGuide];
    } completed:^{
        NSLog(@"Did complete catalog HEAD request");
    }];
    
    return false;
}

- (void)reloadGuide {
    [ProductGroupModel setIsScanAndShop:NO];
    
    // We have to clear the cache so that remapping can occur.
    [FetchProxy clearProductModelCache];
    
    
    OfflineProxy* proxy = [[OfflineProxy alloc] init];
    [OfflineProxy setSharedProxy:proxy];
    
    _isLoaded = NO;
    _isLoading = YES;
    [self.indicatorView startAnimating];
    
    @weakify(self);
    [[[FetchProxy fetchGuideModel] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(GuideModel* x) {
        @strongify(self);
        self.guideModel = x;
        [self.publicationsController setPublications:self.guideModel.issueModels];
        [self.indicatorView stopAnimating];
        [self.publicationsController.collectionView flashScrollIndicators];
        
        if(self.guideModel.issueModels.count == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Publications Available"
                                                            message:@"Sorry, there are no publications available at this time. Please check back soon."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } error:^(NSError *error) {
        _isLoaded = NO;
        _isLoading = NO;
    } completed:^{
        _isLoaded = YES;
        _isLoading = NO;
    }];
}

#pragma mark - User Selection

- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    switch (selection.selectionType) {
        case ItemSelectionTypeUnknown: {
            [self dismissViewControllerAnimated:YES completion:^{ }];
            break;
        }
        default:{
            // Proxy up the chain!
            if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
                [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
            }
        }
            
    }
}

#pragma mark - Handling selection results in child ProductDetailView (handling wishlist selection bubbling for tabbaritem badges)

- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(productDetailView:didSelectResult:)]) {
        [self.productDetailViewDelegate productDetailView:view didSelectResult:result];
    }
}

-(BOOL)checkIfCartContainsItem:(ProductGroupModel*)item{
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(checkIfCartContainsItem:)]) {
        return [self.productDetailViewDelegate checkIfCartContainsItem:item];
    }
    return false;
}

#pragma mark - Search

- (UITextField*)newSearchField {
    
    CGFloat width = self.view.frame.size.width - 80 - 20;
    UITextField* t = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
    t.tag = [@"search text" hash];
    t.font = [Fonts fontType:FontTypeNormalLight withSize:FontSizeBig];
    t.font = [UIFont fontWithName:[Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium].fontName size:([Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium].pointSize + 4)];
    t.text = @"Search for Products";
    t.textColor = [UIColor colorWithRed:(212.0/255.0) green:(212.0/255.0) blue:(212.0/255.0) alpha:1.0];
    t.keyboardType = UIKeyboardTypeDefault;
    
    t.leftViewMode = UITextFieldViewModeAlways;
    UIImage *searchIcon = [Icons sharedIcons].searchIconImage();
    UIImageView* leftView = [[UIImageView alloc] initWithImage:searchIcon];
    leftView.frame = CGRectMake(0.0, 0.0, 32.0, 22.0);//extra width adds padding with aspect fit
    leftView.contentMode = UIViewContentModeScaleAspectFit;
    t.leftView = leftView;
    
    t.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    t.backgroundColor = [UIColor whiteColor];
    t.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]
                           CGColor];
    t.layer.borderWidth = 1;
    t.layer.cornerRadius = 4;
    return t;
}

- (UIBarButtonItem*)newSearchItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                         target:self
                                                         action:@selector(startSearch:)];
}

- (void)showSearch:(id)sender {
    UITextField* searchField = [self newSearchField];
    searchField.delegate = self;
    UIBarButtonItem* searchItem = [self newSearchItem];
    
    
    
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    UIBarButtonItem* search = [[UIBarButtonItem alloc] initWithCustomView:searchField];
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:[[NLS nls] stringFor:@"share.cancelText" default:@"Cancel"]
                                                               style:UIBarButtonItemStyleDone
                                                              target:self action:@selector(cancel:)];
    [cancel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Helvetica-Light" size:18.0], NSFontAttributeName,
                                    [MasterConfiguration sharedConfiguration].cancelButtonColor, NSForegroundColorAttributeName,
                                    nil]
                          forState:UIControlStateNormal];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.publicationsController.navigationItem.titleView = nil;
        self.publicationsController.navigationItem.leftBarButtonItems = nil;
        self.publicationsController.navigationItem.rightBarButtonItems = nil;
        [self.publicationsController.navigationItem setLeftBarButtonItems:@[search, space] animated:YES];
        [self.publicationsController.navigationItem setRightBarButtonItem:cancel animated:YES];
    });
}

#pragma mark - Text Input
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:@"Search for Products"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            textField.text = @"";
            textField.textColor = [UIColor colorWithRed:(120.0/255.0) green:(120.0/255.0) blue:(120.0/255.0) alpha:1.0];
        });
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self openSearchControllerWithString:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField resignFirstResponder];
    });
    return YES;
}

-(void)openSearchControllerWithString:(NSString*)string{
    if([string  isEqual: @""]){
        [self setNavigationItems];
        return;
    }
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 200);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    SearchViewController* c = [[[SearchViewController DIClass] alloc] initWithCollectionViewLayout:layout];
    IssueModel* issue = self.guideModel.issueModels.firstObject;
    c.issueModels = self.guideModel.issueModels;
    ItemSelection* selection = [[ItemSelection alloc] init];
    selection.selection = issue;
    selection.selectionType = ItemSelectionTypeIssue;
    
    RACSignal* loading = [[FetchProxy fetchCatalogModelUsingIssueModel:issue] deliverOn:[RACScheduler mainThreadScheduler]];
    [loading subscribeNext:^(CatalogModel* catalogModel) {
        c.catalog = catalogModel;
        [c searchWithText:string inCatalog:c.catalog];
        c.productDetailViewDelegate = self;
        c.itemSelectionDelegate = self;
        c.searchViewControllerDelegate = self;
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:c];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self completionhandler_pushViewController:c animated:YES completion:^{
                [self setNavigationItems];
            }];
        });
    }];
}

- (void)cancel:(id)sender{
    [self setNavigationItems];
}

@end
