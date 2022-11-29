//
//  NLS.h
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/13/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLS : NSObject

+ (NLS*)nlsWithName:(NSString*)name andValidLocales:(NSArray*)locales;
+ (NLS*)nls;
+ (void)setNLS:(NLS*)nls;
+ (NSString*)currencyStringFrom:(NSNumber*)n;

- (NSString*)stringFor:(NSString*)key default:(NSString*)def;
- (NSString*)pluralizedStringFor:(NSString*)key withCount:(NSInteger)n default:(NSString*)def;
- (NSDictionary*)stringsForLocale:(NSLocale*)locale;
- (void)setCurrentLocale:(NSLocale*)locale;

@property (readwrite) NSLocale* locale;
@property (readwrite) NSDictionary* localeToFile;
@property (readwrite) NSDictionary* currentStrings;
/** A list of valid locales. Locales not contained in this list will only be shown in debug builds. 
 If this list is empty all locales will be shown in all builds.
 */
@property (readwrite) NSArray* validLocales;

@end
