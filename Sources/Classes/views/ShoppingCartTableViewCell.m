//
//  AddToBagTableViewCell.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 9/18/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ShoppingCartTableViewCell.h"
#import "UIImageView+Offline.h"
#import "MasterConfiguration.h"
#import "Icons.h"
#import "Fonts.h"
#import "Masonry.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@implementation ShoppingCartTableViewCell

- (id)init {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[ShoppingCartTableViewCell cellIdentifier]];
    if (self) {
        @weakify(self);
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.indicatorView];
        
        self.textLabel.font = [Fonts fontType:FontTypeNormal
                                     withSize:FontSizeSmall];
        self.detailTextLabel.font = [self.detailTextLabel.font fontWithSize:10];
        self.imageView.backgroundColor = [UIColor clearColor];
        
        self.quantity = 0;
        
        self.quantityField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.quantityField.font = [Fonts fontType:FontTypeNormal
                                         withSize:FontSizeSmall];
        RAC(self, quantityField.text) = [RACObserve(self, quantity) map:^NSString* (NSNumber* value) {
            return [NSString stringWithFormat:@" %i",[value intValue]];
        }];
        self.quantityField.layer.borderColor = [[UIColor grayColor] CGColor];
        self.quantityField.layer.borderWidth = 1;
        self.quantityField.layer.cornerRadius = 2;
        self.quantityField.backgroundColor = [UIColor whiteColor];
        self.quantityField.delegate = self;
        self.quantityField.keyboardType = UIKeyboardTypeNumberPad;
        [self.contentView addSubview:self.quantityField];
        
        self.amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.amountLabel.font = [Fonts fontType:FontTypeNormal
                                       withSize:FontSizeSmall];
        RAC(self, amountLabel.text) = [RACObserve(self, quantity) map:^id(id value) {
            return [NSString stringWithFormat:@"$.%.2f", [value floatValue]];
        }];
        [self.contentView addSubview:self.amountLabel];
        
        self.quantityDone = [[UIButton alloc] initWithFrame:CGRectZero];
        
        UIImage* done = [[Icons sharedIcons].checkIconImage()
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.quantityDone setImage:done forState:UIControlStateNormal];
        self.quantityDone.tintColor = [UIColor colorWithRed:0.36 green:0.67 blue:0.30 alpha:1];
        self.quantityDone.alpha = 0;
        [self.contentView addSubview:self.quantityDone];
        [[self.quantityDone
         rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if ([self.quantityField isFirstResponder]) {
                [self.quantityField resignFirstResponder];
            }
        }];
    }
    
    return self;
}

#pragma mark - Class Meth

+ (NSString*)cellIdentifier {
    return @"addtobagcell";
}

+ (CGFloat)quantityOffsetInView:(UIView*)view {
    return view.frame.size.width * 0.52;
}

+ (CGFloat)amountOffsetInView:(UIView*)view {
    return view.frame.size.width * 3/4;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat qtyx = [ShoppingCartTableViewCell quantityOffsetInView:self];
    CGRect qty = CGRectMake(qtyx, 10, 50, 24);
    self.quantityField.frame = qty;
    
    CGFloat amtx = [ShoppingCartTableViewCell amountOffsetInView:self];
    CGRect amount = CGRectMake(amtx, 10, 100, 50);
    self.amountLabel.frame = amount;
    [self.amountLabel sizeToFit];
    
    CGRect text = self.textLabel.frame;
    text.size.width = qtyx - text.origin.x;
    self.textLabel.frame = text;
    
    CGRect detail = self.detailTextLabel.frame;
    detail.size.width = text.size.width;
    self.detailTextLabel.frame = detail;
    
    self.indicatorView.center = CGPointMake(20, 20);
    
    CGPoint center = self.contentView.center;
    CGRect done = CGRectMake(0, 0, 30, 30);
    CGPoint dcenter = center;
    self.quantityDone.frame = done;
    dcenter.x = CGRectGetMaxX(self.quantityField.frame) + 20;
    self.quantityDone.center = dcenter;
    
    CGPoint acenter = center;
    acenter.x = self.frame.size.width - self.accessoryView.frame.size.width/2;
    self.accessoryView.center = acenter;
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.quantityDone.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark - Responding to changes of quantity

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.quantity = [self.quantityField.text intValue];
    if (self.shoppingCartItemDelegate && [self.shoppingCartItemDelegate respondsToSelector:@selector(shoppingCartItem:updatedQuantityTo:)]) {
        [self.shoppingCartItemDelegate shoppingCartItem:self.productModel updatedQuantityTo:self.quantity];
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.quantityDone.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet* s = [NSCharacterSet characterSetWithCharactersInString:string];
    NSCharacterSet* n = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    if ([s isSupersetOfSet:n]) {
        [self.quantityField resignFirstResponder];
    }
    
    NSLog(@"%@",string);
    NSCharacterSet* nums = [NSCharacterSet decimalDigitCharacterSet];
    
    if ([nums isSupersetOfSet:s]) {
        // SYN-817
        // Wishlist - limit QTY box to 2 digits or '99'
        int i = [[self.quantityField.text stringByAppendingString:string] intValue];
        if (i <= 99) {
            [self setNeedsLayout];
            return YES;
        }
    }
    return NO;
}

@end
