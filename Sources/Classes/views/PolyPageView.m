//
//  PolyPageView.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/15/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "PolyPageView.h"
#import "SyndecaSDK.h"
#import "FetchProxy.h"
#import "ProductItemView.h"
#import "MasterConfiguration.h"
#import "PagePanelItem.h"
#import "UIImageView+Offline.h"
#import "VideoModel.h"
#import "VariantModel.h"
#import "UIImageView+ContentScale.h"
#import "Icons.h"
#import "PageView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Masonry/Masonry.h>
#import "UIImage+animatedGIF.h"
#import "UIImage+SyndecaSDK.h"

#define PRODUCT_ITEM_CELL_HEIGHT 220
#define TABLE_HEADER_HEIGHT 30

@interface PolyPageView ()
@property (readwrite) UITableView* productsView;
@property (readwrite) UIActivityIndicatorView* indicatorView;

@property (readwrite) UIView* zoomContainer;
@property (readwrite) UIView* zoomBackgroundView;
@property (readwrite) BOOL isZoomingIn;
@end

@implementation PolyPageView

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame andZoomContainer:nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame andZoomContainer:(UIView *)zoomContainer {
    self = [super initWithFrame:frame];
    if (self) {
        self.zoomContainer = zoomContainer;
        self.isZoomingIn = NO;
        self.contentSizeHeightAdjustment = 0;
        
        self.zoomBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.zoomBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];

        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        [self addSubview:self.indicatorView];

        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 3;
        [self addSubview:self.scrollView];
        
        self.pageViewMask = [[UIView alloc] initWithFrame:CGRectZero];
        self.pageViewMask.layer.masksToBounds = YES;
        [self.scrollView addSubview:self.pageViewMask];
        
        self.pageView = [[PageView alloc] initWithFrame:CGRectZero];
        self.pageView.delegate = self;
        [self.pageViewMask addSubview:self.pageView];
        
        self.productsView = [[UITableView alloc] initWithFrame:CGRectZero];
        self.productsView.backgroundColor = [UIColor clearColor];
        self.productsView.delegate = self;
        self.productsView.dataSource = self;
        self.productsView.separatorInset = UIEdgeInsetsZero;
        self.productsView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.3] CGColor];
        self.productsView.layer.borderWidth = 1;

        [self.scrollView addSubview:self.productsView];
    }
    return self;
}

- (void)updateLayout {
    if (self.isZoomingIn) {
        return;
    }
    
    CGRect pageViewFrame = [self frameForPageView];
    if (CGRectEqualToRect(pageViewFrame, CGRectZero)) {
        NSLog(@"%s",__func__);
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.indicatorView.frame = [self frameForIndicatorView];
        self.pageView.frame = pageViewFrame;
        self.pageViewMask.frame = [self frameForPageViewMask];
        self.productsView.frame = [self frameForProductsView];
        self.scrollView.frame = self.bounds;
        self.zoomBackgroundView.frame = self.bounds;
        
        CGSize contentSize = self.frame.size;
        contentSize.height = CGRectGetMaxY(self.productsView.frame) + self.contentSizeHeightAdjustment;
        self.scrollView.contentSize = contentSize;
        [self setNeedsLayout];
    });
    
}

#pragma mark - Controlling video

- (void)pauseAllVideos {
    return [self.pageView pauseAllVideos];
}


#pragma mark - Updating the product model

- (void)setPageModel:(PageModel *)pageModel {
    self.pageView.pageModel = pageModel;
    
    self.scrollView.contentOffset = CGPointZero;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.productsView reloadData];
    });
   
    self.elementTableDataProvider = nil;
    [self updateLayout];
    
    if (!pageModel) {
        return;
    }


    dispatch_async(dispatch_get_main_queue(), ^{
         [self.indicatorView startAnimating];
    });
   
    
    @weakify(self);
    // Fetch the products from the API.
    [[FetchProxy fetchProductsInPageModelsSortedByPage:@[pageModel] fromCatalogModel:self.catalogModel] subscribeNext:^(NSArray* pagesOfProducts) {
        @strongify(self);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
        });
        
        // https://synapsegroup.jira.com/browse/SYN-1433
        // Make sure that previous request from a recycled pageview
        // don't write over our products.
        if (self.pageModel.number != pageModel.number) {
            // There has been a race condition!
            return;
        }
        
        
        self.elementTableDataProvider = [MasterConfiguration sharedConfiguration].generatePagePanelState(pagesOfProducts, @[pageModel]);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.productsView reloadData];
        });
        
        [self updateLayout];
    }];
     
}

- (PageModel*)pageModel {
    return self.pageView.pageModel;
}

#pragma mark - Element selection 

- (void)pageView:(id)pageView didSelectElement:(ElementModel *)element {
    if (element.type == ElementModelType_Widget) {
        // SYN-1889 Add support for modal-only video
        // Find the video, check to see if it's modal only - if so
        // hand it off to the PolyPageView's delegate.
        VideoView* video = [self.pageView videoViewForElement:element];
        
        if (video != nil && video.videoModel.isModalOnly) {
            ItemSelection* selection = [[ItemSelection alloc] init];
            selection.selectionType = ItemSelectionTypeVideo;
            selection.selection = video.videoModel;
            
            if ([self.delegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
                [self.delegate itemContainer:self didMakeSelection:selection];
            }
        } else {
            [self.pageView toggleVideoForElement:element];
        }
    }
}

#pragma mark - Tableview Stuff

- (NSInteger)totalNumberOfItems {
    NSInteger n = 0;
    for (NSArray* section in self.elementTableDataProvider.itemsBySection) {
        n+= [section count];
    }
    return n;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.elementTableDataProvider.itemsBySection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.elementTableDataProvider.itemsBySection objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PRODUCT_ITEM_CELL_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.productsView dequeueReusableCellWithIdentifier:@"polycell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"polycell"];
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
                [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    ProductItemView* itemView = [cell viewWithTag:[@"itemView" hash]];
    if (!itemView) {
        itemView = [[ProductItemView alloc] initWithFrame:CGRectZero];
        itemView.tag = [@"itemView" hash];
    }
    itemView.shopButton.tag = indexPath.row;
    [itemView.shopButton addTarget:self action:@selector(didTapShopNowButton:) forControlEvents:UIControlEventTouchUpInside];
    
//    itemView.heartView.tag = indexPath.row;
//    [itemView.heartView addTarget:self action:@selector(didTapHeartButton:) forControlEvents:UIControlEventTouchUpInside];

    
//    PagePanelItem* item = [self.elementTableDataProvider itemWithIndexPath:indexPath];
    
    NSArray* productSection = [self.elementTableDataProvider.itemsBySection objectAtIndex:indexPath.section];
    PagePanelItem* item = [productSection objectAtIndex:indexPath.row];
    
    
    itemView.panelItem = item;
    [cell.contentView addSubview:itemView];

    [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@(0));
        make.width.and.height.equalTo(cell.contentView);
    }];
    
    
//    UIView* coverView = [[UIView alloc] initWithFrame:CGRectZero];
//    coverView.backgroundColor = [UIColor colorWithWhite:0.29 alpha:0.0];
//    coverView.tag = 200;
//    [cell.contentView addSubview:coverView];
//    
//    [coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.top.equalTo(@(0));
//        make.width.and.height.equalTo(cell.contentView);
//    }];
    
    return cell;
}

//- (void)didTapHeartButton:(id)sender{
//    UIButton *shopButton = (UIButton*)sender;
//   
//    
//    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
//    
//    UIImage* newImage = [UIImage imageNamed:@"glyphicons_012_heart.png" inBundle:bundle compatibleWithTraitCollection:nil];
//    
//    [shopButton setImage:newImage forState:UIControlStateNormal];
//                         
//
//    
//}
//
//- (void)didTapShopNowButton:(id)sender{
//    UIButton *shopButton = (UIButton*)sender;
//    int indexTag = shopButton.tag;
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:indexTag inSection:0];
//    
//    PagePanelItem* item = [self.elementTableDataProvider itemWithIndexPath:indexPath];
//    ItemSelection* selection = [[ItemSelection alloc] init];
//
//    switch (item.itemType) {
//        case PagePanelItemType_Product: {
//            ProductGroupModel* product = (ProductGroupModel*)item.item;
//            selection.selectionType = ItemSelectionTypeProduct;
//            selection.selection = product;
//            break;
//        }
//        default: {
//            selection = nil;
//            break;
//        }
//    }
//    
//    if ([self.delegate respondsToSelector:@selector(itemContainer:didPressShopNowSelection:)]) {
//        [self.delegate itemContainer:self didPressShopNowSelection:selection];
//    }
//
//}


- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    ProductItemView* itemView = [cell viewWithTag:[@"itemView" hash]];
        itemView.animateViewUnSelected;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    ProductItemView* itemView = [cell viewWithTag:[@"itemView" hash]];
        itemView.animateViewSelected;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // SYN-223 Just pause all playing on-page videos when someone selects something in the panel.
    [self.pageView pauseAllVideos];

    PagePanelItem* item = [self.elementTableDataProvider itemWithIndexPath:indexPath];
    ItemSelection* selection = [[ItemSelection alloc] init];
    
    switch (item.itemType) {
        case PagePanelItemType_Product: {
            ProductGroupModel* product = (ProductGroupModel*)item.item;
            selection.selectionType = ItemSelectionTypeProduct;
            selection.selection = product;
            break;
        }
        
        case PagePanelItemType_Variant: {
            ProductGroupModel* product = (VariantModel*)item.item;
            selection.selectionType = ItemSelectionTypeVariant;
            selection.selection = product;
            break;
        }
        case PagePanelItemType_Video: {
            VideoModel* video = (VideoModel*)item.item;
            selection.selectionType = ItemSelectionTypeVideo;
            selection.selection = video;
            break;
        }
            
        case PagePanelItemType_LinkInternal:
        case PagePanelItemType_LinkExternal: {
            ElementLinkModel* link = (ElementLinkModel*)item.item;
            selection.selectionType = ItemSelectionTypeLink;
            selection.selection = link;
            break;
        }
            
        default: {
            selection = nil;
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        ProductItemView* itemView = [cell viewWithTag:[@"itemView" hash]];
    
        
            [self.delegate itemContainer:self didMakeSelection:selection];
            itemView.animateViewUnSelected;
        
    }
    
}

#pragma mark - Scrolling && Framing

#define PAGEVIEW_HEIGHT (self.bounds.size.height - 75)

- (CGRect)frameForPageView {
    CGRect frame = self.bounds;
    frame.size.height = PAGEVIEW_HEIGHT;
    frame.origin.y = self.scrollView.contentOffset.y / -4;
    return frame;
}

- (CGRect)frameForPageViewMask {
    CGRect frame = self.bounds;
    frame.size.height = PAGEVIEW_HEIGHT;
    CGFloat offy = self.scrollView.contentOffset.y;
    frame.origin.y = offy/2;
    frame.size.height -= offy/2;
    return frame;
}

- (CGRect)frameForProductsView {
    CGRect bounds = self.bounds;
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.pageViewMask.frame), bounds.size.width, 0);
    NSUInteger n = [self totalNumberOfItems];
    frame.size.height = PRODUCT_ITEM_CELL_HEIGHT * n;
    return frame;
}

- (CGRect)frameForIndicatorView {
    CGRect product = [self frameForProductsView];
    CGRect frame = CGRectMake(product.origin.x + product.size.width/2 - 20,
                              product.origin.y, 40, 40);
    frame.size.width = 40;
    frame.size.height = 40;
    return frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isZoomingIn || scrollView != self.scrollView) {
        return;
    }
    self.pageViewMask.frame = [self frameForPageViewMask];
    self.pageView.frame = [self frameForPageView];
}

#pragma mark - Zooming

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(viewForZoomingIn:)]) {
        return [self.zoomDelegate viewForZoomingIn:self];
    }
    return self.pageViewMask;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (scrollView.zoomScale > 1.0) {
        return;
    }
    
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(willBeginZooming:withView:)]) {
        [self.zoomDelegate willBeginZooming:self withView:view];
    }
    
    self.isZoomingIn = YES;
    self.pageViewMask.layer.masksToBounds = NO;
        self.zoomBackgroundView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.zoomBackgroundView.alpha = 1;
        }];
        [self addSubview:self.productsView];
    
    // Then take the scrollview and add that to our zoom container so it can
    // be free.
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = 60;
        self.scrollView.contentInset = insets;
        [self.zoomContainer addSubview:self.zoomBackgroundView];
        [self.zoomContainer addSubview:self.scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(didZoomWithScale:)]) {
        [self.zoomDelegate didZoomWithScale:scrollView.zoomScale];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (scale == 1.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.zoomBackgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(didEndZooming:withView:atScale:)]) {
                [self.zoomDelegate didEndZooming:self withView:view atScale:scale];
            }
            self.isZoomingIn = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pageViewMask.layer.masksToBounds = YES;
            
                [self addSubview:self.scrollView];
                [self.scrollView addSubview:self.productsView];
                [self.zoomBackgroundView removeFromSuperview];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIEdgeInsets insets = self.scrollView.contentInset;
                insets.bottom = 0;
                self.scrollView.contentInset = insets;
            });
            [self updateLayout];
        }];
    }
    

    
}

@end
