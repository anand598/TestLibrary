//
//  UILabel+HTML.m
//  Nordstrom
//
//  Created by Schell Scivally on 3/30/15.
//  Copyright (c) 2015 Schell Scivally. All rights reserved.
//

#import "UILabel+HTML.h"
#import "UIColor+Hex.h"
//#import "DTCoreText.h"

@implementation UILabel (HTML)

- (void)setHtmlText:(NSString *)htmlText {
    self.attributedText = [self attributedStringFromHtml:htmlText];
}

- (NSString*)htmlText {
    return [self.attributedText string];
}

- (NSAttributedString*)attributedStringFromHtml:(NSString*)htmlText {
    UIFont* font = self.font;
    if (!htmlText) {
        return nil;
    }
    NSString* html = [NSString stringWithFormat:
                      @"<font face=\"%@\" color=\"%@\">%@</font>",
                      font.fontName, [self.textColor asHexString], htmlText];
    NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return [[NSAttributedString alloc] initWithString:htmlText];
//
//    NSAttributedString* test = [[NSAttributedString alloc]
//                               initWithHTMLData:data
//                               options:@{DTUseiOS6Attributes:@YES,
//                                         DTDefaultFontName:font.fontName,
//                                         DTDefaultFontSize:@(font.pointSize)}
//                               documentAttributes:nil];
//
//    NSMutableAttributedString* test2 = [[NSMutableAttributedString alloc] initWithAttributedString:test];
//    NSRange range =  NSMakeRange(0, [test2 length]);
//    [test2 addAttribute:NSParagraphStyleAttributeName value:style range:range];
//
//    return test2;
}

- (NSAttributedString*)attributedStringFromString:(NSString*)htmlText {
    UIFont* font = self.font;
    if (!htmlText) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithString:htmlText];
}

- (NSAttributedString*)underLineBoldAttributedStringFromHTML:(NSString*)htmlText {
    UIFont* font = self.font;
    if (!htmlText) {
        return nil;
    }
    NSString* html = [NSString stringWithFormat:
                      @"<u><font face=\"%@\" color=\"%@\">%@</font></u>",
                      font.fontName, [self.textColor asHexString], htmlText];
    return [[NSAttributedString alloc] initWithString:htmlText];
//    
//    NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
//    return [[NSAttributedString alloc]
//            initWithHTMLData:data
//            options:@{DTUseiOS6Attributes:@YES,
//                      DTDefaultFontName:font.fontName,
//                      DTDefaultFontSize:@(font.pointSize)}
//            documentAttributes:nil];
}

- (NSAttributedString*)strikeOutAttributedStringFromString:(NSString*)text{
    return nil;
}

- (NSString*)stringFromHtml:(NSString*)html {
    NSAttributedString* string = [self attributedStringFromHtml:html];
    return [string string];
}

@end
