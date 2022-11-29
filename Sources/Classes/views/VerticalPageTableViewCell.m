//
//  VerticalPageTableViewCell.m
//  Pods
//
//  Created by Rijul Gupta on 6/27/17.
//
//

#import "VerticalPageTableViewCell.h"
#import "MasterConfiguration.h"
#import "Icons.h"
#import "UIImageView+Offline.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation VerticalPageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView* itemView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.pageImageView = itemView;
        
        self.pageImageView.layer.borderWidth  = 1.0f;
        self.pageImageView.layer.masksToBounds = YES;
      //  RAC(self, itemView.panelItem) = RACObserve(self, panelItem);
    }
    return self;
}


- (void)prepareForReuse {
    //[self.indicatorView stopAnimating];
}

+ (NSString*)identifier {
    return @"VerticalPageTableViewCell";
}

@end
