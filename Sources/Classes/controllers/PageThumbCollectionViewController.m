//
//  PageThumbCollectionViewController.m
//  Pods
//
//  Created by Schell Scivally on 4/12/16.
//
//

#import "PageThumbCollectionViewController.h"
#import "MasterConfiguration.h"
#import "UICollectionViewCell+ContentViews.h"
#import "UIImageView+ContentScale.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "UIViewHelper.h"


@interface PageThumbCollectionViewController ()
@property (readwrite) NSUInteger selectedIndex;
@end

@implementation PageThumbCollectionViewController

- (void)viewDidLoad {
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]){
            [self.collectionView setPrefetchingEnabled:NO];
        }
        [self.collectionView reloadData];
    });
   
    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.titleView = titleView;
    });
    
    self.selectedIndex = NSUIntegerMax;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.selectedIndex != NSUIntegerMax) {
        NSIndexPath* ndx = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        [self highlightItemAtIndexPath:ndx];
    }
}

#pragma mark - Updating the Pages

- (void)setPageModels:(NSArray*)pageModels {
    _pageModels = pageModels;
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.collectionView reloadData];
    });
}

#pragma mark - Highlighting a Specific Page

- (void)highlightPageWithModel:(PageModel*)pm {
    NSUInteger ndx = NSUIntegerMax;
    for (PageModel* page in _pageModels) {
        if ([page.ID isEqualToString:pm.ID]) {
            ndx = [_pageModels indexOfObject:page];
            break;
        }
    }
    self.selectedIndex = ndx;
}

#pragma mark - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_pageModels == nil) {
        return 0;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_pageModels == nil) {
        return 0;
    }
    return [_pageModels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //set up the general cell and get the necessary properties
    UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setupContentViewOfImageWithLabelId:@"label" andImageViewId:@"imageView" andActivityIndicator:@"indicator"];
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    UIActivityIndicatorView* indicatorView = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicator"];
    
    //set up the iPad portait design
    
    //set up the iPhone design, only portrait
    if(IS_IPAD && IS_LANDSCAPE){
        
    }
    else if (IS_IPAD && IS_PORTRAIT){
        
    }
    else{
        
    }
    PageModel* page = (PageModel*)[_pageModels objectAtIndex:indexPath.row];
    NSURLRequest* request = [NSURLRequest requestWithURL:[page imageURL]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        label.textColor = [MasterConfiguration sharedConfiguration].tocPageLabelColor;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.frame];
        cell.selectedBackgroundView.backgroundColor = [MasterConfiguration sharedConfiguration].tocPageHighlightColor;
        [indicatorView startAnimating];
        label.text = page.title;
    });
    
         @weakify(imageView);
         [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
             @strongify(imageView);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [indicatorView stopAnimating];
                 imageView.image = image;
             });
             
             if (self.selectedIndex != NSUIntegerMax && indexPath.row == self.selectedIndex) {
                [self performSelector:@selector(highlightCell:) withObject:cell afterDelay:1    inModes:@[NSDefaultRunLoopMode]];
             }
         } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
         }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    UIActivityIndicatorView* indicatorView = (UIActivityIndicatorView*)[cell contentViewWithIdentifier:@"indicatorView"];
    [imageView cancelImageRequestOperation];
//    [imageView cancelImageDownloadTask];
    dispatch_async(dispatch_get_main_queue(), ^{
        label.text = nil;
        imageView.image = nil;
        [indicatorView stopAnimating];
    });
    
}

- (void)highlightItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [self highlightCell:cell];
}

- (void)highlightCell:(UICollectionViewCell*)cell {
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    UIImageView* imageView = (UIImageView*)[cell contentViewWithIdentifier:@"imageView"];
    CGRect frame = imageView.frame;
    UIEdgeInsets insets = [imageView contentInsets];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        label.textColor = [MasterConfiguration sharedConfiguration].tocPageHighlightColor;
        cell.selectedBackgroundView.frame = CGRectMake(frame.origin.x + insets.left - 1,
                                                       frame.origin.y + insets.top - 1,
                                                       frame.size.width - insets.right - insets.left + 2,
                                                       frame.size.height - insets.bottom - insets.top + 2);
    });
    
    [cell setSelected:YES];
}

- (void)unhighlightItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UILabel* label = (UILabel*)[cell contentViewWithIdentifier:@"label"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        label.textColor = [MasterConfiguration sharedConfiguration].tocPageLabelColor;
    });
    [cell setSelected:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        PageModel* issue = [_pageModels objectAtIndex:indexPath.row];
        ItemSelection* selection = [[ItemSelection alloc] init];
        selection.selection = issue;
        selection.selectionType = ItemSelectionTypePage;
        [self.delegate itemContainer:self didMakeSelection:selection];
    }
    
    [self highlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self unhighlightItemAtIndexPath:indexPath];
}

@end
