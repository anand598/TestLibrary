//
//  CollectionReusableImageView.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "CollectionImageViewCell.h"
#import <Masonry/Masonry.h>

@implementation CollectionImageViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imageView];
        
        self.descriptionTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont* f = [self.descriptionTextLabel.font fontWithSize:[UIFont smallSystemFontSize]];
        self.descriptionTextLabel.font = f;
        self.descriptionTextLabel.numberOfLines = 1;
        self.descriptionTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.descriptionTextLabel];
        
        UIFontDescriptor* fontDescriptor = [self.descriptionTextLabel.font fontDescriptor];
        UIFontDescriptor* boldFontDescriptor = [fontDescriptor
                                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont* boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:[UIFont smallSystemFontSize]];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.font = boldFont;
        self.textLabel.numberOfLines = 1;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        
        self.subTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subTextLabel.font = f;
        self.subTextLabel.numberOfLines = 2;
        self.subTextLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.subTextLabel];

        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.indicatorView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(@(0));
        make.width.equalTo(self.contentView.mas_width);
        make.bottom.equalTo(self.textLabel.mas_top);
        make.height.equalTo(self.contentView.mas_height).offset(-48);
    }];

    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.subTextLabel.mas_top);
        /*
        if (self.textLabel.text && ![self.textLabel.text isEqualToString:@""]) {
          //  make.height.equalTo(@(32));
        } else {
            make.height.equalTo(@(0));
        }
         */
        make.left.equalTo(@(0));
        make.width.equalTo(self.contentView.mas_width);
    }];
    
   
    [self.subTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.descriptionTextLabel.mas_top);
        /*
        if (self.subTextLabel.text && ![self.subTextLabel.text isEqualToString:@""]) {
    //        make.height.equalTo(@(32));
        } else {
            make.height.equalTo(@(0));
        }
         */
        make.left.equalTo(@(0));
        make.width.equalTo(self.contentView.mas_width);
    }];
    [self.descriptionTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        /*
        if (self.descriptionTextLabel.text && ![self.descriptionTextLabel.text isEqualToString:@""]) {
      //      make.height.equalTo(@(16));
        } else {
            make.height.equalTo(@(0));
        }
         */
        make.left.equalTo(@(0));
        make.width.equalTo(self.contentView.mas_width);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

@end
