//
//  ScanShopResultsViewController.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/16/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "ScanShopResultsViewController.h"
#import "FetchProxy.h"
#import "PageModel.h"
#import "FIRTrackProxy.h"
#import "Icons.h"
#import "CollectionImageViewCell.h"
#import "WebViewController.h"
#import "UILabel+HTML.h"
#import "NLS.h"
#import "VideoModel.h"
#import "MasterConfiguration.h"
#import "PDPWebController.h"
#import "Fonts.h"
#import <Masonry/Masonry.h>
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "UIImage+animatedGIF.h"
#import "UIImage+SyndecaSDK.h"


#define TABLE_HEADER_HEIGHT 28

#define PAGE_ITEM_WIDTH 188
#define PRODUCT_ITEM_WIDTH 128
#define PRODUCT_ITEM_HEIGHT 250
#define VIDEO_ITEM_HEIGHT 100
#define VIDEO_ITEM_WIDTH 200
#define ITEM_SIDE_PADDING 10

#define PAGE_CELL_HEIGHT 250
#define PRODUCT_CELL_HEIGHT 260
#define VIDEO_CELL_HEIGHT 150
#define DEFAULT_CELL_HEIGHT 50

typedef enum {
    ResultSectionPage,
    ResultSectionProducts,
    ResultSectionVideos,
    ResultSectionLinks,
    ResultSectionUnknown
} ResultSection;

@interface ScanShopResultsViewController ()

@property (readwrite) PageModel* pageModel;
@property (readwrite) CatalogModel* catalogModel;
@property (readwrite) NSMutableArray* indexToSection;
@property (readwrite) NSArray* products;
@property (readwrite) NSArray* videos;
@property (readwrite) NSArray* links;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) UITableView* tableView;
@property (readwrite) UICollectionView* pageCollectionView;
@property (readwrite) UICollectionView* productCollectionView;
@property (readwrite) UICollectionView* videoCollectionView;
@property (readwrite) AVPlayerViewController* videoController;

@end

@implementation ScanShopResultsViewController

SYNTHESIZE_DI

- (id)initWithCatalog:(IssueModel*)issue andPageIndex:(NSUInteger)ndx andBarcode:(NSString*)barcode {
    self = [super init];
    if (self) {
        self.handleProductVideoAndExternalLinkSelection = NO;
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.indexToSection = [[NSMutableArray alloc] init];
        
        if (issue != nil) {
            [self loadScanResultsForIssue:issue andPageIndex:ndx];
        } else {
            [self loadScanResultsForBarcode:barcode];
        }
    }
    return self;
}

- (id)initWithBarcode:(NSString *)barcode {
    return [self initWithCatalog:nil andPageIndex:0 andBarcode:barcode];
}

- (id)initWithCatalog:(IssueModel *)issue andPageIndex:(NSUInteger)ndx {
    return [self initWithCatalog:issue andPageIndex:ndx andBarcode:nil];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        // This controller is being removed, so we should tell our delegate.
        [self backAction];
    }
}

- (void)backAction {
    if (self.delegate) {
        [self.delegate didDismissResultsController:self];
        [self dismissViewControllerAnimated:YES completion: ^{
        }];
        
    }
}

#pragma mark - Building the view


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.top.and.left.equalTo(@0);
    }];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.height.equalTo(@40);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView startAnimating];
    });
    
    
    UILabel* titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.text = @"Scan + Shop";
    titleView.textColor = [MasterConfiguration sharedConfiguration].scanShopResultsTitleViewLabelColor;
    [titleView sizeToFit];
    self.navigationItem.titleView = titleView;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIImage *backButtonImage = [Icons sharedIcons].backButtonImage();
    UIImageView* backButtonImageView = [[UIImageView alloc] initWithImage:backButtonImage];
    [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backAction)]];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
    
    //  UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
    
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Loading the results

- (void)clearData {
    [self.indicatorView startAnimating];
    for (int i = 0; i < ResultSectionUnknown; i++) {
        self.indexToSection[i] = @(NSNotFound);
    }
    self.catalogModel = nil;
    self.pageModel = nil;
    self.videos = nil;
    self.products = nil;
    self.links = nil;
    self.tableView.alpha = 0;
    [self.tableView reloadData];
}

- (void)loadData {
    [self.indicatorView stopAnimating];
    
    NSUInteger ndx = 0;
    if (self.pageModel != nil) {
        self.indexToSection[ndx++] = @(ResultSectionPage);
    }
    if (self.products && [self.products count]) {
        self.indexToSection[ndx++] = @(ResultSectionProducts);
    }
    if (self.videos && [self.videos count]) {
        self.indexToSection[ndx++] = @(ResultSectionVideos);
    }
    if (self.links && [self.links count]) {
        self.indexToSection[ndx++] = @(ResultSectionLinks);
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.alpha = 1;
    }];
    [self.tableView reloadData];
    
    // SYN-1005 & SYN-1112
    // https://synapsegroup.jira.com/browse/SYN-1005
    // https://synapsegroup.jira.com/browse/SYN-1112
    // This will be reset (to the same values) when the tab controller loads
    // the page in signal completion.
    if (self.catalogModel && self.pageModel) {
        [[FIRTrackProxy sharedProxy] trackScanSuccess:self.catalogModel
                                          withPage:self.pageModel];
    }
}

- (void)loadScanResultsForBarcode:(NSString*)barcode {
    [self clearData];
    // SYN-1979
    // Support Barcode Scanning in Scan + Shop
    [[FetchProxy fetchProductFromBarcode:barcode] subscribeNext:^(ProductGroupModel* x) {
        // For now we skip selection and go straight to product details.
        ScanShopResult* result = [[ScanShopResult alloc] init];
        result.result = x;
        result.resultType = ScanShopResultTypeProduct;
        
        if (self.handleProductVideoAndExternalLinkSelection) {
            self.products = @[x];
            [self loadData];
        } else if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResult:inResultController:)]) {
            [self.delegate didSelectResult:result inResultController:self];
        }
    } error:^(NSError *error) {
        ScanShopResult* result = [[ScanShopResult alloc] init];
        result.result = @"Could not find any data associated with the scanned barcode.";
        result.resultType = ScanShopResultTypeError;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResult:inResultController:)]) {
            [self.delegate didSelectResult:result inResultController:self];
        }
    } completed:^{
        
    }];
}

- (void)loadScanResultsForIssue:(IssueModel*)issue andPageIndex:(NSUInteger)ndx {
    [self clearData];
    
    @weakify(self);
    // SYN-1660
    // Implement Scan + Shop 2.0 Publication Scan
    [[FetchProxy fetchCatalogModelUsingIssueModel:issue] subscribeNext:^(CatalogModel* c) {
        if ([c.pageModels count] < ndx) {
            return [self backAction];
        }
        
        self.pageModel = [c.pageModels objectAtIndex:ndx];
        
        [[FetchProxy fetchProductsInPageModels:@[self.pageModel] fromCatalogModel:c] subscribeNext:^(id x) {
            @strongify(self);
            
            NSMutableArray* products = [[NSMutableArray alloc] init];
            for (ProductGroupModel* productArray in x){
                NSArray* ents = productArray.entities;
                if(ents.count > 0){
                    [products addObject:productArray];
                }
            }
            self.products = [[NSArray alloc] initWithArray:products];
            
            self.catalogModel = c;
            self.videos = [self.pageModel videoModels];
            self.links = self.pageModel.elementModelsThatAreLinks;
            [self loadData];
        }];
    }];
}

#pragma mark - Table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger n = 0;
    for (NSNumber* num in self.indexToSection) {
        if (num.integerValue != NSNotFound) {
            n++;
        }
    }
    return n;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;
    if(header){
        header.textLabel.font = ((UILabel*)self.navigationItem.titleView).font;
        //header.textLabel.font = [Fonts fontType:FontTypeNormalLight
        //                               withSize:FontSizeSmall];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView* header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectZero];
    header.textLabel.textColor = [UIColor grayColor];
    header.textLabel.font = ((UILabel*)self.navigationItem.titleView).font;
    header.tintColor = [UIColor whiteColor];
    header.contentView.backgroundColor = [UIColor whiteColor];
    header.backgroundView.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        return header;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    [header.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.height.equalTo(@(1));
        make.left.equalTo(@(0));
        make.width.equalTo(header.contentView.mas_width);
    }];
    return header;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;
//    header.tintColor = [UIColor whiteColor];
//    header.backgroundColor = [UIColor whiteColor];
//    header.backgroundView.backgroundColor = [UIColor whiteColor];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TABLE_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSNumber* num = self.indexToSection[indexPath.section];
    NSInteger section = num.integerValue;
    switch (section) {
        case ResultSectionPage: {
            return PAGE_CELL_HEIGHT;
            break;
        }
            
        case ResultSectionProducts: {
            return PRODUCT_CELL_HEIGHT;
            break;
        }
            
        case ResultSectionVideos: {
            return VIDEO_CELL_HEIGHT;
            break;
        }
            
        default:
            return DEFAULT_CELL_HEIGHT;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sec {
    NSNumber* num = self.indexToSection[sec];
    NSInteger section = num.integerValue;
    switch (section) {
        case ResultSectionPage:
            if (self.pageModel) {
                return 1;
            }
            break;
            
        case ResultSectionProducts: {
            if (self.products && [self.products count]) {
                return 1;
            }
            break;
        }
            
        case ResultSectionVideos: {
            if (self.videos && [self.videos count]) {
                return 1;
            }
            break;
        }
            
        case ResultSectionLinks: {
            if (self.links) {
                return [self.links count];
            }
            break;
        }
            
        default:
            break;
    }
    
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sec {
    NSNumber* num = self.indexToSection[sec];
    NSInteger section = num.integerValue;
    switch (section) {
        case ResultSectionPage: {
            return @"Catalogs + Lookbooks";
            break;
        }
        case ResultSectionProducts: {
            return @"Products";
            break;
        }
        case ResultSectionVideos: {
            return @"Videos";
            break;
        }
        case ResultSectionLinks: {
            return @"Links";
            break;
        }
        default:
            break;
    }
    return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    NSNumber* num = self.indexToSection[indexPath.section];
    NSInteger section = num.integerValue;
    switch (section) {
        case ResultSectionPage: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"page"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"page"];
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
            
            UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            self.pageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            [self.pageCollectionView registerClass:[CollectionImageViewCell class] forCellWithReuseIdentifier:@"page"];
            self.pageCollectionView.backgroundColor = [UIColor clearColor];
            self.pageCollectionView.delegate = self;
            self.pageCollectionView.dataSource = self;
            [cell.contentView addSubview:self.pageCollectionView];
            
            [self.pageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(cell.mas_width);
                make.height.equalTo(cell.mas_height);
                make.centerX.equalTo(cell.mas_centerX);
                make.centerY.equalTo(cell.mas_centerY);
            }];
            break;
        }
            
        case ResultSectionProducts: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"product"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"product"];
            }
            
            UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.productCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                            collectionViewLayout:layout];
            [self.productCollectionView registerClass:[CollectionImageViewCell class]
                           forCellWithReuseIdentifier:@"product"];
            self.productCollectionView.backgroundColor = [UIColor clearColor];
            self.productCollectionView.delegate = self;
            self.productCollectionView.dataSource = self;
            [cell.contentView addSubview:self.productCollectionView];
            
            [self.productCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(cell.mas_width);
                make.height.equalTo(cell.mas_height);
                make.centerX.equalTo(cell.mas_centerX);
                make.centerY.equalTo(cell.mas_centerY);
            }];
            break;
        }
            
        case ResultSectionVideos: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"video"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"video"];
            }
            
            UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.videoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
            [self.videoCollectionView registerClass:[CollectionImageViewCell class]
                         forCellWithReuseIdentifier:@"video"];
            self.videoCollectionView.backgroundColor = [UIColor clearColor];
            self.videoCollectionView.delegate = self;
            self.videoCollectionView.dataSource = self;
            
            [cell.contentView addSubview:self.videoCollectionView];
            [self.videoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(cell.mas_width);
                make.height.equalTo(cell.mas_height);
                make.centerX.equalTo(cell.mas_centerX);
                make.centerY.equalTo(cell.mas_centerY);
            }];
            break;
        }
            
        case ResultSectionLinks: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"link"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"link"];
            }
            ElementLinkModel* link = (ElementLinkModel*)[self.links objectAtIndex:indexPath.row];
            cell.textLabel.text = link.linkTitle;
            cell.detailTextLabel.text = link.linkDescription;
            break;
        }
            
        default:
            break;
    }
    return cell;
}

#pragma mark Handling User Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* num = self.indexToSection[indexPath.section];
    switch (num.integerValue) {
        case ResultSectionLinks: {
            ElementLinkModel* link = (ElementLinkModel*)[self.links objectAtIndex:indexPath.row];
            ScanShopResult* result = [[ScanShopResult alloc] init];
            result.resultType = ScanShopResultTypeLink;
            result.result = link;
            
            
            if(self.selectionDelegate != nil){
                [self.selectionDelegate didSelectScanResult:result];
            } else {
                
            }
            
            if (link.linkType == LinkTypeExternal && self.handleProductVideoAndExternalLinkSelection) {
                NSURLRequest* req = [NSURLRequest requestWithURL:link.URL.asURL];
                WebViewController* wc = [[WebViewController alloc] initWithRequest:req];
                wc.shouldReloadOnViewDidAppear = true;
                wc.shouldShowBackButton = true;
                [[self navigationController] pushViewController:wc animated:YES];
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResult:inResultController:)]) {
                [self.delegate didSelectResult:result inResultController:self];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Collection view stuff

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.pageCollectionView && self.pageModel) {
        return 1;
    }
    if (collectionView == self.productCollectionView && self.products) {
        return [self.products count];
    }
    if (collectionView == self.videoCollectionView && self.videos) {
        return [self.videos count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.pageCollectionView && self.pageModel) {
        CollectionImageViewCell* cell = [self.pageCollectionView dequeueReusableCellWithReuseIdentifier:@"page" forIndexPath:indexPath];
        cell.textLabel.text = self.pageModel.catalog.title;
        cell.subTextLabel.text = self.pageModel.title;
        cell.descriptionTextLabel.text = nil;
        [cell.indicatorView startAnimating];
        NSURLRequest* req = [NSURLRequest requestWithURL:self.pageModel.imageURL];
        @weakify(cell);
        [cell.imageView setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
            @strongify(cell);
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = image;
            [cell.indicatorView stopAnimating];
            [cell setNeedsLayout];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {}];
        return cell;
    }
    if (collectionView == self.productCollectionView && self.products) {
        CollectionImageViewCell* cell = [self.productCollectionView
                                         dequeueReusableCellWithReuseIdentifier:@"product"
                                         forIndexPath:indexPath];
        ProductGroupModel* product = [self.products objectAtIndex:indexPath.row];
        NSString* brand = product.brand;
        NSString* title = product.title;
        
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        f.locale = [NLS nls].locale;
        f.numberStyle = NSNumberFormatterCurrencyStyle;
        NSNumber* priceNum = [NSNumber numberWithFloat:product.priceFloat];
        NSString* price = [f stringFromNumber:priceNum];
        if (product.hasPriceRange) {
            NSArray<NSNumber*> *range = product.priceRange;
            NSString *min = [f stringFromNumber:range[0]];
            NSString *max = [f stringFromNumber:range[1]];
            price = [min stringByAppendingFormat:@" - %@",max];
        }
        NSNumber* salePriceNum = [NSNumber numberWithFloat:product.priceSaleFloat];
        NSString* salePrice = [f stringFromNumber:salePriceNum];
        cell.textLabel.numberOfLines = 2;
        cell.subTextLabel.numberOfLines = 2;
        cell.textLabel.text = [cell.textLabel stringFromHtml:brand];
        cell.subTextLabel.text = [cell.subTextLabel stringFromHtml:title];
        
        if (product.priceFloat == 0 && !product.hasPriceRange) {
            cell.descriptionTextLabel.text = @"";
        } else {
            if(product.priceSaleFloat != 0){
                cell.descriptionTextLabel.text = salePrice;
            }else{
                cell.descriptionTextLabel.text = price;
            }
        }
        NSURL* previewURL = product.previewURL;
        NSURLRequest* req = [NSURLRequest requestWithURL:previewURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.indicatorView startAnimating];
            cell.imageView.image = nil;
        });
        @weakify(cell);
        [cell.imageView setImageWithURLRequest:req
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                           @strongify(cell);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               cell.imageView.image = image;
                                               cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                               [cell.indicatorView stopAnimating];
                                               [cell setNeedsLayout];
                                           });
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {}];
        return cell;
    }
    if (collectionView == self.videoCollectionView && self.videos) {
        CollectionImageViewCell* cell = [self.videoCollectionView
                                         dequeueReusableCellWithReuseIdentifier:@"video"
                                         forIndexPath:indexPath];
        VideoModel* video = [self.videos objectAtIndex:indexPath.row];
        NSURLRequest* req = [NSURLRequest requestWithURL:[video thumbURL]];
        [cell.indicatorView startAnimating];
        @weakify(cell);
        cell.textLabel.text = [video title];
        [cell.imageView setImageWithURLRequest:req
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
                                           @strongify(cell);
                                           cell.imageView.image = image;
                                           cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                           [cell.indicatorView stopAnimating];
                                           [cell setNeedsLayout];
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {}];
        return cell;
    }
    return nil;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, ITEM_SIDE_PADDING, 0, ITEM_SIDE_PADDING);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.pageCollectionView) {
        return CGSizeMake(PAGE_ITEM_WIDTH, PAGE_CELL_HEIGHT);
    }
    if (collectionView == self.productCollectionView) {
        return CGSizeMake(PRODUCT_ITEM_WIDTH, PRODUCT_ITEM_HEIGHT);
    }
    if (collectionView == self.videoCollectionView) {
        return CGSizeMake(VIDEO_ITEM_WIDTH, VIDEO_ITEM_HEIGHT);
    }
    return CGSizeZero;
}

#pragma mark Handling User Selection

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ScanShopResult* result = [[ScanShopResult alloc] init];
    result.resultType = ScanShopResultTypeUnknown;
    result.page = self.pageModel;
    
    
    if (collectionView == self.pageCollectionView) {
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
//        if(config.isShopCatalogs == true){
//            return;
//        }
        
        result.resultType = ScanShopResultTypePage;
        result.result = self.pageModel;
        if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(didSelectPage:)]) {
            [self.selectionDelegate didSelectPage:self.pageModel];
            [self backAction];
            return;
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResult:inResultController:)]) {
                [self.delegate didSelectResult:result inResultController:self];
            }
        }
    }
    
    if (collectionView == self.productCollectionView) {
        ProductGroupModel* p = (ProductGroupModel*)[self.products objectAtIndex:indexPath.row];
        result.resultType = ScanShopResultTypeProduct;
        result.result = p;
        
        MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
        
        //Setup default behavior to open shop now url if no delegate is set
        if(self.selectionDelegate == nil){
            NSURL* u = p.url1_tracking;
            NSURLRequest* req = [NSURLRequest requestWithURL:u];
            PDPWebController* c = [[PDPWebController alloc] initWithRequest:req];
            c.productGroupModel = p;
            c.isFromSearchController = true;
            [c.view layoutIfNeeded];
            [self.navigationController pushViewController:c animated:YES];
            return;
        } else {
            //Still allow shop now web url if appropriate methods are set on delegate
            if(self.selectionDelegate.shouldForceWebView == true){
                NSURL* u = p.url1_tracking;
                NSURLRequest* req = [NSURLRequest requestWithURL:u];
                PDPWebController* c = [[PDPWebController alloc] initWithRequest:req];
                c.productGroupModel = p;
                c.isFromSearchController = true;
                [c.view layoutIfNeeded];
                [self.navigationController pushViewController:c animated:YES];
            }
        }
        
    }
    
    if (collectionView == self.videoCollectionView) {
        VideoModel* v = (VideoModel*)[self.videos objectAtIndex:indexPath.row];
        result.resultType = ScanShopResultTypeVideo;
        result.result = v;
        
        if(self.selectionDelegate == nil){
            AVPlayer* player = [AVPlayer playerWithURL:[v URL]];
            self.videoController = [[AVPlayerViewController alloc] init];
            self.videoController.player = player;
            //[self.navigationController pushViewController:self.videoController animated:YES];
            [self presentViewController:self.videoController animated:YES completion:^{ }];
            return;
        }
        
    }
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(didSelectScanResult:)]) {
        [self.selectionDelegate didSelectScanResult:result];
    }
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(shouldRemoveResultsView:)]) {
        if(self.selectionDelegate.shouldRemoveResultsView == true){
            [self backAction];
        }
    }
}

@end

