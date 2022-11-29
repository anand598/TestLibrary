//
//  UILabel+HTML.h
//  Nordstrom
//
//  Created by Schell Scivally on 3/30/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HTML)

@property (readwrite) NSString* htmlText;

- (NSString*)stringFromHtml:(NSString*)html;
- (NSAttributedString*)attributedStringFromHtml:(NSString*)htmlText;
- (NSAttributedString*)underLineBoldAttributedStringFromHTML:(NSString*)htmlText;
- (NSAttributedString*)attributedStringFromString:(NSString*)htmlText;
- (NSAttributedString*)strikeOutAttributedStringFromString:(NSString*)text;
@end
