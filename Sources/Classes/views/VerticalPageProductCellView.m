//
//  VerticalPageProductCellView.m
//  Pods
//
//  Created by Rijul Gupta on 6/27/17.
//
//

#import "VerticalPageProductCellView.h"
#import "MasterConfiguration.h"
#import "Icons.h"
#import "UIImageView+Offline.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation VerticalPageProductCellView
static Class __verticalPageProductCellViewClass = nil;
+ (Class)DIClass {
    if (!__verticalPageProductCellViewClass) {
        __verticalPageProductCellViewClass = [VerticalPageProductCellView class];
    }
    return __verticalPageProductCellViewClass;
}

+ (void)setDIClass:(Class)c {
    if ([c isSubclassOfClass:[VerticalPageProductCellView class]]) {
        __verticalPageProductCellViewClass = c;
    } else {
        [NSException raise:@"Class is not a subclass of VerticalPageProductCellView" format:@""];
    }
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        VerticalProductItemView* itemView = [[[VerticalProductItemView DIClass] alloc] initWithFrame:CGRectZero];
        itemView.removePanelItemDelegate = self;
        [self.contentView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.borderTag = 0;
        self.itemView = itemView;
        RAC(self, itemView.panelItem) = RACObserve(self, panelItem);
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (selected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.itemView.layer.borderColor  = config.productCellHighlightTopBorderColor.CGColor;
                self.itemView.layer.borderWidth = 1.0;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.itemView.layer.borderColor  = UIColor.clearColor.CGColor;
                self.itemView.layer.borderWidth = 0.0;
            });
        }
    } completion:^(BOOL finished) { }];

}

-(void)toggleBorderShow{
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.itemView.layer.borderColor  = config.toggleVerticalProductsLabelColor.CGColor;
        self.itemView.layer.borderWidth = 2.0;
    });
}

-(void)toggleBorderHide{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.itemView.layer.borderColor = UIColor.clearColor.CGColor;
        self.itemView.layer.borderWidth = 0.0;
    });
}
- (void)prepareForReuse {
    //[self.indicatorView stopAnimating];
}

+ (NSString*)identifier {
    return @"VerticalPageProductCellView";
}

#pragma mark - Remove Panel Item Products with failing images
-(void)removePanelItemForProductWithId:(ProductGroupModel *)productGroupModel{
    if(self.removePanelItemDelegate){
        [self.removePanelItemDelegate removePanelItemForProductWithId:productGroupModel];
    }
}
@end
