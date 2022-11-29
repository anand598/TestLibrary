//
//  SearchNavigationController.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/24/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "SearchViewController.h"
#import "UIViewHelper.h"
#import "SyndecaTabBarController.h"
#import "FetchProxy.h"
#import "NLS.h"
#import "Fonts.h"
#import "UILabel+HTML.h"
#import "FIRTrackProxy.h"
#import "UICollectionViewCell+ContentViews.h"
#import "ItemSelection.h"
#import "NLS.h"
#import "PDPWebController.h"
#import "SearchModel.h"

#import "UIImage+animatedGIF.h"
#import "UIImage+SyndecaSDK.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

SYNTHESIZE_DI

- (void)viewDidLoad {
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"result"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
     self.collectionView.collectionViewLayout = [self collectionViewResultsLayout];
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.left = 8;
    insets.right = 8;
    insets.top += 4;
    self.collectionView.contentInset = insets;
    
    //add a just back button
    UIImage *backButtonImage = [Icons sharedIcons].backButtonImage();
    UIImageView* backButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButtonImageView setImage:backButtonImage];
    [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
    self.navigationItem.leftBarButtonItem = back;

    self.indicatorView.center = self.view.center;
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0, 0, 40, 40);
    [self.view addSubview:self.indicatorView];
    
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
    
    self.noResultsLabel = [[UILabel alloc] init];
    self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
    self.noResultsLabel.textColor = [UIColor darkTextColor];
    self.noResultsLabel.alpha = 0.0;
    self.noResultsLabel.userInteractionEnabled = NO;
    self.noResultsLabel.font = [Fonts fontType:FontTypeNormalLight withSize:FontSizeBig];
    self.noResultsLabel.numberOfLines = 0;
    [self.view addSubview:self.noResultsLabel];
    [self.noResultsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@104);
        make.width.equalTo(self.view).offset(-20);
    }];
}

-(void)didPressBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.indicatorView.center = self.view.center;
}

#pragma mark - Factories

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
    leftView.frame = CGRectMake(0.0, 0.0, leftView.image.size.width+10.0, leftView.image.size.height);
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
    [self startSearch:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField resignFirstResponder];
    return YES;
}

#pragma mark - Search

- (void)startSearch:(id)_ {
    NSString* text = self.searchField.text;
    [self searchWithText:text inCatalog:self.catalog];
}

- (bool)searchWithText:(NSString*)text inCatalog:(CatalogModel*)c {
    [self.searchField resignFirstResponder];
    self.catalog = nil;
    self.searchField.text = nil;
    [self.collectionView reloadData];
    
    // Store the catalog model for later use.
    self.catalog = c;
    self.searchField.text = text;
    
    [[FIRTrackProxy sharedProxy] trackSearchPhrase:text];
    [self.indicatorView startAnimating];
    [[FetchProxy fetchSearchResultsForText:text inGuide:c.guide] subscribeNext:^(NSArray* items) {
        self.items = items;
        [self.indicatorView stopAnimating];
        [self.collectionView reloadData];
        [self checkForEmptySearchResult:text];
    } error:^(NSError *error) {
            
            
    } completed:^{
            
    }];
    
    return false;
}


-(void)checkForEmptySearchResult:(NSString*)text{
    if([self.items count] > 0) {
        return;
    }
    
    NSString* textString = [NSString stringWithFormat:@"No results for %@\nCheck the spelling or try a more general term.", text];
    
    self.noResultsLabel.text = textString;
    [UIView animateWithDuration:0.1 animations:^{
        self.noResultsLabel.alpha = 0.8;
    }];

}

#pragma mark - UICollectionViewDelegateFlowLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 20.0);
//}


- (UICollectionViewLayout*)collectionViewResultsLayout{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    if(IS_IPAD){
        
        CGFloat width = self.view.frame.size.width/4.0 - 14.0;
        //        layout.minimumInteritemSpacing = 8.0;
        //        layout.minimumLineSpacing = leftPadding;
        CGSize previewSize = CGSizeMake(width, width*(5.0/3.0)+50);
        layout.itemSize = previewSize;
        
    } else{
        CGFloat width = self.view.frame.size.width/2.0 - 14.0;
//        layout.minimumInteritemSpacing = 8.0;
//        layout.minimumLineSpacing = leftPadding;
        CGSize previewSize = CGSizeMake(width, width*(5.0/3.0)+50);
        layout.itemSize = previewSize;
        
    }
    
    return layout;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.items && [self.items count]) {
        return [self.items count];
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"result" forIndexPath:indexPath];
    
    [cell setupContentViewOfSearchResultWithTitleLabelId:@"titleLabel"
                                          andImageViewId:@"imageView"
                                  andActivityIndicatorId:@"indicator"
                                      andSubtitleLabelId:@"subtitleLabel"
                                              andPriceId:@"priceLabel"
                                               andSaleId:@"saleLabel"
                                          andHeartViewId:@"heartView"];
    
    UICollectionViewCell* configuredCell = [self configureSearchResultsCell:cell andIndexPath:indexPath];
    
    return configuredCell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView* indicator = (UIImageView*)[cell contentViewWithIdentifier:@"indicator"];
    [indicator stopAnimating];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"image"];
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = nil;
    });
    [imageView cancelImageRequestOperation];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchModel* item = [self.items objectAtIndex:indexPath.row];
    if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        ElementLinkModel* link = [[ElementLinkModel alloc] initWithSearchModel:item];
        ItemSelection* selection = [[ItemSelection alloc] init];
        selection.selectionType = ItemSelectionTypeLink;
        selection.selection = link;
        [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
    }
}

-(UICollectionViewCell*)configureSearchResultsCell:(UICollectionViewCell*)cell andIndexPath:(NSIndexPath*)indexPath{
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"titleLabel"];
    UILabel* subtitleLabel = (UILabel*)[cell contentViewWithIdentifier:@"subtitleLabel"];
    UILabel* priceLabel = (UILabel*)[cell contentViewWithIdentifier:@"priceLabel"];
    UILabel* saleLabel = (UILabel*)[cell contentViewWithIdentifier:@"saleLabel"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    
    UIButton* heartView = (UIButton*)[cell contentViewWithIdentifier:@"heartView"];
    heartView.alpha = 0;
    
    UIImageView* indicator = (UIImageView*)[cell contentViewWithIdentifier:@"indicator"];
    
    SearchModel* item = [self.items objectAtIndex:indexPath.row];
    
    [indicator startAnimating];
    label.text = item.title;
    label.numberOfLines = 2;
    subtitleLabel.text = item.desc;
    subtitleLabel.numberOfLines = 2;
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.bottom.equalTo(subtitleLabel.mas_top);
        make.width.equalTo(cell.contentView.mas_width);
        make.height.equalTo(@(32));
    }];
    [subtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.bottom.equalTo(priceLabel.mas_top);
        make.width.equalTo(cell.contentView.mas_width);
        make.height.equalTo(@(32));
    }];
    
    saleLabel.alpha = 0.0;
    
    cell.backgroundColor = [UIColor clearColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = nil;
    });
    
    NSURLRequest* req = [NSURLRequest requestWithURL:item.thumb];
    @weakify(imageView);
    [imageView setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        @strongify(imageView);
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
            [indicator stopAnimating];
        });
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];
    
    return cell;
}

#pragma mark - Cancel Search
- (void)cancel:(id)sender {
    if(self.searchViewControllerDelegate && [self.searchViewControllerDelegate respondsToSelector:@selector(cancelSearch:)]){
        [self.searchViewControllerDelegate cancelSearch:sender];
    }
}

#pragma mark - Handling selection results in child ProductDetailView (handling wishlist selection bubbling for tabbaritem badges)

- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(productDetailView:didSelectResult:)]) {
        [self.productDetailViewDelegate productDetailView:view didSelectResult:result];
    }
}

- (NSString*)currencyStringFrom:(NSNumber*)n {
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    f.locale = [NLS nls].locale;
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    return [f stringFromNumber:n];
}
@end
