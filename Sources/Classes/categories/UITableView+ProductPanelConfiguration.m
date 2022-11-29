//
//  PickerView+ProductPanelConfiguration.m
//  Syndeca iOS SDK
//
//  Created by Schell on 5/14/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "UITableView+ProductPanelConfiguration.h"
#import "SyndecaSDK.h"
#import "MasterConfiguration.h"
#import "ProductCellView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation UITableView (ProductPanelConfiguration)

+ (UITableView*)productPanelPickerView {
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    UITableView* picker = [[UITableView alloc] initWithFrame:CGRectZero];
    
    picker.contentInset = config.productPanelContentInset;
    picker.separatorColor = config.productPanelSeparatorColor;
    picker.backgroundColor = config.productPanelBackgroundColor;
    [picker registerClass:[ProductCellView class] forCellReuseIdentifier:[ProductCellView identifier]];

    return picker;
}

@end
