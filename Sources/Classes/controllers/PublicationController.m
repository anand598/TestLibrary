//
//  CatalogPhoneViewController.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/14/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "PublicationController.h"
#import "WebViewController.h"
#import "UIViewHelper.h"
#import "Icons.h"
#import "Fonts.h"
#import "SortsAndFilters.h"
#import "PolyPageView.h"
#import "VerticalPageView.h"
#import "VariantModel.h"
#import "NLS.h"
#import "ShareProxy.h"
#import "FIRTrackProxy.h"
#import "FetchProxy.h"
#import "MasterConfiguration.h"
#import "SearchViewController.h"
#import "NetworkStatusObserver.h"
#import "ProductCellView.h"
#import "VerticalPageProductCellView.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIImageView+AFNetworking.h"
#import "SyndecaAlertView.h"
#import "LeftAndRightShareable.h"
#import "UINavigationController+CompletionHandler.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIImage+SyndecaSDK.h"
#import <SyndecaSDK/UrlModel.h>

@interface PublicationController ()

@end

@implementation PublicationController

SYNTHESIZE_DI

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.leftButtonItemType = LeftButtonItemType_Hamburger;
        self.navigationItem.leftItemsSupplementBackButton = YES;
        _catalogModel = nil;
        self.edgesForExtendedLayout = UIRectEdgeNone;
 
        // Add the page share dialog toolbar item.
        self.pagesShareBarButtonItem = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                        target:self
                                        action:@selector(sharePages)];
        
        // This overwrites the global tab bar icon color settings.
        // self.pagesShareBarButtonItem.tintColor = [UIColor blackColor];
        self.pagesShareBarButtonItem.accessibilityLabel = @"item-share-page";
    }
    return self;
}

#pragma mark - View Controller Standards

- (void)viewDidLoad {
    self.view.multipleTouchEnabled = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"page"];
    //fixes disappearing cell bugs in iOS 10 +
    //Stops Catalog Page Image View from preloading if set to NO
    //Fixed disappearing images without setPrefetchingEnabled:NO by editing cellDidEndDisplay
    if([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]){
     //   [self.collectionView setPrefetchingEnabled:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resetAllPagesWhenLeavingView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    
//    We setup the elementTableView and verticalCollectionView holders in the CatalogViewController
    if(self.elementTableView){
        NSIndexPath*    selection = [self.elementTableView indexPathForSelectedRow];
        if (selection) {
            [self.elementTableView deselectRowAtIndexPath:selection animated:YES];
        }
    }
    if(self.verticalElementCollectionView){
        NSIndexPath* selection = [[self.verticalElementCollectionView indexPathsForSelectedItems] firstObject];
        if (selection) {
            [self.verticalElementCollectionView deselectItemAtIndexPath:selection animated:YES];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNavigationItems];
    if (self.elementTableView) {
        self.elementTableView.contentInset = UIEdgeInsetsMake(0, 0, 46, 0);
        self.elementTableView.backgroundColor = [UIColor colorWithRed:(248.0/255.0) green:(248.0/255.0) blue:(248.0/255.0) alpha:0.9];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(self.catalogModel != nil){
            if(self.catalogModel.isVertical == false){
                [self loadProducts];
            } else {
//               We don't load products if we're on a vertical catalog.
            }
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getters

- (CatalogModel*)catalogModel {
    return _catalogModel;
}

- (NSArray*)visiblePageModels {
    NSArray* ndxes = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    NSArray* pages = @[];
    for (NSIndexPath* path in ndxes) {
        PageModel* page = [_catalogModel.pageModels objectAtIndex:path.row];
        pages = [pages arrayByAddingObject:page];
    }
    return pages;
}

- (PolyPageView*)polyPageView {
    NSArray* paths = self.collectionView.indexPathsForVisibleItems;
    if (paths.count >= 1) {
        NSIndexPath* path = paths[0];
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:path];
        if (cell) {
            PolyPageView* view = [cell viewWithTag:[@"page" hash]];
            return view;
        }
    }
    return nil;
}

- (PageView*)leftPageView {
    if (IS_IPAD) {
        NSArray* paths = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
        NSIndexPath* path = [paths firstObject];
        if (path) {
            UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:path];
            if (cell) {
                return (PageView*)[cell viewWithTag:[@"page" hash]];
            }
        }
    }
    return [self polyPageView].pageView;
}

- (PagePanelState*)elementPanelDataProvider {
    
    if(self.catalogModel.isVertical){
        return _elementPanelDataProvider;
    }
    
    if (IS_IPAD) {
        return _elementPanelDataProvider;
    }
    
    
    PolyPageView* view = [self polyPageView];
    return view.elementTableDataProvider;
}

- (BOOL)hasVisibleOnPageElements {
    if (self.elementTableView == nil) {
        return NO;
    }
    NSUInteger sections = [self numberOfSectionsInTableView:self.elementTableView];
    NSUInteger n = 0;
    for (int i = 0; i < sections; i++) {
        n += [self tableView:self.elementTableView numberOfRowsInSection:i];
    }
    return n >= 1;
}

#pragma mark - Setters

- (void)setCatalogModel:(CatalogModel*)catalogModel {
    _catalogModel = nil;
    _elementPanelDataProvider = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
    if (self.elementTableView) {
        if (self.isShowingElementPanel) {
            [self toggleElementPanelAnimated:NO];
        }
        [self.elementTableView reloadData];
    }
    

    _catalogModel = catalogModel;
    
    [self setNavigationItems];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(self.catalogModel != nil){
            if(self.catalogModel.isVertical == false){
            } else {
                [self loadProductsOnFirstPage];
            }
        }
    });
    
    // Update the page collection.
    CGSize size = self.view.bounds.size;
    CGSize contentSize = size;
    contentSize.width *= self.catalogModel.pageModels.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionView.contentOffset = CGPointZero;
        [self.collectionView reloadData];
    });
}

#pragma mark - Page Navigation

- (void)swipeToNext {
    UICollectionView* collection = self.collectionView;
    NSArray* paths = collection.indexPathsForVisibleItems;
    if (paths.count >= 1) {
        NSIndexPath* path = (NSIndexPath*)paths[0];
        NSInteger ndx = path.row +1;
        NSIndexPath* next = [NSIndexPath indexPathForRow:ndx inSection:0];
        [collection scrollToItemAtIndexPath:next atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    
}

- (void)openPageWithIndexNumber:(NSNumber*)n {
    UICollectionView* collection = self.collectionView;
    NSInteger index = [n integerValue];
    if (self.catalogModel.pageModels.count >= index) {
        if ([[collection visibleCells] count] == 0) {
            collection.alpha = 0;
            [self performSelector:@selector(openPageWithIndexNumber:) withObject:@(index) afterDelay:0.1];
            return;
        } else {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                collection.alpha = 1;
            } completion:^(BOOL finished) { }];
        }
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
        if (IS_IPAD && IS_LANDSCAPE && index != 0) {
            // Get the rect of the spread
            UICollectionViewLayoutAttributes* atts = [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            CGRect rect = atts.frame;
            if (index != 0 && index % 2 == 0) {
                path = [NSIndexPath indexPathForRow:index - 1 inSection:0];
            } else {
                path = [NSIndexPath indexPathForRow:index + 1 inSection:0];
            }
            
            atts = [collection.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            rect = CGRectUnion(rect, atts.frame);
            // Account for the insets
            CGFloat dx = collection.frame.size.width - rect.size.width;
            rect.origin.x -= dx/2;
            rect.size.width += dx;
            [collection scrollRectToVisible:rect animated:NO];
        } else if (index == 0) {
            CGPoint offset = collection.contentOffset;
            offset.x = 0;
            collection.contentOffset = offset;
        } else {
            UICollectionViewScrollPosition position;
            if (self.catalogModel.isVertical) {
                position = UICollectionViewScrollPositionTop;
            } else {
                position = UICollectionViewScrollPositionCenteredHorizontally;
            }
            [collection scrollToItemAtIndexPath:path atScrollPosition:position animated:NO];
        }
    }
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self.collectionView afterDelay:0.01];
}

#pragma mark - Sharing

- (void)sharePages {
    NSArray* paths = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    NSArray<PageModel*>* pages = @[];
    for (NSIndexPath* path in paths) {
        pages = [pages arrayByAddingObject:[self.catalogModel.pageModels objectAtIndex:path.row]];
    }
    ShareProxy* shareProxy = [[ShareProxy sharedProxy] newShareProxy];
    NSArray* items = @[];
    
    if (paths.count >= 2) {
        PageModel* left = pages[0];
        PageModel* right = pages[1];
        LeftAndRightShareable* sharable = [[LeftAndRightShareable alloc] init];
        sharable.left = left;
        sharable.right = right;
        items = [shareProxy itemsFromShareable:sharable];
    } else if (paths.count >= 1) {
        PageModel* page = pages[0];
        items = [shareProxy itemsFromShareable:page];
    }
    
    if ([items count]) {
        shareProxy.pageModels = pages;
        self.shareViewController = [shareProxy newShareViewControllerWithItems:items];
        if (IS_IPAD) {
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.shareViewController];
            self.popOverController.delegate = self;
            [self.popOverController presentPopoverFromBarButtonItem:self.pagesShareBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [self.navigationController presentViewController:self.shareViewController animated:YES completion:^{ }];
        }
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

-(void)shouldRevealToggle{
    if(self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(shouldRevealToggle)]){
        [self.productDetailViewDelegate shouldRevealToggle];
    }
}



#pragma mark - PolyPageView Element selection (iPhone)

- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    switch (selection.selectionType) {
        case ItemSelectionTypeVideo: {
            VideoModel* video = (VideoModel*)selection.selection;
            [self displayModalVideo:video];
            break;
        }
            
        case ItemSelectionTypePage: {
            [self dismissViewControllerAnimated:YES completion:^{ }];
            PageModel* page = (PageModel*)selection.selection;
            [self openPageWithIndexNumber:@(page.index)];
            break;
        }
            
        case ItemSelectionTypeUnknown: {
            [self dismissViewControllerAnimated:YES completion:^{ }];
            break;
        }
            
        default: {
            // Bubble up to some outer delegate
            if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
                [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
            }
            break;
        }
    }
}


#pragma mark - Handling selection results
//
//- (void)itemContainer:(id)container didPressShopNowSelection:(ItemSelection*)selection{
//    switch (selection.selectionType) {
//        case ItemSelectionTypeProduct: {
//                ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
//            ProductGroupModel* productGroup = (ProductGroupModel*)selection.selection;
//                result.result = [MasterConfiguration choose:productGroup or:productGroup.firstEntity];
//                result.resultType = ProductDetailViewResultTypeShopNow;
//            NSURL* u = productGroup.url1;
//            u = productGroup.url1_tracking;
//            NSURLRequest* req = [NSURLRequest requestWithURL:u];
//            WebViewController* c = [[WebViewController alloc] initWithRequest:req];
//            [self.navigationController pushViewController:c animated:YES];
//            break;
//            
//            [[TrackProxy sharedProxy] trackTapShopNow];
//        }            
//        default: {
//            NSLog(@"unhandled selection of item type");
//            break;
//        }
//    }
//}


#pragma mark - Video

- (void)displayModalVideo:(VideoModel*)videoModel {
    self.videoModel = videoModel;
    [[FIRTrackProxy sharedProxy] trackViewVideo:videoModel];
    AVPlayer* player = [AVPlayer playerWithURL:[videoModel URL]];
    player.rate = 0;
    if (self.videoController) {
        [self.videoController removeObserver:self forKeyPath:@"player.rate"];
    }
    self.videoController = [[AVPlayerViewController alloc] init];
    self.videoController.player = player;
    [self presentViewController:self.videoController animated:YES completion:^{
         [self.videoController addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:NULL];
    }];
}

#pragma mark AVPlayer KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSLog(@"%s %@",__func__,change);
    if (self.videoController.player.rate >= 1) {
        [[FIRTrackProxy sharedProxy] trackStartVideo:self.videoModel];
    } else {
        [[FIRTrackProxy sharedProxy] trackStopVideo:self.videoModel];
    }
}

#pragma mark - On-Page Elements + Panel (iPad)
#pragma mark PageView On-Page Elements and Selection (iPad)

- (void)toggleElementPanel {
    [self toggleElementPanelAnimated:YES];
}

- (void)toggleElementPanelAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.elementTableView.alpha = !self.elementTableView.alpha;
        } completion:^(BOOL finished) {
            self.isShowingElementPanel = self.elementTableView.alpha;
            [self setNavigationItems];
        }];
    } else {
        self.elementTableView.alpha = !self.elementTableView.alpha;
        self.isShowingElementPanel = self.elementTableView.alpha;
        [self setNavigationItems];
    }
}

- (void)pageView:(PageView*)pageView didSelectElement:(ElementModel *)elementModel {
    if (!elementModel) {
        // Nothing was selected, so de-select if need be.
        NSIndexPath* path = [self.elementTableView indexPathForSelectedRow];
        if (path) {
            [self.elementTableView deselectRowAtIndexPath:path animated:YES];
        }
    } else {
        // SYN-1189
        // Update products to product group with variants.
        NSString* ID = elementModel.productID;
        PagePanelItemType itemType = PagePanelItemType_Product;
        if (elementModel.selectedVariant) {
//            ID = elementModel.selectedVariant;
//            itemType = PagePanelItemType_Variant;
        } else if (elementModel.type == ElementModelType_Widget) {
            ID = elementModel.widgetID;
            itemType = PagePanelItemType_Video;
            // Also play the video!
            VideoModel* video = [pageView.pageModel videoWithWidgetID:ID];
            if (video.isModalOnly) {
                [self displayModalVideo:video];
            } else {
                [pageView toggleVideoForElement:elementModel];
            }
        } else if (elementModel.type == ElementModelType_Link) {
            ElementLinkModel* link = (ElementLinkModel*)elementModel;
            ID = link.ID;
            switch (link.linkType) {
                case LinkTypeExternal: {
                    itemType = PagePanelItemType_LinkExternal;
                    if (self.itemSelectionDelegate
                        && [self.itemSelectionDelegate
                            respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
                        ItemSelection* item = [[ItemSelection alloc] init];
                        item.selection = link;
                        item.selectionType = ItemSelectionTypeLink;
                        [self.itemSelectionDelegate itemContainer:nil didMakeSelection:item];
                    }
                    break;
                }
                case LinkTypeInternal:
                    itemType = PagePanelItemType_LinkInternal;
                    break;
                default:
                    break;
            }
        }
        
        //Show Tapped Product in Panel
        
        //Find the path for this ID
        NSIndexPath* path = [self.elementPanelDataProvider indexPathForItemType:itemType withId:ID];
        if (!path) {
            path = [self.elementPanelDataProvider indexPathForItemWithId:ID];
        }
        
        //If our path exists
        if (path) {
            
            //If this is a vertical catalog
            if(self.catalogModel.isVertical == true){
                
                //Open the vertical elements holder and toggle to viewable
                [(VerticalPageProductCellView*)[self.verticalElementCollectionView cellForItemAtIndexPath:path] toggleBorderShow];
                
                if(self.cellWithBorderPath != nil){
                    [(VerticalPageProductCellView*)[self.verticalElementCollectionView cellForItemAtIndexPath:self.cellWithBorderPath] toggleBorderHide];
                }
                
                self.cellWithBorderPath = path;
                
                [self.verticalElementCollectionView layoutIfNeeded];
                [self.verticalElementCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                if(self.verticalProductsHolderToggleDelegate){
                    [self.verticalProductsHolderToggleDelegate toggleVerticalProductsHolderUp];
                }
                
                NSArray* arr = [[NSArray alloc] initWithObjects:path, nil];
                [self.verticalElementCollectionView reloadItemsAtIndexPaths:arr];
                
            } else {
                //If we're not in a vertical catalog
                
                //We toggle the  element panel tableview
                if (self.elementTableView.alpha == 0) {
                    [self toggleElementPanel];
                }
                
                [self.elementTableView
                 selectRowAtIndexPath:path
                 animated:YES
                 scrollPosition:UITableViewScrollPositionTop];
            }
           
            
            [FIRTrackProxy sharedProxy].elementModel = elementModel;
            [[FIRTrackProxy sharedProxy] trackTapElement];
        }
    }
    
}

#pragma mark Loading and Displaying On-Page Elements (iPad)

- (void)setElementPanelTableView:(UITableView *)tableView {
    self.elementTableView = tableView;
    self.elementTableView.delegate = self;
    self.elementTableView.dataSource = self;
    self.isShowingElementPanel = self.elementTableView.alpha;
}

- (void)setVerticalElementPanelCollectionView:(UICollectionView *)collectionView {
    self.verticalElementCollectionView = collectionView;
    self.verticalElementCollectionView.delegate = self;
    self.verticalElementCollectionView.dataSource = self;
}

- (void)loadProducts {
    self.cellWithBorderPath = nil;
    [self loadProductsOnPagesWithModels:[self visiblePageModels]];
}

-(void)loadProductsOnFirstPage{
    self.shouldOpenProductsPanel = true;
    NSArray* objs = [NSArray arrayWithObjects:self.catalogModel.pageModels.firstObject, nil];
    [self loadProductsOnPagesWithModels:objs];
}
- (void)loadProductsOnPagesWithModels:(NSArray*)pageModels {
    @weakify(self);
    
    NSArray* ndxes = [self.collectionView indexPathsForVisibleItems];
    
    [[FetchProxy fetchProductsInPageModelsSortedByPage:pageModels fromCatalogModel:_catalogModel] subscribeNext:^(NSArray* pagesOfProductModels) {
        @strongify(self);
        // TODO: Relate specific elements to products.
        // As found in SYN-3809, elements are not related to items/products in the product panel, but
        // they should be. Figure out how to associate each page panel item to its specific element
        // in order to display the correct entity.
        NSArray* newNdxes = [self.collectionView indexPathsForVisibleItems];
        if ([ndxes isEqualToArray:newNdxes]) {
            
            
            int minIndex = 100;
            
            for(NSIndexPath* indexPath in newNdxes){
                if(indexPath.row < minIndex){
                    minIndex = indexPath.row;
                }
            }
            
            int counter = 0;
            NSMutableArray* newPagesOfProductModels = [[NSMutableArray alloc] init];
            for(NSArray* productArray in pagesOfProductModels){
                
                NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndex:0];
                if(newNdxes.count != 0){
                    indexPath = [newNdxes objectAtIndex:0];
                }
                for(NSIndexPath* thisPath in newNdxes){
                    if(thisPath.row == (minIndex + counter)){
                        indexPath = thisPath;
                    }
                }
                
                UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                CGRect cellFrame = [self.collectionView convertRect:cell.frame toView:self.view];

                
                counter = counter + 1;
                NSMutableArray* newPageArray = [[NSMutableArray alloc] init];
                
//                We must re-associate each product with it's page, only once
                for(ProductGroupModel* pg in productArray){
                    ElementModel* em = pg.associatedElements.firstObject;
                    //The bounds of the element model are in percentage values relative to the parent frame - e.g. the UICollectionViewCell
                    CGRect emFrame = em.hitAreaPolygon.bounds;
                    
                    CGFloat elementTop = (emFrame.origin.y*0.01*cellFrame.size.height + cellFrame.origin.y);
                    CGFloat elementBottom = elementTop + (emFrame.size.height*0.01*cellFrame.size.height);
                    
                    CGFloat offset = 64.0;
                    if((elementBottom >= offset) && (elementTop <= (self.view.frame.size.height - offset))){
                        [newPageArray addObject:pg];
                    } else {
                    }
                }
                [newPagesOfProductModels addObject:newPageArray];
            }
            
            pagesOfProductModels = [newPagesOfProductModels copy];
            
            // The user is still looking at the page that corresponds to this
            // request, so show the products.
            if(self.catalogModel.isVertical){
                _elementPanelDataProvider = [MasterConfiguration sharedConfiguration].generateFilteredPagePanelState(pagesOfProductModels, pageModels);
            } else{
                _elementPanelDataProvider = [MasterConfiguration sharedConfiguration].generatePagePanelState(pagesOfProductModels, pageModels);
            }

//            Update our products holder for a normal catalog. Will do nothing if we're in a vertical catalog
            UIEdgeInsets insets = self.elementTableView.contentInset;
            self.elementTableView.contentOffset = CGPointMake(0, -insets.top);
            [self.elementTableView reloadData];
            
//            If we're in a vertical catalog, then we want to update the vertical catalog products holder
            if(self.verticalElementCollectionView){
                [self.verticalElementCollectionView reloadData];
                if(self.verticalProductsHolderToggleDelegate){
                    
                    if(pagesOfProductModels.count > 0){
                        
//                        This allows for smooth/non-jittery interaction with click and drag functionality
                        [self.verticalProductsHolderToggleDelegate finishedLoadingProducts];
                        
//                        if we just loaded the catalog, then this bool will tell us to show the products panel. This ensures we only open the products panel the first time.

                        if(self.shouldOpenProductsPanel == true){
                            self.shouldOpenProductsPanel = false;
                            [self.verticalProductsHolderToggleDelegate toggleVerticalProductsHolderUp];
                            
//                            We make sure and close the panel after 2.5 seconds
                            dispatch_time_t timeToHidePanel = dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC);
                            dispatch_after(timeToHidePanel, dispatch_get_main_queue(), ^(void){
                                if(self.verticalProductsHolderToggleDelegate != nil){
                                    [self.verticalProductsHolderToggleDelegate toggleVerticalProductsHolderDown:YES];

                                }
                                
                            });
                            
                        }
                    }
                    
//                    We also check if our products are greater than our screen size. If so, we want to show the more products arrow. Otherwise, we hide the show products arrow.
                    
//                    Divide view width by size of product view
                    int productsOnView = floor(self.view.frame.size.width/112.0);
                    int products = [[[self elementPanelDataProvider].itemsBySection objectAtIndex:0] count];
                    
                    if(products > productsOnView){
                        [self.verticalProductsHolderToggleDelegate toggleMoreProductsArrowShow];
                    } else {
                        [self.verticalProductsHolderToggleDelegate toggleMoreProductsArrowHide];
                    }
                }
            }
            // If there are no products and the element table is not shown, don't give the user an option to open the table.
            [self setNavigationItems];
        }
        
    } error:^(NSError *error) {
        NSLog(@"error downloading products:%@",error);
        SyndecaAlertView* alert = [SyndecaAlertView alertDownloadFailed];
        alert.delegate = self;
        alert.request = [error.userInfo valueForKey:@"request"];
        [alert show];
    } completed:^{
        [FIRTrackProxy sharedProxy].catalogModel = self.catalogModel;
        [FIRTrackProxy sharedProxy].pageModels = pageModels;
        [[FIRTrackProxy sharedProxy] trackViewPage];
        
    }];
}

#pragma mark - UICollectionView (Pages)

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self setNavigationItems];
        [self performSelector:@selector(loadProducts) withObject:nil afterDelay:0];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.collectionView){
        if(self.verticalProductsHolderToggleDelegate){
            [self.verticalProductsHolderToggleDelegate toggleVerticalProductsHolderDown:YES];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(decelerate == NO){
        if(scrollView == self.collectionView){
            [self setNavigationItems];
            [self performSelector:@selector(loadProducts) withObject:nil afterDelay:0];
        }
    }
}

#pragma mark Vertical Elements Collection View Delegate & DataSource

- (UICollectionViewCell*)cellForVerticalElementAtIndexPath:(NSIndexPath*)indexPath {
    VerticalPageProductCellView* cell = (VerticalPageProductCellView*)[self.verticalElementCollectionView dequeueReusableCellWithReuseIdentifier:[VerticalPageProductCellView identifier] forIndexPath:indexPath];
    NSArray* productSection = [[self elementPanelDataProvider].itemsBySection objectAtIndex:indexPath.section];
    PagePanelItem* item = [productSection objectAtIndex:indexPath.row];
    cell.panelItem = item;
    cell.removePanelItemDelegate = self;
    if((self.cellWithBorderPath.section == indexPath.section) && (self.cellWithBorderPath.row == indexPath.row) && (self.cellWithBorderPath != nil)){
        [cell toggleBorderShow];
    } else {
        [cell toggleBorderHide];
    }
    return cell;
}

-(void)verticalElementsCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (UICollectionViewCell* cell in [self.collectionView visibleCells]) {
        PageView* page = [cell.contentView viewWithTag:[@"page" hash]];
        [page pauseAllVideos];
    }
    
    PagePanelItem* pitem = [[[self elementPanelDataProvider].itemsBySection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    ItemSelection* selection = [[ItemSelection alloc] init];

    //classic logic, pushes itemselectiondelegation up to show PDP view
    switch (pitem.itemType) {
        case PagePanelItemType_Product: {
            selection.selectionType = ItemSelectionTypeProduct;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_LinkInternal:
        case PagePanelItemType_LinkExternal: {
            selection.selectionType = ItemSelectionTypeLink;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_Variant: {
            selection.selectionType = ItemSelectionTypeVariant;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_Video: {
            VideoModel* v = (VideoModel*)pitem.item;
            [self displayModalVideo:v];
            break;
        }
            
        default: {
            selection.selectionType = ItemSelectionTypeUnknown;
            break;
        }
    }
    
    // Bubble the selection up to some outer delegate
    if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
        
        //If this is a vertical catalog
        if(self.catalogModel.isVertical == true){
            
            //Open the vertical elements holder and toggle to viewable
            [(VerticalPageProductCellView*)[self.verticalElementCollectionView cellForItemAtIndexPath:indexPath] toggleBorderShow];
            
            if(self.cellWithBorderPath != nil){
                [(VerticalPageProductCellView*)[self.verticalElementCollectionView cellForItemAtIndexPath:self.cellWithBorderPath] toggleBorderHide];
            }
            
            self.cellWithBorderPath = indexPath;
            
            [self.verticalElementCollectionView layoutIfNeeded];
            [self.verticalElementCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            if(self.verticalProductsHolderToggleDelegate){
                [self.verticalProductsHolderToggleDelegate toggleVerticalProductsHolderUp];
            }
            
            NSArray* arr = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.verticalElementCollectionView reloadItemsAtIndexPaths:arr];
            
        }
        
    }
}
#pragma mark UICollectionViewDelegate & DataSource & Layout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(collectionView == self.verticalElementCollectionView){
        return 1;
    } else{
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.catalogModel == nil) {
        return 0;
    }
    
    if(collectionView == self.verticalElementCollectionView){
        NSArray* items = [[self elementPanelDataProvider].itemsBySection objectAtIndex:section];
        return [items count];   
    }
    
    return self.catalogModel.pageModels.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(collectionView == self.verticalElementCollectionView){
        return [self cellForVerticalElementAtIndexPath:indexPath];
    }
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"page" forIndexPath:indexPath];

    if (self.catalogModel.isVertical) {
        VerticalPageView* polyView = [cell.contentView viewWithTag:[@"pageV" hash]];
        if (polyView == nil) {
            polyView = [[VerticalPageView alloc] initWithFrame:CGRectZero andZoomContainer:self.view];
            polyView.tag = [@"pageV" hash];
            polyView.zoomDelegate = self;
            [cell.contentView addSubview:polyView];
            [polyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        polyView.catalogModel = self.catalogModel;
        polyView.pageModel = pageModel;
        polyView.elementSelectionDelegate = self;
        polyView.delegate = self;
    } else if (IS_IPHONE) {
        PolyPageView* polyView = [cell.contentView viewWithTag:[@"page" hash]];
        if (polyView == nil) {
            polyView = [[PolyPageView alloc] initWithFrame:CGRectZero andZoomContainer:self.view];
            polyView.tag = [@"page" hash];
            polyView.zoomDelegate = self;
            [cell.contentView addSubview:polyView];
            [polyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        polyView.catalogModel = self.catalogModel;
        polyView.pageModel = pageModel;
        polyView.delegate = self;
    } else {
        PageView* pageView = [cell.contentView viewWithTag:[@"page" hash]];
        if (pageView == nil) {
            pageView = [[PageView alloc] initWithFrame:CGRectZero];
            pageView.delegate = self;
            pageView.tag = [@"page" hash];
            [cell.contentView addSubview:pageView];
            [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        pageView.pageModel = pageModel;
        pageView.delegate = self;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.verticalElementCollectionView){
        if((self.cellWithBorderPath.section == indexPath.section) && (self.cellWithBorderPath.row == indexPath.row) && (self.cellWithBorderPath != nil)){
            [(VerticalPageProductCellView*)cell toggleBorderShow];
        } else {
            [(VerticalPageProductCellView*)cell toggleBorderHide];
        }
        return;
    }
    
    for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
        
        if(self.catalogModel.isVertical){
            VerticalPageView* view = [cell.contentView viewWithTag:[@"pageV" hash]];
            if (view && [self.collectionView indexPathForCell:cell] != indexPath) {
               // [view pauseAllVideos];
            }
        }
        else if (IS_IPHONE) {
            PolyPageView* view = [cell.contentView viewWithTag:[@"page" hash]];
            if (view && [self.collectionView indexPathForCell:cell] != indexPath) {
                [view pauseAllVideos];
            }
        } else {
            PageView* view = [cell.contentView viewWithTag:[@"page" hash]];
            if (view && [self.collectionView indexPathForCell:cell] != indexPath) {
                [view pauseAllVideos];
            }
        }
    }
    
    if (IS_IPAD) {
        if (indexPath.row == 0) {
            [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:collectionView afterDelay:0.1];
        }
    }
    
    if(self.catalogModel.isVertical){
        VerticalPageView* polyView = [cell.contentView viewWithTag:[@"pageV" hash]];
        if (polyView == nil) {
            polyView = [[VerticalPageView alloc] initWithFrame:CGRectZero andZoomContainer:self.view];
            polyView.tag = [@"page" hash];
            polyView.zoomDelegate = self;
            [cell.contentView addSubview:polyView];
            [polyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        polyView.catalogModel = self.catalogModel;
        polyView.pageModel = pageModel;
        polyView.elementSelectionDelegate = self;
        polyView.delegate = self;
    }
    else if (IS_IPHONE) {
        PolyPageView* polyView = [cell.contentView viewWithTag:[@"page" hash]];
        if (polyView == nil) {
            polyView = [[PolyPageView alloc] initWithFrame:CGRectZero andZoomContainer:self.view];
            polyView.tag = [@"page" hash];
            polyView.zoomDelegate = self;
            [cell.contentView addSubview:polyView];
            [polyView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        polyView.catalogModel = self.catalogModel;
        polyView.pageModel = pageModel;
        polyView.delegate = self;
    } else {
        PageView* pageView = [cell.contentView viewWithTag:[@"page" hash]];
        if (pageView == nil) {
            pageView = [[PageView alloc] initWithFrame:CGRectZero];
            pageView.delegate = self;
            pageView.tag = [@"page" hash];
            [cell.contentView addSubview:pageView];
            [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.left.equalTo(@0);
                make.width.and.height.equalTo(cell.contentView);
            }];
        }
        
        PageModel* pageModel = [self.catalogModel.pageModels objectAtIndex:indexPath.row];
        pageView.pageModel = pageModel;
        pageView.delegate = self;
    }
    
}

-(void)resetAllPagesWhenLeavingView{
    if(self.catalogModel.isVertical == true){
        for(UICollectionViewCell *cell in self.collectionView.visibleCells){
          //add animation to cell here
            VerticalPageView* polyView = [cell.contentView viewWithTag:[@"pageV" hash]];
            if (polyView) {
                [polyView.pageView pauseAllVideos];
//                [polyView.pageView reset];
//                polyView.pageModel = nil;
//                polyView.catalogModel = nil;
            }
        }
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.verticalElementCollectionView){
        return;
    }
    
    if(self.catalogModel.isVertical == true){
        VerticalPageView* polyView = [cell.contentView viewWithTag:[@"pageV" hash]];
        if (polyView) {
            [polyView.pageView reset];
            polyView.pageModel = nil;
            polyView.catalogModel = nil;
        }
    }
    else if (IS_IPHONE) {
        PolyPageView* polyView = [cell.contentView viewWithTag:[@"page" hash]];
        if (polyView) {
            [polyView.pageView reset];
            polyView.pageModel = nil;
            polyView.catalogModel = nil;
        }
    } else {
        PageView* pageView = [cell.contentView viewWithTag:[@"page" hash]];
        if (pageView) {
            if([pageView respondsToSelector:@selector(reset)]){
                [pageView reset];
                pageView.pageModel = nil;
            } else{
                VerticalPageView* polyView = [cell.contentView viewWithTag:[@"page" hash]];
                if (polyView) {
                    if([polyView.pageView respondsToSelector:@selector(reset)]){
                        [polyView.pageView reset];
                        polyView.pageModel = nil;
                        polyView.catalogModel = nil;
                    }
                }
            }
        }
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.verticalElementCollectionView){
        [self verticalElementsCollectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate & DataSource (iPad On-Page Elements)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self elementPanelDataProvider].itemsBySection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* items = [[self elementPanelDataProvider].itemsBySection objectAtIndex:section];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCellView* cell = (ProductCellView*)[tableView dequeueReusableCellWithIdentifier:[ProductCellView identifier]];
    NSArray* productSection = [[self elementPanelDataProvider].itemsBySection objectAtIndex:indexPath.section];
    PagePanelItem* item = [productSection objectAtIndex:indexPath.row];
    cell.panelItem = item;
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return [MasterConfiguration sharedConfiguration].productCellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IS_IPAD && IS_LANDSCAPE){
        return 30;
    }else{
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.elementPanelDataProvider && [self.elementPanelDataProvider.sectionHeaderModels count]) {
        NSString* title = [self.elementPanelDataProvider.sectionHeaderModels objectAtIndex:section];
        return title;
    }
    return @"Page Title";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // SYN-223 Pause videos any time a user interacts with the product panel.
    
    //write logic to automatically push to web view
    //should write into a delegate
    
   
    for (UICollectionViewCell* cell in [self.collectionView visibleCells]) {
        PageView* page = [cell.contentView viewWithTag:[@"page" hash]];
        [page pauseAllVideos];
    }
    
    PagePanelItem* pitem = [[[self elementPanelDataProvider].itemsBySection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    ItemSelection* selection = [[ItemSelection alloc] init];
    
//    if(pitem.itemType == PagePanelItemType_Product){
//        
//        selection.selectionType = ItemSelectionTypeProduct;
//        selection.selection = pitem.item;
//        
//        if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didPressShopNowSelection:)]) {
//            [self.itemSelectionDelegate itemContainer:self didPressShopNowSelection:selection];
//            return;
//        }
//        
//    }
//    
    //classic logic, pushes itemselectiondelegation up to show PDP view
    switch (pitem.itemType) {
        case PagePanelItemType_Product: {
            selection.selectionType = ItemSelectionTypeProduct;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_LinkInternal:
        case PagePanelItemType_LinkExternal: {
            selection.selectionType = ItemSelectionTypeLink;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_Variant: {
            selection.selectionType = ItemSelectionTypeVariant;
            selection.selection = pitem.item;
            break;
        }
            
        case PagePanelItemType_Video: {
            VideoModel* v = (VideoModel*)pitem.item;
            [self displayModalVideo:v];
            break;
        }
            
        default: {
            selection.selectionType = ItemSelectionTypeUnknown;
            break;
        }
    }
    
    // Bubble the selection up to some outer delegate
    if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
    }
}


#pragma mark - Search

- (void)showSearch:(id)sender {
    UITextField* searchField = [self newSearchField];
    searchField.delegate = self;
    
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
        self.navigationItem.titleView = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
        
        [self.navigationItem setLeftBarButtonItems:@[search, space] animated:YES];
        [self.navigationItem setRightBarButtonItem:cancel animated:YES];
    });
}


#pragma mark - Search Navigation Getters
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

#pragma mark - Text Input
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:@"Search for Products"]){
        textField.text = @"";
        textField.textColor = [UIColor colorWithRed:(120.0/255.0) green:(120.0/255.0) blue:(120.0/255.0) alpha:1.0];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self openSearchControllerWithString:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
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
    c.catalog = self.catalogModel;
    c.productDetailViewDelegate = self;
    c.itemSelectionDelegate = self;
    c.searchViewControllerDelegate = self;
    bool willHandleResults = [c searchWithText:string inCatalog:c.catalog];

    if (!willHandleResults) {
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:c];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController completionhandler_pushViewController:c animated:YES completion:^{
                [self setNavigationItems];
            }];
        });
    }
}


- (void)cancel:(id)sender{
    [self setNavigationItems];
}

#pragma mark - Navigation Items

- (UIBarButtonItem*)hamburgerBarButtonItem {
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 56)];
    UIImage *hamButtonImage = [Icons sharedIcons].hamburgerMenuImage();
    UIButton* hamButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [hamButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
    [hamButton addTarget:self.revealDelegate action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    hamButton.adjustsImageWhenHighlighted = NO;
    [containerView addSubview:hamButton];
    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:hamButton];
    return hamBarButton;
}

- (UIBarButtonItem*)backBarButtonItem {
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 56)];
    UIImage *hamButtonImage = [Icons sharedIcons].backButtonImage();
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self.backButtonDelegate action:@selector(didTapBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.adjustsImageWhenHighlighted = NO;
    [containerView addSubview:backButton];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)setNavigationItems {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = nil;
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
    });
    
    [self.navigationItem setLeftItemsSupplementBackButton:YES];
    
    UIView* logoView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationItem setTitleView:logoView];
    });
    
    NSArray* rightItems = @[];
    if (![NetworkStatusObserver sharedObserver].hasNetworkConnection) {
        [self.navigationItem setRightBarButtonItems:nil];
        return;
    }
    if (IS_IPAD && [self hasVisibleOnPageElements]) {
        // Add the show/hide products toolbar item.
        NSString* show = [[NLS nls] stringFor:@"catalog.showProducts"
                                      default:@"Show Products"];
        NSString* hide = [[NLS nls] stringFor:@"catalog.hideProducts"
                                      default:@"Hide Products"];
        
        NSString* text;
        if (self.isShowingElementPanel) {
            text = hide;
        } else {
            text = show;
        }
        
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:text
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(toggleElementPanel)];
        [button setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithWhite:0.22 alpha:1.0], NSForegroundColorAttributeName,nil]
                              forState:UIControlStateNormal];
        
        self.toggleElementPanelButtonItem = button;
        self.toggleElementPanelButtonItem.accessibilityLabel = @"show-products";
        
        // TODO: When the element panel is not showing and we don't have any products,
        // don't show the products bar button item.
        rightItems = [rightItems arrayByAddingObject:self.toggleElementPanelButtonItem];
    }
    
    if (self.catalogModel.extensions.searchEnabled) {
        UIImage *searchImage = [Icons sharedIcons].searchIconImage();
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearch:)];
        [search setImageInsets:UIEdgeInsetsMake(4, 4, 0, 4)];     
        rightItems = [rightItems arrayByAddingObject:search];
    }
    
    if (self.catalogModel.extensions.sharingEnabled) {
        rightItems = [rightItems arrayByAddingObject:self.pagesShareBarButtonItem];
    }
    
    //Add a custom image hamburger button
    UIBarButtonItem* barButton;
    if (self.leftButtonItemType == LeftButtonItemType_Back) {
        barButton = [self backBarButtonItem];
    } else {
        barButton = [self hamburgerBarButtonItem];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationItem setRightBarButtonItems:rightItems animated:NO];
        self.navigationItem.leftBarButtonItem = barButton;
    });
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
   
#pragma mark - Remove Panel Item Products with failing images
-(void)removePanelItemForProductWithId:(ProductGroupModel *)productGroupModel{
    NSLog(@"SHOULD REMOVE PRODUCT: %@", productGroupModel.ID);
    
    NSString* ID = productGroupModel.ID;
    for (int i = 0; i < [self.elementPanelDataProvider.itemsBySection count]; i++) {
        NSArray* section = [self.elementPanelDataProvider.itemsBySection objectAtIndex:i];
        for (int j = 0; j < [section count]; j++) {
            PagePanelItem* pitem = [section objectAtIndex:j];
            NSLog(@"%s Looking for %@ - %@",__func__,ID,pitem.item.ID);
            if ([pitem.item.ID isEqualToString:ID]) {
                NSIndexPath*indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                
                NSMutableArray* savedItems = [[NSMutableArray alloc] initWithArray:self.elementPanelDataProvider.itemsBySection];
                NSMutableArray* sectionArr = [[NSMutableArray alloc] initWithArray:[self.elementPanelDataProvider.itemsBySection objectAtIndex:indexPath.section]];
                [sectionArr removeObjectAtIndex:indexPath.row];
                [savedItems replaceObjectAtIndex:indexPath.section withObject:[sectionArr copy]];
                
                self.elementPanelDataProvider.itemsBySection = [savedItems copy];
                
            }
        }
    }
    
    [self.elementTableView reloadData];
    
    //            If we're in a vertical catalog, then we want to update the vertical catalog products holder
    if(self.verticalElementCollectionView){
        [self.verticalElementCollectionView reloadData];
    }
    
    
}

@end
