//
//  ProductCellView.m
//  Syndeca iOS SDK
//
//  Created by Schell on 6/5/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ProductCellView.h"
#import "MasterConfiguration.h"
#import "Icons.h"
#import "UIImageView+Offline.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation ProductCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        ProductItemView* itemView = [[ProductItemView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);            
        }];
        self.itemView = itemView;
        
        self.itemView.layer.borderWidth  = 1.0f;
        self.itemView.layer.masksToBounds = YES;
        RAC(self, itemView.panelItem) = RACObserve(self, panelItem);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (selected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.itemView.backgroundColor = config.productCellHighlightTopBackgroundColor;
                self.itemView.saleView.textColor = [UIColor whiteColor];
                self.itemView.layer.borderColor  = config.productCellHighlightTopBorderColor.CGColor;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.itemView.backgroundColor = config.productCellTopBackgroundColor;
                self.itemView.saleView.textColor = [UIColor grayColor];
                self.itemView.layer.borderColor  = config.productCellTopBorderColor.CGColor;
            });
        }
    } completion:^(BOOL finished) { }];
}

- (void)prepareForReuse {
    //[self.indicatorView stopAnimating];
}

+ (NSString*)identifier {
    return @"ProductCellView";
}

@end
