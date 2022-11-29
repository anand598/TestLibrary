//
//  AddToBagScreenView.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ShoppingCartScreenView.h"
#import "ShoppingCartTableViewCell.h"
#import "ShoppingCart.h"
#import "SyndecaSDK.h"
#import "FetchProxy.h"
#import "ProductDetailViewController.h"
#import "UIImageView+Offline.h"
#import "NLS.h"
#import "Icons.h"
#import "Fonts.h"
#import "UILabel+HTML.h"
#import "FIRTrackProxy.h"
#import "UIViewHelper.h"
#import "UICollectionViewCell+ContentViews.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import <SyndecaSDK/UIImage+SyndecaSDK.h>
//#import "DTCoreText.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface ShoppingCartScreenView ()

@property (readwrite) NSUInteger rowForDeletion;

@property (readwrite) ProductDetailViewController* productDetailController;
@property (readwrite) NSArray* products;
@property (readwrite) NSArray* pages;
@end

@implementation ShoppingCartScreenView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        
        self.isWishlist = NO;
        
        RAC(self, shoppingCart.isWishlist) = RACObserve(self, isWishlist);

        NSString* bagTitle = [[NLS nls] stringFor:@"cart.title"
                                          default:@"Shopping Bag"];
        NSString* productTitle = [[NLS nls] stringFor:@"cart.productsHeading"
                                              default:@"Products"];
        NSString* amtTitle = [[NLS nls] stringFor:@"cart.amountHeading"
                                          default:@"Amount"];
        NSString* qtyTitle = [[NLS nls] stringFor:@"cart.quantityHeading"
                                          default:@"Qty"];
        NSString* estTitle = [[NLS nls] stringFor:@"cart.totalAmountLabel"
                                          default:@"Estimated total"];
        
                RACSignal* bagEmpty = [[self hasItems] not];

#pragma mark - UI Elements
//#pragma mark titleLabel
//        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        titleLabel.text = bagTitle;
//        titleLabel.font = [Fonts fontType:FontTypeMarquee
//                                 withSize:FontSizeMedium];
//        [self addSubview:titleLabel];
//
//        self.titleLabel = titleLabel;
//        
//#pragma mark productsHeader
//        UILabel* productsHeader = [[UILabel alloc] initWithFrame:CGRectZero];
//        productsHeader.text = productTitle;
//        productsHeader.font = [Fonts fontType:FontTypeNormal
//                                     withSize:FontSizeMedium];
//        [self addSubview:productsHeader];
//
//        self.productsHeader = productsHeader;
//        RAC(self, productsHeader.hidden) = [[self hasItems] not];
//        
//
//        [bagEmpty subscribeNext:^(id x) {
//            @strongify(self);
//            [self makeLayout];
//        }];
//
//#pragma mark qtyHeader
//        UILabel* qtyHeader = [[UILabel alloc] initWithFrame:CGRectZero];
//        qtyHeader.text = qtyTitle;
//        qtyHeader.font = self.productsHeader.font;
//        [self addSubview:qtyHeader];
//
//        self.qtyHeader = qtyHeader;
//        RAC(self, qtyHeader.hidden) = bagEmpty;
//        
//#pragma mark amountHeader
//        UILabel* amountHeader = [[UILabel alloc] initWithFrame:CGRectZero];
//        amountHeader.text = amtTitle;
//        amountHeader.font = self.productsHeader.font;
//        [self addSubview:amountHeader];
//
//        self.amountHeader = amountHeader;
//        RAC(self, amountHeader.hidden) = bagEmpty;

//#pragma mark productsTableView
//        UITableView* productsTableView = [[UITableView alloc] initWithFrame:CGRectZero];
//        productsTableView.dataSource = self;
//        productsTableView.delegate = self;
//        [self addSubview:productsTableView];
//        
//        self.productsTableView = productsTableView;
//        RAC(self, productsTableView.hidden) = bagEmpty;
        
#pragma mark productsCollectionView
        UICollectionView* productsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self collectionViewResultsLayout]];
        productsCollectionView.backgroundColor = [UIColor whiteColor];
        productsCollectionView.dataSource = self;
        productsCollectionView.delegate = self;
        [productsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"result"];
        [self addSubview:productsCollectionView];
        
        UIEdgeInsets insets = productsCollectionView.contentInset;
        insets.left = 8;
        insets.right = 8;
        insets.top += 4;
        productsCollectionView.contentInset = insets;
        
        self.productsCollectionView = productsCollectionView;
        RAC(self, productsCollectionView.hidden) = bagEmpty;
//        
//#pragma mark estTotalLabel
//        UILabel* estTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        estTotalLabel.text = estTitle;
//        estTotalLabel.font = [Fonts fontType:FontTypeCurrency
//                                    withSize:FontSizeMedium];
//        [self addSubview:estTotalLabel];
//
//        self.estTotalLabel = estTotalLabel;
//        RAC(self, estTotalLabel.hidden) = bagEmpty;
//        
//#pragma mark estTotalValue
//        UILabel* estTotalValue = [[UILabel alloc] initWithFrame:CGRectZero];
//        [self addSubview:estTotalValue];
//        estTotalValue.font = [Fonts fontType:FontTypeCurrency
//                                    withSize:FontSizeMedium];
//        
//        self.estTotalValue = estTotalValue;
//        RAC(self, estTotalValue.hidden) = bagEmpty;
//        RAC(self, estTotalValue.text) = [RACObserve(self, shoppingCart.itemStore) map:^id(id _) {
//            @strongify(self);
//            CGFloat price = [self.shoppingCart totalPrice];
//            NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
//            f.numberStyle = NSNumberFormatterCurrencyStyle;
//            f.locale = [NLS nls].locale;
//            NSString* pstr = [f stringFromNumber:[NSNumber
//                                                  numberWithFloat:price]];
//            return pstr;
//        }];
//        
//#pragma mark legalTextTitle
//        // This is the "How it Works" text in the Mary Kay app.
//        UILabel* legalTextTitle = [[UILabel alloc] initWithFrame:CGRectZero];
//        legalTextTitle.font = [Fonts fontType:FontTypeSubtext
//                                     withSize:FontSizeBig];
//        legalTextTitle.text = [[NLS nls] stringFor:@"cart.legalTextTitle"
//                                           default:@""];
//        [self addSubview:legalTextTitle];
//       
//        self.legalTextTitle = legalTextTitle;
//        RAC(self, legalTextTitle.hidden) = bagEmpty;
        
//#pragma  mark legalTextLabel 
//        UILabel* legalTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        legalTextLabel.font = [Fonts fontType:FontTypeNormal
//                                     withSize:FontSizeMedium];
//        legalTextLabel.numberOfLines = 0;
//        legalTextLabel.text = [[NLS nls] stringFor:@"cart.legalText"
//                                                default:@"Legal text sub"];
//        [self addSubview:legalTextLabel];
//        [legalTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(@10);
//            make.right.equalTo(self.mas_right).offset(-10);
//            make.top.equalTo(legalTextTitle.mas_bottom).offset(5);
//            make.height.lessThanOrEqualTo(@24);
//        }];
//        self.legalTextLabel = legalTextLabel;
//        RAC(self, legalTextLabel.hidden) = bagEmpty;
        
#pragma mark exportButton 
        UIButton* exportButton = [[UIButton alloc] initWithFrame:CGRectZero];
        NSString* checkoutTxt = [[NLS nls] stringFor:@"cart.checkoutText"
                                             default:@"checkout"];
        checkoutTxt = @"Email My Favorites";
        [exportButton setTitle:checkoutTxt forState:UIControlStateNormal];
        exportButton.backgroundColor = [UIColor colorWithRed:1.0
                                                       green:0.4
                                                        blue:0.0 alpha:1];
        exportButton.backgroundColor = [UIColor colorWithRed:0.08 green:0.04 blue:0.04 alpha:1.0];
        [exportButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        exportButton.titleLabel.font = [Fonts fontType:FontTypeNormal
                                         withPointSize:14.0f];
        
        exportButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [[exportButton rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             @strongify(self);
             if (self.exportAction) {
                 self.exportAction(self.shoppingCart);
             }
             if (self.isWishlist) {
                 [[FIRTrackProxy sharedProxy] trackExportWishlist:self.shoppingCart];
             } else {
                 [[FIRTrackProxy sharedProxy] trackExportCart:self.shoppingCart];
             }
         }];
        [self addSubview:exportButton];
  
        self.exportButton = exportButton;
        RAC(self, exportButton.hidden) = [[self hasItems] not];

        
//#pragma mark legalTextSub
//        UILabel* legalTextSub = [[UILabel alloc] initWithFrame:CGRectZero];
//        legalTextSub.numberOfLines = 0;
//        legalTextSub.font = [Fonts fontType:FontTypeSubtext
//                                   withSize:FontSizeMedium];
//        legalTextSub.text = [[NLS nls] stringFor:@"cart.legalTextSub"
//                                         default:@"Add your favorite items by "
//                                                 @"clicking the \"add to wishlist\" "
//                                                 @"button on any product detail page."];
//        [self addSubview:legalTextSub];
//
//        self.legalTextSub = legalTextSub;
//        RAC(self, legalTextSub.hidden) = bagEmpty;
        
#pragma mark emptyBagLabel
        UILabel* emptyBagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        emptyBagLabel.numberOfLines = 2;
        emptyBagLabel.textAlignment = NSTextAlignmentCenter;
        emptyBagLabel.text = [[NLS nls] stringFor:@"cart.emptyText"
                                          default:@"Your bag is currently empty."];
        [self addSubview:emptyBagLabel];

        self.emptyBagLabel = emptyBagLabel;
        RAC(self, emptyBagLabel.hidden) = [self hasItems];

        
#pragma mark - Other Setup
        self.shoppingCart = [[ShoppingCart alloc] initWithSaveName:@"cart" andReader:^id<HasID>(NSDictionary* info) {
            return [[[ProductGroupModel DIClass] alloc] initWithInfo:info];
        }];
        
//        [[RACObserve(self, shoppingCart.itemStore) filter:^BOOL(id value) {
//            @strongify(self);
//            return ![self.productsTableView isEditing];
//        }] subscribeNext:^(id x) {
//            @strongify(self);
//            [self.productsTableView reloadData];
//            if (self.shoppingCartDelegate) {
//                [self.shoppingCartDelegate didUpdateShoppingCart:self.shoppingCart];
//            }
//        }];
        
        [self makeLayout];
    }
    return self;
}

#pragma mark - Signals

- (RACSignal*)hasItems {
    return [RACObserve(self, shoppingCart.runningTotal) map:^(NSNumber* n) {
        return @([n intValue] > 0);
    }];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [self makeLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.productsCollectionView setCollectionViewLayout:[self collectionViewResultsLayout]];
    });
    [super layoutSubviews];
}

- (void)makeLayout {
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@64);
//        make.left.equalTo(@5);
//        make.right.lessThanOrEqualTo(self.mas_right).offset(-5);
//        make.height.lessThanOrEqualTo(@24);
//    }];       
//    [self.productsHeader mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
//        make.height.equalTo(@12);
//        make.left.equalTo(self.titleLabel.mas_left);
//        make.right.lessThanOrEqualTo(self.mas_centerX);
//    }];       
//    [self.qtyHeader mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_right).multipliedBy(0.52);
//        make.width.lessThanOrEqualTo(@50);
//        make.top.equalTo(self.productsHeader.mas_top);
//        make.height.equalTo(@12);
//    }];       
//    [self.amountHeader mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_right).multipliedBy(0.75);
//        make.width.lessThanOrEqualTo(@50);
//        make.top.equalTo(self.qtyHeader.mas_top);
//        make.height.equalTo(@12);
//    }];       
    [self.productsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@64);
//        make.bottom.equalTo(self.exportButton.mas_top).offset(-10);
//        make.height.equalTo(@300);
    }];
//    [self.estTotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.amountHeader.mas_left).offset(-10);
//        make.width.lessThanOrEqualTo(@125);
//        make.top.equalTo(self.productsCollectionView.mas_bottom).offset(10);
//        make.height.lessThanOrEqualTo(@24);
//    }];       
//    [self.estTotalValue mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.amountHeader.mas_left);
//        make.right.lessThanOrEqualTo(self.mas_right).offset(-5);
//        make.top.equalTo(self.estTotalLabel.mas_top);
//        make.height.equalTo(self.estTotalLabel);
//    }];       
//    [self.legalTextTitle mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.productsHeader.mas_left);
//        make.top.equalTo(self.estTotalLabel.mas_bottom).offset(10);
//        make.width.lessThanOrEqualTo(self.mas_width);
//    }];       
    [self.exportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.productsCollectionView.mas_bottom).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.height.equalTo(@44);
        make.width.equalTo(@160);
    }];       
//    [self.legalTextSub mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.mas_centerX);
//        make.width.lessThanOrEqualTo(self.mas_width);
//        make.top.equalTo(self.exportButton.mas_bottom).offset(10);
//        make.height.greaterThanOrEqualTo(@40);
//    }];
//    
//    [self.emptyBagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).offset(5);
//        make.right.equalTo(self.mas_right).offset(-5);
//        make.centerY.equalTo(self.mas_centerY);
//        make.height.greaterThanOrEqualTo(@12);
//    }];
}

#pragma mark - UITableView Stuff


//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ShoppingCartTableViewCell* cell = [self.productsTableView dequeueReusableCellWithIdentifier:[ShoppingCartTableViewCell cellIdentifier]];
//    if (!cell) {
//        cell = [[ShoppingCartTableViewCell alloc] init];
//    }
//    
//    //cell.backgroundView = [[UIView alloc] init];
//    //cell.backgroundView.backgroundColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    // SYN-790
//    // Add remove "X" button on Wishlist iPhone / iPad
//    UIImage* close = [[Icons sharedIcons].removeIconImage()
//                      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    UIButton* b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//    [b addTarget:self
//          action:@selector(deleteRowWithButton:)
//forControlEvents:UIControlEventTouchUpInside];
//    [b setImage:close forState:UIControlStateNormal];
//    b.tintColor = [UIColor grayColor];
//    cell.accessoryView = b;
//    
//    NSUInteger ndx = indexPath.row;
//    ProductGroupModel* pm = (ProductGroupModel*)[[self.shoppingCart array] objectAtIndex:ndx];
//    cell.productModel = pm;
//    cell.textLabel.text = pm.title;
//    
//    BOOL isSale = pm.priceSaleFloat != 0 && pm.priceSaleFloat < pm.priceFloat;
//    CGFloat pricef = pm.priceFloat;
//    CGFloat salef = pm.priceSaleFloat;
//    
//    NSNumber* price = [NSNumber numberWithFloat:pricef];
//    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
//    f.numberStyle = NSNumberFormatterCurrencyStyle;
//    f.locale = [NLS nls].locale;
//    NSString* pstr = [f stringFromNumber:price];
//    NSLog(@"%@",[f.locale localeIdentifier]);
//    
//    if (isSale) {
//        NSString* html = @"<font face=\"%@\" color=\"#333\"><del>%@</del></font>"
//        @"&nbsp;"
//        @"<font face=\"%@\" color=\"#f00\">%@</font>";
//        UIFont* font = cell.detailTextLabel.font;
//        NSNumber* sale = [NSNumber numberWithFloat:salef];
//        NSString* sstr = [f stringFromNumber:sale];
//        NSString* str = [NSString stringWithFormat:
//                         html,
//                         font.fontName,pstr,
//                         font.fontName,sstr];
//        NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
//        cell.detailTextLabel.attributedText = [[NSAttributedString alloc]
//                                               initWithHTMLData:data
//                                               options:@{DTUseiOS6Attributes:@YES,
//                                                         DTDefaultFontName:font.fontName,
//                                                         DTDefaultFontSize:@(10)}
//                                               documentAttributes:nil];
//        pricef = salef;
//    } else {
//        cell.detailTextLabel.text = pstr;
//    }
//    
//    CGFloat qty = [self.shoppingCart quantityOfItem:pm];
//    cell.quantity = qty;
//    cell.amountLabel.text = [f stringFromNumber:[NSNumber
//                                                 numberWithFloat:pricef * qty]];
//    [cell.indicatorView startAnimating];
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [[cell.imageView loadImageWithURL:pm.previewURL]
//     subscribeNext:^(UIImage* img) {
//         cell.imageView.image = img;
//         [cell.indicatorView stopAnimating];
//         [cell layoutSubviews];
//     }];
//    
//    @weakify(pm);
//    @weakify(self);
//    cell.shoppingCartItemDelegate = self;
//    return cell;
//}
//

- (UICollectionViewLayout*)collectionViewResultsLayout{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    if(IS_IPAD){
        
        CGFloat width = self.frame.size.width/4.0 - 14.0;
        //        layout.minimumInteritemSpacing = 8.0;
        //        layout.minimumLineSpacing = leftPadding;
        CGSize previewSize = CGSizeMake(width, width*(5.0/3.0)+50);
        layout.itemSize = previewSize;
        
    } else{
        CGFloat width = self.frame.size.width/2.0 - 14.0;
        //        layout.minimumInteritemSpacing = 8.0;
        //        layout.minimumLineSpacing = leftPadding;
        CGSize previewSize = CGSizeMake(width, width*(5.0/3.0)+50);
        layout.itemSize = previewSize;
        
    }

    return layout;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.shoppingCart && [self.shoppingCart array] && [[self.shoppingCart array] count]) {
        return [[self.shoppingCart array] count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [self.productsCollectionView dequeueReusableCellWithReuseIdentifier:@"result" forIndexPath:indexPath];
    
    [cell setupContentViewOfSearchResultWithTitleLabelId:@"titleLabel" andImageViewId:@"imageView" andActivityIndicatorId:@"indicator" andSubtitleLabelId:@"subtitleLabel" andPriceId:@"priceLabel" andSaleId:@"saleLabel" andHeartViewId:@"heartView"];
    
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"titleLabel"];
    UILabel* subtitleLabel = (UILabel*)[cell contentViewWithIdentifier:@"subtitleLabel"];
    UILabel* priceLabel = (UILabel*)[cell contentViewWithIdentifier:@"priceLabel"];
    UILabel* saleLabel = (UILabel*)[cell contentViewWithIdentifier:@"saleLabel"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    UIActivityIndicatorView* indicator = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicator"];
    UIButton* heartView = (UIButton*)[cell contentViewWithIdentifier:@"heartView"];
    [heartView addTarget:self action:@selector(updateCartWithItem:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    ProductGroupModel* product = [[self.shoppingCart array] objectAtIndex:indexPath.row];
    if([self checkIfCartContainsItem:product] == true){
        dispatch_async(dispatch_get_main_queue(), ^{
            [heartView setBackgroundImage:[Icons sharedIcons].heartIconImage() forState:UIControlStateNormal];
        });
    }
    NSString* priceStr = [self currencyStringFrom:[NSNumber numberWithFloat:product.priceFloat]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [indicator startAnimating];
        label.text = product.subtitle;
        subtitleLabel.text = product.title;
        
        
        priceLabel.text = priceStr;
        saleLabel.alpha = 0.0;
        
        cell.backgroundColor = [UIColor clearColor];
    });
    
    if(product.isSale){
        saleLabel.alpha = 1.0;
        NSString* html = @"";
        if (product.originalPrice) {
            html = [NSString stringWithFormat:@"<font color=\"#7f7f7f\"><b><del>%@</del></b></font>",product.originalPrice];
        }
        NSString* priceStr = [self currencyStringFrom:[NSNumber numberWithFloat:product.priceSaleFloat]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            saleLabel.attributedText = [saleLabel attributedStringFromHtml:html];
            priceLabel.text = priceStr;
        });
        
    }
    
    NSURLRequest* req = [NSURLRequest requestWithURL:product.previewURL];
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIActivityIndicatorView* indicator = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicator"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"image"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [indicator stopAnimating];
        imageView.image = nil;
    });
    [imageView cancelImageRequestOperation];
//    [imageView cancelImageDownloadTask];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
     ProductGroupModel* product = [[self.shoppingCart array] objectAtIndex:indexPath.row];
    if(self.shoppingCartDelegate && [self.shoppingCartDelegate respondsToSelector:@selector(didSelectProductForDetail:)]){
        [self.shoppingCartDelegate didSelectProductForDetail:product];
    }
    
}


- (void)shoppingCartItem:(id<HasID>)item updatedQuantityTo:(NSUInteger)quantity {
    [self.shoppingCart updateItem:item toQuantity:quantity];
    if (quantity == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.productsCollectionView reloadData];
        });
    }
}

- (void)deleteRowWithButton:(UIButton*)button {
    UIView* view = button;
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    NSIndexPath* indexPath = [self.productsCollectionView indexPathForCell:(UITableViewCell*)view];
    NSUInteger ndx = indexPath.row;
    self.rowForDeletion = ndx;
    NSString* title = [[NLS nls] stringFor:@"remove.item" default:@"Remove item"];
    NSString* msg = [[NLS nls] stringFor:@"remove.itemAlert"
                                 default:@"Are you sure you want to remove this "
                                         @"item from your Wishlist?"];
    NSString* cancel = [[NLS nls] stringFor:@"share.cancelText" default:@"Cancel"];
    NSString* yes = [[NLS nls] stringFor:@"global.yesButtonText" default:@"Yes"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:yes, nil];
    [alert show];
}

- (void)alertView:(UIAlertView*)alert didDismissWithButtonIndex:(NSInteger)ndx {
    if (ndx) {
        ProductGroupModel* pm = (ProductGroupModel*)[[self.shoppingCart array] objectAtIndex:self.rowForDeletion];
        [self.shoppingCart removeItem:pm];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.productsCollectionView reloadData];
        });
        
        if (self.isWishlist) {
            [[FIRTrackProxy sharedProxy] trackRemoveFromWishlist:pm];
        }
    }
}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSUInteger ndx = indexPath.row;
//    ProductGroupModel* pm = (ProductGroupModel*)[[self.shoppingCart array] objectAtIndex:ndx];
//    [self.shoppingCart removeItem:pm];
//    if (self.isWishlist) {
//        [[TrackProxy sharedProxy] trackRemoveFromWishlist:pm];
//    }
//    
////    [self.productsCollectionView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}


#pragma mark - Setters and Getters

-(void)setWillHaveTabBar:(BOOL)willHaveTabBar{
    if(willHaveTabBar == true){
        [self.exportButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-54);
        }];
        [self.productsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(@0);
        }];
    }
}

#pragma mark - Handling selection results in child ProductDetailView (handling wishlist selection bubbling for tabbaritem badges)

- (void)productDetailView:(ProductDetailView *)view didSelectResult:(ProductDetailViewResult *)result {
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(productDetailView:didSelectResult:)]) {
        [self.productDetailViewDelegate productDetailView:view didSelectResult:result];
    }
}

#pragma mark - Favoriting

-(void)updateCartWithItem:(UIButton*)sender{
    BOOL cartWillNotHaveProduct = true;
    UIButton* heartView = sender;
    UICollectionViewCell* cell = (UICollectionViewCell*)heartView.superview.superview;
    
    if(!cell){
        return;
    }
    NSIndexPath *path = [self.productsCollectionView indexPathForCell:cell];
    ProductGroupModel* product = [[self.shoppingCart array] objectAtIndex:path.row];
    if([self.productDetailViewDelegate respondsToSelector:@selector(checkIfCartContainsItem:)]){
        cartWillNotHaveProduct = [self checkIfCartContainsItem:product];
    }
    
    ShoppingCart* cart = [[ShoppingCart alloc] init];
    ProductEntityModel* test = product.firstEntity;
    [cart addItem:product inQuantity:1];
    
    ProductDetailViewResult* result = [[ProductDetailViewResult alloc] init];
    result.result = cart;
    result.resultType = ProductDetailViewResultTypeWishlist;
    
    [self productDetailView:self didSelectResult:result];
    //    [TrackProxy sharedProxy].catalogModel = product.catalog;
    //    [[TrackProxy sharedProxy] trackAddWishListGroup:product];
    
    if(cartWillNotHaveProduct == true){
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[Icons sharedIcons].heartIconEmptyImage() forState:UIControlStateNormal];
        });
        
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[Icons sharedIcons].heartIconImage() forState:UIControlStateNormal];
        });
    }
    
}

-(BOOL)checkIfCartContainsItem:(ProductGroupModel*)item{
    // Just bubble it up!
    if (self.productDetailViewDelegate && [self.productDetailViewDelegate respondsToSelector:@selector(checkIfCartContainsItem:)]) {
        return [self.productDetailViewDelegate checkIfCartContainsItem:item];
    }
    return false;
}

- (NSString*)currencyStringFrom:(NSNumber*)n {
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    f.locale = [NLS nls].locale;
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    return [f stringFromNumber:n];
}



@end
