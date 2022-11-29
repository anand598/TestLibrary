//
//  CatalogViewController.m
//  Pods
//
//  Created by Schell Scivally on 4/7/16.
//
//

#import "CatalogViewController.h"
#import "ProductDetailViewController.h"
#import "PublicationController.h"
#import "VerticalPublicationController.h"
#import "VerticalPageProductCellView.h"
#import "SearchViewController.h"
#import "SyndecaRevealViewController.h"
#import "MasterConfiguration.h"
#import "VariantModel.h"
#import "Icons.h"
#import "NLS.h"
#import "ElementLinkModel.h"
#import "PublicationCollectionViewLayout.h"
#import "FetchProxy.h"
#import "FIRTrackProxy.h"
#import "ProductCellView.h"
#import "WebViewController.h"
#import "PDPWebController.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewHelper.h"
#import "UIImageView+ContentScale.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <WebViewController.h>
#import <SyndecaSDK/SyndecaTabBarController.h>

@interface CatalogViewController ()
@property (readwrite) ProductDetailViewController* productDetailController;
@property (readwrite) PDPWebController* pdpWebController;
@property (readwrite) BOOL isCatalogLoading;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) UITableView* elementTableView;
@property (readwrite) UIView* verticalProductsHolder;
@property (readwrite) UIView* moreProductsArrowView;
@property (readwrite) UIView* moreProductsArrowBackgroundView;
@property (readwrite) UIImageView* moreProductsArrowImageView;
@property (readwrite) UICollectionView* verticalElementCollectionView;
@property (readwrite) UIView* toggleVerticalCVView;
@property (readwrite) BOOL hasElementPanel;
@end

@implementation CatalogViewController

#pragma mark VerticalProductHolder Design Constants
#define VERTICAL_CV_PRODUCT_WIDTH 108
#define VERTICAL_CV_PRODUCT_HEIGHT 164
#define VERTICAL_TOGGLEVIEW_HEIGHT 32
#define VERTICAL_CVLAYOUT_PADDING 6
#define HEIGHT_OF_TABBAR 0
BOOL verticalProductHolderIsToggling;
BOOL verticalProductHolderIsShowing;
BOOL verticalProductHolderIsClickAndDragging;
BOOL delegateIsScrolling;

- (id)init {
    self = [super init];
    if (self) {
        self.tabBarItem = [self pageTabBarItem];
       
        // Set up a PublicationController to display the actual pages of the catalog.
        // PublicationController is a CollectionViewController that does most of the UI/UX
        // layout. CatalogViewController handles most of the logic and uses the
        // PublciationController to display information.
        self.pagesController = [[[PublicationController DIClass] alloc]
                                initWithCollectionViewLayout:[self publicationCollectionLayoutWithinSize:CGSizeZero]];
        self.pagesController.productDetailViewDelegate = self;
        self.pagesController.itemSelectionDelegate = self;
        self.pagesController.searchViewControllerDelegate = self;
        self.pagesController.revealDelegate = self.delegate;
        self.pagesController.verticalProductsHolderToggleDelegate = self;
        self.viewControllers = @[self.pagesController];
        self.elementTableView = nil;
    }
    return self;
}

- (UITabBarItem*)pageTabBarItem {
    UITabBarItem* bookItem =
        [[UITabBarItem alloc]
         initWithTitle:@"Page"
                 image:[Icons sharedIcons].catalogIconImage()
                   tag:1
         ];
    bookItem.accessibilityLabel = @"Page";
    return bookItem;
}

- (UITabBarItem*)homeTabBarItem {
    NSString* home = [[NLS nls] stringFor:@"nav.home" default:@"Home"];
    UITabBarItem* guideItem = [[UITabBarItem alloc] initWithTitle:home
                                                            image:[Icons sharedIcons].homeIconImage()
                                                              tag:0];
    guideItem.accessibilityLabel = @"home";
    return guideItem;
}

- (void)initializeElementTableView {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    self.elementTableView = [[UITableView alloc] initWithFrame:[self frameForElementTableView]];
    self.elementTableView.contentInset = UIEdgeInsetsZero;
    self.elementTableView.alpha = 0;
    self.elementTableView.contentInset = config.productPanelContentInset;
    self.elementTableView.separatorColor = config.productPanelSeparatorColor;
    self.elementTableView.backgroundColor = config.productPanelBackgroundColor;
    [self.elementTableView registerClass:[ProductCellView class] forCellReuseIdentifier:[ProductCellView identifier]];
    [self.view addSubview:self.elementTableView];
}

#pragma mark Alloc the Vertical Page Element Collection View/Panel

- (void)initVerticalProductsHolder {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    // We set up a different UI/UX layout for VerticalProducts,
    // we don't use this and the elementTableView at the same time.
    UIView* holderView = [[UIView alloc] initWithFrame:CGRectZero];
    holderView.backgroundColor = config.toggleVerticalProductsBackgroundColor;
    self.verticalProductsHolder = holderView;
    self.verticalProductsHolder.alpha = 0.0;
    [self.pagesController.view addSubview:self.verticalProductsHolder];
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    CGSize size = self.view.frame.size;
    size.width = VERTICAL_CV_PRODUCT_WIDTH;
    size.height = VERTICAL_CV_PRODUCT_HEIGHT;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = size;
    layout.minimumLineSpacing = VERTICAL_CVLAYOUT_PADDING;
    layout.minimumInteritemSpacing = VERTICAL_CVLAYOUT_PADDING;
    
    self.verticalElementCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.verticalElementCollectionView.contentInset = UIEdgeInsetsZero;
    [self.verticalElementCollectionView registerClass:[VerticalPageProductCellView class] forCellWithReuseIdentifier:[VerticalPageProductCellView identifier]];
    self.verticalElementCollectionView.backgroundColor = [UIColor clearColor];
     [self.verticalProductsHolder addSubview:self.verticalElementCollectionView];
    
//    This view toggles the vertical products holder on and off.
    CGRect toggleViewFrame = CGRectMake(0, 0, self.view.frame.size.width, VERTICAL_TOGGLEVIEW_HEIGHT);
    UIView* toggleView = [[UIView alloc] initWithFrame:toggleViewFrame];
    UILabel* showProductsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    showProductsLabel.textColor = config.toggleVerticalProductsLabelColor;
    showProductsLabel.text = @"Show Products";
    
    [toggleView addSubview:showProductsLabel];
    [showProductsLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(toggleView.mas_centerX);
        make.centerY.equalTo(toggleView.mas_centerY).offset(-2);
    }];
    
    UIView* topBorder = [[UIView alloc] initWithFrame:CGRectZero];
    topBorder.backgroundColor = [UIColor blackColor];
    [showProductsLabel addSubview:topBorder];
    [topBorder mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(showProductsLabel.mas_centerX);
        make.top.equalTo(toggleView.mas_top);
        make.width.equalTo(toggleView.mas_width);
        make.height.equalTo(@1);
    }];
    
    self.toggleVerticalCVView = toggleView;
    
    UITapGestureRecognizer* toggleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleVerticalLayout)];
    [self.toggleVerticalCVView addGestureRecognizer:toggleTap];
    [self.toggleVerticalCVView setUserInteractionEnabled:false];
    [self.verticalProductsHolder addSubview:self.toggleVerticalCVView];
    
    //    Set up a UIPanGestureRecognizer to allow for "Click and Drag" functionality of the products holder view.
    UIPanGestureRecognizer * verticalProductsHolderClickDragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleVerticalProductHolderPan:)];
    verticalProductsHolderClickDragRecognizer.delegate = self;
    [self.verticalProductsHolder addGestureRecognizer:verticalProductsHolderClickDragRecognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0, 0, 40, 40);
    [self.view addSubview:self.indicatorView];
    
    if (self.hasElementPanel) {
        [self initVerticalProductsHolder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.topViewController == self.pagesController) {
        self.elementTableView.frame = [self rightFrameForElementTableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackButtonItem {
    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView* backButtonImageView = [[UIImageView alloc] initWithImage:backButtonImage];
    [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Reset the normal layout

- (void)setupNormalLayout {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pagesController.collectionView setPagingEnabled:YES];
        [self.pagesController.collectionView reloadData];
        self.verticalProductsHolder.alpha = 0.0;
    });
    
    if (self.elementTableView == nil) {
        [self initializeElementTableView];
    }
    [self.pagesController setElementPanelTableView:self.elementTableView];
    [self.pagesController setVerticalElementPanelCollectionView:nil];
}

#pragma mark - Vertical Page Element Collection View

- (void)setHasOnPageElementPanel:(BOOL)hasPanel {
    self.hasElementPanel = hasPanel;
}

//Removes regular horizontal page-by-page scroll and replaces with vertical scrolling layout
- (void)setupVerticalLayout {
    //set up vertical product holder toggle variables
    verticalProductHolderIsToggling = false;
    verticalProductHolderIsShowing = false;
    verticalProductHolderIsClickAndDragging = false;
    delegateIsScrolling = false;
    
    //remove the table view product holder used on tablets
    self.elementTableView = nil;
    [self.pagesController setElementPanelTableView:nil];
    
    if (self.hasElementPanel) {
        [self initVerticalProductsHolder];
        //set up our pages uicollectionview controller with our vertical products ui collection view
        [self.pagesController setVerticalElementPanelCollectionView:self.verticalElementCollectionView];
    } else {
        [self.verticalProductsHolder removeFromSuperview];
        self.verticalProductsHolder = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pagesController.collectionView setPagingEnabled:NO];
        [self.pagesController.collectionView reloadData];
        self.verticalProductsHolder.alpha = 1.0;
    });
    
    [self.toggleVerticalCVView setUserInteractionEnabled:true];
    [self setupVerticalProductsLayout];
}

-(void)setupVerticalProductsLayout{
    CGFloat top = self.pagesController.view.frame.size.height - VERTICAL_TOGGLEVIEW_HEIGHT
                                                              - HEIGHT_OF_TABBAR;
    CGFloat height = VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT
                                                + VERTICAL_CVLAYOUT_PADDING * 2;
    CGRect holderViewFrame = CGRectMake(0, top, self.pagesController.view.frame.size.width, height);
    CGRect cvFrame = CGRectMake(0, VERTICAL_TOGGLEVIEW_HEIGHT, self.pagesController.view.frame.size.width, VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2);
    CGRect toggleViewFrame = CGRectMake(0, 0, self.pagesController.view.frame.size.width, VERTICAL_TOGGLEVIEW_HEIGHT);
    
    
//    Set up frames for the right hand arrow that shows more products are available to scroll through
    CGFloat moreProductsWidth = 32.0;
    CGRect moreProductsArrowFrame = CGRectMake((self.pagesController.view.frame.size.width - moreProductsWidth), 0, moreProductsWidth, height);
    
    CGRect moreProductsArrowBackgroundFrame = CGRectMake(0, 0, moreProductsArrowFrame.size.width, moreProductsArrowFrame.size.height);
    
    CGFloat arrowSize = 24.0;
    CGRect moreProductsArrowImageFrame = CGRectMake((moreProductsWidth - arrowSize)/2.0, (height - arrowSize)/2.0, arrowSize, arrowSize);
    
    [self.verticalProductsHolder setFrame:holderViewFrame];
    [self.verticalElementCollectionView setFrame:cvFrame];
    [self.toggleVerticalCVView setFrame:toggleViewFrame];
    
//    [self.moreProductsArrowView setFrame:moreProductsArrowFrame];
//    [self.moreProductsArrowBackgroundView setFrame:moreProductsArrowBackgroundFrame];
//    [self.moreProductsArrowImageView setFrame:moreProductsArrowImageFrame];
}

-(void)toggleVerticalProductsHolderDown:(BOOL)isFromScroll{
    
    if(isFromScroll == true){
        delegateIsScrolling = true;
        if(verticalProductHolderIsClickAndDragging == true){
            return;
        }
    }
    CGFloat finalHolderHeight = self.pagesController.view.frame.size.height - (VERTICAL_TOGGLEVIEW_HEIGHT) - HEIGHT_OF_TABBAR;
    CGRect finalFrame = CGRectMake(0, finalHolderHeight, self.pagesController.view.frame.size.width, (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2));
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.verticalProductsHolder setFrame:finalFrame];
    }completion:^(BOOL finished) {
        verticalProductHolderIsToggling = !finished;
        verticalProductHolderIsShowing = false;
    }];
    
}

-(void)toggleVerticalProductsBounce{
    
    if(verticalProductHolderIsShowing == true){
        return;
    }
    CGFloat finalHolderUp = self.pagesController.view.frame.size.height - (VERTICAL_TOGGLEVIEW_HEIGHT) - HEIGHT_OF_TABBAR - 60;
    CGRect finalFrame = CGRectMake(0, finalHolderUp, self.pagesController.view.frame.size.width, (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2));
    
    
    [UIView animateWithDuration:0.20 animations:^{
        [self.verticalProductsHolder setFrame:finalFrame];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.20 animations:^{
            [self toggleVerticalProductsHolderDown:NO];
        }completion:^(BOOL finished) {
          
        }];
    }];
}

//We set our click and drag bool to false to allow the scrolling to close the product panel
-(void)finishedLoadingProducts{
    verticalProductHolderIsClickAndDragging = false;
    delegateIsScrolling = false;
}
-(void)toggleVerticalProductsHolderUp{
    if(verticalProductHolderIsToggling){
        return;
    }

        CGFloat finalHolderHeight = self.pagesController.view.frame.size.height - (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2) - HEIGHT_OF_TABBAR;
    
    CGRect finalFrame = CGRectMake(0, finalHolderHeight, self.pagesController.view.frame.size.width, (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2));
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.verticalProductsHolder setFrame:finalFrame];
    }completion:^(BOOL finished) {
        verticalProductHolderIsToggling = false;
        verticalProductHolderIsShowing = true;
    }];
}

-(void)toggleVerticalLayout{
    if(verticalProductHolderIsToggling){
        return;
    }
    
    CGFloat finalHolderHeight = self.pagesController.view.frame.size.height - (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2) - HEIGHT_OF_TABBAR;
    if(verticalProductHolderIsShowing){
        finalHolderHeight = self.pagesController.view.frame.size.height - (VERTICAL_TOGGLEVIEW_HEIGHT) - HEIGHT_OF_TABBAR;
    }
    
    CGRect finalFrame = CGRectMake(0, finalHolderHeight, self.pagesController.view.frame.size.width, (VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2));
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.verticalProductsHolder setFrame:finalFrame];
    }completion:^(BOOL finished) {
        verticalProductHolderIsToggling = !finished;
        verticalProductHolderIsShowing = !verticalProductHolderIsShowing;
    }];
}

-(void)toggleMoreProductsArrowShow {
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.moreProductsArrowView setAlpha:1.0];
//    }completion:^(BOOL finished) {
//    }];
}

-(void)toggleMoreProductsArrowHide {
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.moreProductsArrowView setAlpha:0.0];
//    }completion:^(BOOL finished) {
//    }];
}

- (IBAction)handleVerticalProductHolderPan:(UIPanGestureRecognizer *)recognizer {
    
//    We wait for any animations to finish
    if(verticalProductHolderIsToggling){
        return;
    }

    verticalProductHolderIsClickAndDragging = true;
//    Check the translation (change in y) and the top and bottom position of our holder. Top is less than Bottom.
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat finalTop = self.pagesController.view.frame.size.height - ((VERTICAL_CV_PRODUCT_HEIGHT + VERTICAL_TOGGLEVIEW_HEIGHT + VERTICAL_CVLAYOUT_PADDING*2))/2.0;
    CGFloat finalBottom = self.pagesController.view.frame.size.height + (VERTICAL_CV_PRODUCT_HEIGHT)/2.0 - VERTICAL_TOGGLEVIEW_HEIGHT/2.0 + VERTICAL_CVLAYOUT_PADDING;
    
//    If the user has ended, we want to force it either open or shut.
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat topThreshold = finalTop + (finalBottom - finalTop)/2.0;
        if(recognizer.view.center.y <= (topThreshold + 10)){
            [self toggleVerticalProductsHolderUp];
        } else {
             [self toggleVerticalProductsHolderDown:NO];
        }
        if(delegateIsScrolling == false){
            verticalProductHolderIsClickAndDragging = false;
        }
        
          return;
    }
    
//    We prevent dragging outside the boundaries.
    CGFloat movingThreshold = 25.0;
    if(recognizer.view.center.y <= (finalTop + movingThreshold) && translation.y < 0){
        [self toggleVerticalProductsHolderUp];
        return;
    }
    
    if(recognizer.view.center.y >= (finalBottom - movingThreshold) && translation.y > 0){
        [self toggleVerticalProductsHolderDown:NO];
        return;
    }
    
//    We set the new position and reset the translation
    recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}



#pragma mark - UICollectionViewLayout

- (UICollectionViewLayout*)publicationCollectionLayoutWithinSize:(CGSize)withinSize {
    if(self.catalogModel.isGrid){
        CGFloat padding = 10.0;
        if(IS_IPHONE){
            CGSize size = withinSize;
            size.width -= padding*2;
            CGFloat catalogHeight = self.catalogModel.pageSize.height;
            CGFloat catalogWidth = self.catalogModel.pageSize.width;
            size.height = floor((catalogHeight*size.width)/catalogWidth);
            
            UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = size;
            layout.minimumLineSpacing = padding;
            layout.minimumInteritemSpacing = padding;
            self.pagesController.collectionView.collectionViewLayout = layout;
            return layout;
        } else {
            CGFloat cellWidth = floor((withinSize.width - padding*4)/3.0);
            CGSize size = withinSize;
            size.width = cellWidth;
            CGFloat catalogHeight = self.catalogModel.pageSize.height;
            CGFloat catalogWidth = self.catalogModel.pageSize.width;
            size.height = floor((catalogHeight*size.width)/catalogWidth);
            UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = size;
            layout.minimumLineSpacing = padding;
            layout.minimumInteritemSpacing = padding;
            layout.sectionInset = UIEdgeInsetsMake(0.0, padding, 0, padding);
            self.pagesController.collectionView.collectionViewLayout = layout;
            return layout;
        }
    }
    
    //If the catalog model vertical flag is set true, we return a UICollectionViewFlowLayout to enable vertical scrolling.
    if(self.catalogModel.isVertical){
        CGSize size = [UIImageView aspectFitSize:self.catalogModel.pageSize
                                      insideSize:withinSize];

        // If the catalog model uses single pages flag is set to false, then this catalog shows two pages at a time.
        // We want to adjust our flow layout to reflect this.
        if (!self.catalogModel.extensions.usesSinglePages){
            size.width = size.width/2;
        }

        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        return layout;
    }
    
    PublicationCollectionViewLayout* layout = [[PublicationCollectionViewLayout alloc] init];
    if ([self.catalogModel.pageModels count]) {
        PageModel* cover = [self.catalogModel.pageModels firstObject];
        layout.imageSize = CGSizeMake(cover.width, cover.height);
        layout.hasCover = self.catalogModel.extensions.hasCover;
        layout.usesSinglePages = self.catalogModel.extensions.usesSinglePages;
    }
    return layout;
}

#pragma mark - Framing & Rotation for Tablet Product Element Table View

- (CGRect)rightFrameForElementTableView {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    return CGRectMake(self.view.bounds.size.width - config.productCellWidth,
                      65, config.productCellWidth,
                      self.view.bounds.size.height - 65);
}

- (CGRect)leftFrameForElementTableView {
    CGRect frame = [self rightFrameForElementTableView];
    frame.origin.x = 0;
    return frame;
}

- (CGRect)noFrameForElementTableView {
    CGRect frame = [self rightFrameForElementTableView];
    frame.origin.x = -(frame.size.width + 1);
    return frame;
}

- (CGRect)frameForElementTableView {
    if (self.topViewController == self.pagesController) {
        return [self rightFrameForElementTableView];
    }
    return [self leftFrameForElementTableView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Pages rotation
    NSArray* ndxes = [self.pagesController.collectionView.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath* ndx = [ndxes firstObject];
    if(self.catalogModel.isVertical){
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.pagesController.collectionView.collectionViewLayout;
        [layout setItemSize:[UIImageView aspectFitSize:self.catalogModel.pageSize insideSize:size]];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.pagesController.collectionView scrollToItemAtIndexPath:ndx atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.elementTableView.frame = [self frameForElementTableView];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if(self.catalogModel.isVertical){
            [self setupVerticalLayout];
        } else {
            [self setupNormalLayout];
        }
        [[self.pagesController.collectionView delegate] scrollViewDidEndDecelerating:self.pagesController.collectionView];
    }];

    // Product rotation
    if (self.productDetailController) {
        NSArray* productNdxes = [self.productDetailController.detailView.previewImages.indexPathsForVisibleItems
                                 sortedArrayUsingSelector:@selector(compare:)];
        NSIndexPath* productNdx = [productNdxes firstObject];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.productDetailController.detailView makeLayoutForSize:size];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.productDetailController.detailView.previewImages scrollToItemAtIndexPath:productNdx
                                                                          atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                                  animated:NO];
        }];
    }
}

- (NSTimeInterval)transitionTime {
    return 0.25;
}

#pragma mark - Showing/Hiding Products
 
- (void)showProductDetailsFor:(ProductGroupModel *)productGroupModel {
    [self showProductDetailsFor:productGroupModel withVariant:nil];
}
    
- (void)showProductDetailsFor:(ProductGroupModel*)productGroupModel withVariant:(VariantModel*)v {
    PageModel* pageModel = [self leftPageView].pageModel;
    
    //Check if we're continuing straight into the Web Product Detail Page
    MasterConfiguration* masterConfig = [MasterConfiguration sharedConfiguration];
    BOOL webPDP = masterConfig.shouldShowWebPDP;
    //If the top controller is already our saved instance of the WebPDP, then we deal directly with that controller.
    //Otherwise, if webPDP is true, we instanciate this controller and present on top of the stack
    if(self.topViewController == self.pdpWebController){
        NSUInteger ndx = 0;
        if (v) {
            ndx = [v indexInProductGroup];
        }
        [self.pdpWebController reloadDetailViewWithProductGroupModel:productGroupModel andVariantIndex:ndx];
        [FIRTrackProxy sharedProxy].productModel = productGroupModel;
        [[FIRTrackProxy sharedProxy] trackTapShopNow];
        return;
    } else if (webPDP == true){
        ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
        ProductGroupModel* productGroup = productGroupModel;
        result.resultType = ProductDetailViewResultTypeShopNow;
        NSURL* u = productGroup.url1;
        u = productGroup.url1_tracking;
        NSURLRequest* req = [NSURLRequest requestWithURL:u];
        PDPWebController* c = [[PDPWebController alloc] initWithRequest:req];
        c.productGroupModel = productGroup;
        [self setBackButtonItem];
        c.isVertical = self.catalogModel.isVertical;
        self.pdpWebController = c;
        [self pushViewController:self.pdpWebController animated:YES];
         [FIRTrackProxy sharedProxy].productModel = productGroupModel;
         [[FIRTrackProxy sharedProxy] trackTapShopNow];
        return;
    }
    
    if (self.topViewController == self.productDetailController) {
        NSUInteger ndx = 0;
        if (v) {
            ndx = [v indexInProductGroup];
        }
        [self.productDetailController reloadDetailViewWithProductGroupModel:productGroupModel andVariantIndex:ndx];
    } else {
        if (v) {
            self.productDetailController = [[ProductDetailViewController alloc] initWithPageModel:pageModel andProductGroupModel:productGroupModel andVariantModel:v];
        } else {
            self.productDetailController = [[ProductDetailViewController alloc] initWithPageModel:pageModel andProductGroupModel:productGroupModel];
        }
        self.productDetailController.productDetailViewDelegate = self;
        [self pushViewController:self.productDetailController animated:YES];
    }
}


- (void)hideProductDetails {
    [self popToViewController:self.pagesController animated:YES];
}

#pragma mark - Animate the On Page Element Table Transitions

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [UIView animateWithDuration:[self transitionTime] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (viewController == self.productDetailController) {
            self.elementTableView.frame = [self leftFrameForElementTableView];
        } else if (viewController == self.pdpWebController){
            self.elementTableView.frame = [self leftFrameForElementTableView];
        } else {
            self.elementTableView.frame = [self noFrameForElementTableView];
        }
    } completion:^(BOOL finished) { }];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    UIViewController* viewController = [super popViewControllerAnimated:animated];
    [UIView animateWithDuration:[self transitionTime] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.topViewController == self.pagesController) {
            self.elementTableView.frame = [self rightFrameForElementTableView];
        } else if (self.topViewController == self.productDetailController) {
            self.elementTableView.frame = [self leftFrameForElementTableView];
        } else if (self.topViewController == self.pdpWebController) {
            self.elementTableView.frame = [self leftFrameForElementTableView];
        }
    } completion:^(BOOL finished) { }];
    return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    if (viewController == self.pagesController) {
        self.elementTableView.frame = [self rightFrameForElementTableView];
    } else if (viewController == self.productDetailController) {
        self.elementTableView.frame = [self leftFrameForElementTableView];
    } else if (viewController == self.pdpWebController && config.shouldShowWebPDP == true){
        self.elementTableView.frame = [self leftFrameForElementTableView];
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - CatalogScreenController Protocol

- (NSArray *)visiblePageModels {
    return [self.pagesController visiblePageModels];
}

- (PageView*)leftPageView {
    return [self.pagesController leftPageView];
}

- (PagePanelState*)pagePanelState {
    return [self.pagesController elementPanelDataProvider];
}

- (void)loadIssueWithModel:(IssueModel*)issueModel onComplete:(void (^)(CatalogModel*))complete {
    if (self.isCatalogLoading) {
        return;
    }
    [self setCatalogModel:nil];
    LeftButtonItemType leftBarButtonType = self.pagesController.leftButtonItemType;
    PublicationController *pc = [[[PublicationController DIClass] alloc]
                                 initWithCollectionViewLayout:[self publicationCollectionLayoutWithinSize:self.view.frame.size]];
    pc.leftButtonItemType = leftBarButtonType;
    pc.productDetailViewDelegate = self;
    pc.itemSelectionDelegate = self;
    pc.searchViewControllerDelegate = self;
    pc.revealDelegate = self.delegate;
    pc.backButtonDelegate = self;
    pc.verticalProductsHolderToggleDelegate = self;
    self.pagesController = pc;
    self.viewControllers = @[self.pagesController];
    [self.pagesController.view addSubview:self.verticalProductsHolder];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    self.pagesController.navigationItem.rightBarButtonItem = item;
    
    [self.indicatorView startAnimating];
    self.isCatalogLoading = YES;
    
    RACSignal* loading = [[FetchProxy fetchCatalogModelUsingIssueModel:issueModel] deliverOn:[RACScheduler mainThreadScheduler]];
    
    @weakify(self);
    [loading subscribeNext:^(CatalogModel* catalogModel) {
        @strongify(self);
        [self setCatalogModel:catalogModel];
        [[FIRTrackProxy defaultProxy] setCatalogModel:catalogModel];
        [[FIRTrackProxy defaultProxy] trackViewCatalog];
        
        [FIRTrackProxy sharedProxy].catalogModel = catalogModel;
        [FIRTrackProxy sharedProxy].pageModels = catalogModel.pageModels;
        [[FIRTrackProxy sharedProxy] trackViewPage];
        
        if (complete != nil) {
            complete(catalogModel);
        }
    }];
}

- (void)loadIssueWithModel:(IssueModel*)issueModel {
    return [self loadIssueWithModel:issueModel onComplete:nil];
}

- (void)openPage:(NSUInteger)index {
    [self.pagesController openPageWithIndexNumber:@(index)];
    [self popToViewController:self.pagesController animated:YES];
}

- (void)swipeToNext {
    [self.pagesController swipeToNext];
}

- (CatalogModel*)catalogModel {
    return _catalogModel;
}

- (void)setCatalogModel:(CatalogModel *)catalogModel {
    [self.indicatorView stopAnimating];
    [self.pagesController setNavigationItems];
    _catalogModel = catalogModel;
    self.isCatalogLoading = NO;
   self.pagesController.collectionView.collectionViewLayout = [self publicationCollectionLayoutWithinSize:self.view.frame.size];
    //fixes disappearing cell bugs in iOS 10 +
    //Stops Catalog Page Image View from preloading if set to NO
    //Fixed disappearing images without setPrefetchingEnabled:NO by editing cellDidEndDisplay
    if([self.pagesController.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]){
      //  [self.pagesController.collectionView setPrefetchingEnabled:NO];
    }
    
    //If the catalog model vertical flag is true, we set up the vertical layout
    //This is done without Masonry so we can achieve layout in a thread-safe manor
    if(self.catalogModel.isVertical == true || self.catalogModel.isGrid == true){
        [self setupVerticalLayout];
    } else {
        [self setupNormalLayout];
    }
    [self.pagesController setCatalogModel:catalogModel];
}

#pragma mark - ItemSelectionDelegate Protocol

- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    switch (selection.selectionType) {
        case ItemSelectionTypeProduct: {
            ProductGroupModel* productGroup = (ProductGroupModel*)selection.selection;
            [self showProductDetailsFor:productGroup];
            break;
        }
        case ItemSelectionTypeVariant: {
            VariantModel* v = (VariantModel*)selection.selection;
            ProductGroupModel* pg = v.productGroup;
            [self showProductDetailsFor:pg withVariant:v];
            break;
        }
            
        case ItemSelectionTypeLink: {
            ElementLinkModel* link = (ElementLinkModel*)selection.selection;
            if (link.linkType == LinkTypeExternal) {
                UrlModel* testUrl = link.URL;
                if ([testUrl isCatalogLink]) {
                    // first get the catalog and the page of the catalog to link to
                    NSString* catalog = [testUrl catalog];
                    NSString* page = [testUrl page];
                    // then send it to the delegate
                    [self.catalogLinkDelegate linkToCatalog:catalog page:page];
                } else {
                    NSURL* url = [testUrl asURL];
                    NSURLRequest* req = [NSURLRequest requestWithURL:url];
                    WebViewController* vc = [[WebViewController alloc] initWithRequest:req];
                    vc.shouldReloadOnViewDidAppear = false;
                    vc.shouldShowBackButton = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SyndecaTabBarController sharedController].suspendReloadingPublications = YES;
                        [self pushViewController:vc animated:YES];
                    });
                }
            } else if (link.linkType == LinkTypeInternal) {
                NSInteger page = link.page;
                [self openPage:page];
            }
            break;
        }
            
        default: {
            NSLog(@"unhandled selection of item type");
            break;
        }
    }
}

- (void)itemContainer:(id)container didPressShopNowSelection:(ItemSelection *)selection {
    switch (selection.selectionType) {
        case ItemSelectionTypeProduct: {
            ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
            ProductGroupModel* productGroup = (ProductGroupModel*)selection.selection;
            result.result = [MasterConfiguration choose:productGroup or:productGroup.firstEntity];
            result.resultType = ProductDetailViewResultTypeShopNow;
            NSURL* u = productGroup.url1;
            u = productGroup.url1_tracking;
            NSURLRequest* req = [NSURLRequest requestWithURL:u];
            PDPWebController* c = [[PDPWebController alloc] initWithRequest:req];
            c.productGroupModel = productGroup;
            NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
            UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png" inBundle:bundle compatibleWithTraitCollection:nil];
            UIImageView* backButtonImageView = [[UIImageView alloc] initWithImage:backButtonImage];
            [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
            UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
            self.navigationItem.leftBarButtonItem = back;
            [self pushViewController:c animated:YES];
            [FIRTrackProxy sharedProxy].productModel = productGroup;
             [[FIRTrackProxy sharedProxy] trackTapShopNow];
            break;
            
           
        }
        default: {
            NSLog(@"unhandled selection of item type");
            break;
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



#pragma mark - Navigation Handling Delegate Methods
//
//- (void)shouldRevealToggle{
//    SyndecaRevealViewController* revealController = [[SyndecaRevealViewController alloc] revealViewController];
//    [revealController performSelector:@selector(revealToggle:)];
//}
//

- (void)didTapBack:(id)back {
    if (self.catalogLinkDelegate && [self.catalogLinkDelegate respondsToSelector:@selector(returnFromPublication)]) {
        [self.catalogLinkDelegate returnFromPublication];
    }
}

#pragma mark - Searching

//This allows for searching from within the CatalogViewController, currently overriden elsewhere
//- (void)showSearch:(id)sender{
//    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(100, 200);
//    layout.minimumLineSpacing = 5;
//    layout.minimumInteritemSpacing = 5;
//    
//    SearchViewController* c = [[SearchViewController alloc] initWithCollectionViewLayout:layout];
//    [c.view setFrame:CGRectMake(0, 72.0, self.view.frame.size.width, self.view.frame.size.height - 72.0)];
//    c.productDetailViewDelegate = self;
//    c.itemSelectionDelegate = self;
//    c.searchViewControllerDelegate = self;
//    c.catalog = self.catalogModel;
//        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:c];
//        [self presentViewController:nav animated:YES completion:^{
//            [self.pagesController setNavigationItems];
//        }];
//}

- (void)cancelSearch:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{ }];
    });
}

@end
