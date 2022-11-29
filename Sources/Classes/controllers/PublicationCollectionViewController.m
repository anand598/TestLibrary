//
//  PublicationCollectionViewController.m
//  Pods
//
//  Created by Schell Scivally on 4/12/16.
//
//

#import "PublicationCollectionViewController.h"
#import "IssueModel.h"
#import "MasterConfiguration.h"
#import "ItemSelection.h"
#import "UICollectionViewCell+ContentViews.h"
#import "UIViewHelper.h"
#import "UIImageView+ContentScale.h"
#import "Fonts.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "MasterConfiguration.h"

@interface PublicationCollectionViewController ()
@property (readwrite) UIImageView* bannerImage;
@property (readwrite) UILabel* shopCatalogsLabel;

@end

@implementation PublicationCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.skipToFeaturedPublication = [MasterConfiguration sharedConfiguration].skipToFeaturedCatalog;
        self.titleFont = nil;
    }
    return self;
}

- (void)viewDidLoad {
    
//    Required to work with non-translucent tab bars
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];

    self.bannerImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.bannerImage.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.bannerImage];
    
    self.shopCatalogsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.shopCatalogsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]];
    [self.shopCatalogsLabel setTextColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.shopCatalogsLabel];
    
    self.shopCatalogsLabel.text = @"Shop Our Catalogs";
    
    //we have 150 pixels to lay these out
    
    if(IS_IPAD){
        [self.bannerImage mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.view.mas_left).offset(8);
            make.right.equalTo(self.view.mas_right).offset(-8);
            make.top.equalTo(self.view.mas_top).offset([[MasterConfiguration sharedConfiguration] iPadBannerImageTop]);
            make.height.equalTo(@([[MasterConfiguration sharedConfiguration] iPadBannerImageHeight]));
        }];
    }else{
        [self.bannerImage mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.view.mas_left).offset(8);
            make.right.equalTo(self.view.mas_right).offset(-8);
            make.top.equalTo(self.view.mas_top).offset([[MasterConfiguration sharedConfiguration] iPadBannerImageTop]);
            make.height.equalTo(@([[MasterConfiguration sharedConfiguration] iPhoneBannerImageHeight]));
        }];
    }
    
    
    [self.shopCatalogsLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left).offset(8);
        make.top.equalTo(self.bannerImage.mas_bottom).offset(6);
        make.height.greaterThanOrEqualTo(@25);
    }];
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shopCatalogsLabel.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(8);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(-52);//-52 for the bottom tabbar
    }];
    
    [self.collectionView reloadData];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    
    
}

-(void)setVerticalLayout{
    //    We don't include a left-side offset if we are showing vertical, this allows the publication to be centered in the view
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shopCatalogsLabel.mas_bottom).offset(32);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(-83);//-83 for the bottom tabbar
    }];
}

#pragma mark - Updating the Publications

- (void)setPublications:(NSArray *)issues {
    _publications = issues;
    [self.collectionView reloadData];
    if(self.skipToFeaturedPublication || (issues.count == 1 && self.hasShownPages == false)){
        self.hasShownPages = true;
        if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
            
            IssueModel* issue = [issues objectAtIndex:0];
            ItemSelection* selection = [[ItemSelection alloc] init];
            selection.selection = issue;
            selection.selectionType = ItemSelectionTypeIssue;
            [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
        }
    } else{
        
    }
}

#pragma mark - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_publications == nil) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 1){
        return 0;
    }
    if (_publications == nil) {
        return 0;
    }
    return [_publications count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the general cell and it's properties
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setupContentViewOfImageWithLabelId:@"label" andImageViewId:@"imageView" andActivityIndicator:@"indicator"];
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    UIActivityIndicatorView* indicatorView = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicator"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    
    //perform the iPad Portrait layout
    if(IS_IPAD){
        [label mas_remakeConstraints:^(MASConstraintMaker* make){
            make.left.equalTo(imageView.mas_left).offset(0);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(cell.contentView.mas_width).offset(0);
            make.height.equalTo(@(24));
            
        }];
    } else { //set up the iPhone layout
        [label mas_remakeConstraints:^(MASConstraintMaker* make){
            make.left.equalTo(imageView.mas_left).offset(4);
            make.bottom.equalTo(cell.contentView.mas_bottom);
            make.width.equalTo(cell.contentView.mas_width).offset(0);
            make.height.equalTo(@(24));
            
        }];
    }
    
    //set up the catalog title label attributes
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextAlignment:NSTextAlignmentCenter];
    UIFont* labelFont = [Fonts fontType:FontTypeNormal withSize:FontSizeBig];
    if (self.titleFont != nil) {
        labelFont = self.titleFont;
    }
    [label setFont:labelFont];
    [label setTextColor:[UIColor grayColor]];
    
    
   
    
    IssueModel* issue = (IssueModel*)[_publications objectAtIndex:indexPath.row];
    NSURLRequest* request = [NSURLRequest requestWithURL:[issue coverURL]];
    dispatch_async(dispatch_get_main_queue(), ^{
      [indicatorView startAnimating];
    });
    
    @weakify(imageView);
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        @strongify(imageView);
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicatorView stopAnimating];
            imageView.image = image;
        });
        // SYN-2232 Adjust the height of the image so that we align bottom.
        if (IS_IPHONE) {
            CGFloat dy = cell.frame.size.height - [UIImageView aspectFitSize:image.size insideSize:cell.frame.size].height;
            [label mas_remakeConstraints:^(MASConstraintMaker* make){
                
                make.left.equalTo(imageView.mas_left).offset(4);
                make.bottom.equalTo(cell.contentView.mas_bottom).offset(-0.5*dy);
                make.width.equalTo(cell.contentView.mas_width).offset(0);
                make.height.equalTo(@(24));
                
            }];
            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(1));
                make.top.equalTo(@(0.5*dy));
                make.width.equalTo(cell.contentView).offset(-1);
                make.bottom.equalTo(label.mas_top).offset(-1);
            }];
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) { }];
    dispatch_async(dispatch_get_main_queue(), ^{
        label.text = issue.title;
    });
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    UIActivityIndicatorView* indicatorView = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicator"];
    [imageView cancelImageRequestOperation];
//    [imageView cancelImageDownloadTask];
    dispatch_async(dispatch_get_main_queue(), ^{
        label.text = nil;
        imageView.image = nil;
        [indicatorView stopAnimating];
    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        IssueModel* issue = [_publications objectAtIndex:indexPath.row];
        ItemSelection* selection = [[ItemSelection alloc] init];
        selection.selection = issue;
        selection.selectionType = ItemSelectionTypeIssue;
        [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
    }
}



@end
