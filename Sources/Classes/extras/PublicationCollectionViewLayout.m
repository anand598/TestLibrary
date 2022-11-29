//
//  PublicationCollectionViewLayout.m
//  Pods
//
//  Created by Schell Scivally on 4/14/16.
//
//

#import "PublicationCollectionViewLayout.h"
#import "UIImageView+ContentScale.h"

@interface PublicationCollectionViewLayout ()
@end

@implementation PublicationCollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        self.imageSize = CGSizeZero;
        self.usesSinglePages = NO;
        self.hasCover = YES;
    }
    return self;
}

- (CGSize)viewSize {
    return self.collectionView.bounds.size;
}

- (CGSize)pageSize {
    CGSize size = [self viewSize];
    size.width /= 2;
    return size;
}

- (BOOL)isLandscape {
    return [self viewSize].width > [self viewSize].height;
}

- (CGSize)collectionViewContentSize {
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    if ([self isLandscape] && !self.usesSinglePages) {
        CGSize size = [self viewSize];
        size.width /= 2;
        NSUInteger covers = self.hasCover ? 2 : 0;
        size.width *= (numberOfItems + covers);
        return size;
    }
    return CGSizeMake([self viewSize].width * numberOfItems, [self viewSize].height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    if (numberOfItems == 0) {
        return nil;
    }
    NSUInteger leftNdx  = [self indexOfPageAtOffset:CGRectGetMinX(rect) - 0.1];
    NSUInteger rightNdx = [self indexOfPageAtOffset:CGRectGetMaxX(rect) + 0.1];
    NSLog(@"%s %lu %lu",__func__,(unsigned long)leftNdx,(unsigned long)rightNdx);
    if (rightNdx >= numberOfItems) {
        @throw [NSError errorWithDomain:@"caught out of bounds" code:666 userInfo:nil];
    }
    NSArray* atts = @[];
    for (NSUInteger i = leftNdx; i <= rightNdx; i++) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes* att = [self layoutAttributesForItemAtIndexPath:path];
        atts = [atts arrayByAddingObject:att];
    }
    return atts;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* att = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    att.frame = [self frameForCellAtIndex:indexPath.row];
    return att;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSUInteger)indexOfPageAtOffset:(CGFloat)offset {
    NSUInteger n = [self.collectionView numberOfItemsInSection:0];
    if (self.pageSize.width == 0 || n == 0) {
        return 0;
    }
    
    if (![self isLandscape] || self.usesSinglePages) {
        NSUInteger ndx = offset / [self viewSize].width;
        if (ndx >= n) {
            return n - 1;
        }
        return ndx;
    } else if (!self.hasCover) {
        NSUInteger ndx = offset / ([self viewSize].width / 2);
        if (ndx >= n) {
            return n - 1;
        }
        return ndx;
    }
    
    CGFloat pagesIn = (offset - 0.1) / self.pageSize.width;
    NSInteger unAdjustedPageIndex = pagesIn;
    NSInteger adjustedPageIndex = unAdjustedPageIndex - 1;
    if (adjustedPageIndex < 0) {
        return 0;
    }
    if (adjustedPageIndex >= n) {
        return n - 1;
    }
    return adjustedPageIndex;
}

- (CGRect)frameForCellAtIndex:(NSUInteger)ndx {
    if (![self isLandscape]) {
        return CGRectMake([self viewSize].width * ndx, 0, [self viewSize].width, [self viewSize].height);
    }
    
    if (self.pageSize.width == 0) {
        return CGRectZero;
    }
    
    if (CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        self.imageSize = self.pageSize;
    }
    
    CGSize fitSize = [UIImageView aspectFitSize:self.imageSize insideSize:self.pageSize];
    CGFloat horz = (self.pageSize.width - fitSize.width)/2;
    
    if (!self.usesSinglePages && self.hasCover) {
        // Spread mode with a front and back cover
        // Front cover
        if (ndx == 0) {
            return CGRectMake(self.pageSize.width * 0.5 + horz, 0, fitSize.width, fitSize.height);
        }
        
        if (ndx < [self.collectionView numberOfItemsInSection:0] -1) {
            // Make an adjustment for left and right pages.
            CGFloat horzAdjustment = (ndx % 2) ? horz : -horz;
            return CGRectMake(horz + horzAdjustment + (self.pageSize.width * 2) + (self.pageSize.width * (ndx - 1)), 0, fitSize.width, fitSize.height);
        }
        
        // Back cover
        return CGRectMake(horz + (self.pageSize.width * 2) + (self.pageSize.width * (ndx - 1)) + (self.pageSize.width * 0.5), 0, fitSize.width, fitSize.height);
    } else if (!self.hasCover) {
        // Spread mode, but without covers
        // Make an adjustment for left and right pages.
        CGFloat horzAdjustment = (ndx % 2) ? -horz : horz;
        return CGRectMake(horz + horzAdjustment + (self.pageSize.width * ndx), 0, fitSize.width, fitSize.height);
    } else {
        // Single page mode
        fitSize = [UIImageView aspectFitSize:self.imageSize insideSize:[self viewSize]];
        horz = ([self viewSize].width - fitSize.width)/2;
        return CGRectMake((self.viewSize.width * ndx) + horz, 0, fitSize.width, fitSize.height);
    }
}

@end
