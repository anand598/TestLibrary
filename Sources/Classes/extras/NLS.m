//
//  NLS.m
//  Syndeca iOS SDK
//
//  Created by Schell Scivally on 10/13/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "NLS.h"
#import "SyndecaSDK.h"
#import "SyndecaConfig.h"

@implementation NLS

- (id)initWithStringsBundlePath:(NSString*)bundle andValidLocales:(NSArray*)locales {
    self = [super init];
    if (self) {
        NSArray* files = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:bundle error:nil];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        
        // MKYQA-543
        // Filter locales to only show live markets.
        for (NSString* filename in files) {
            NSString* key = [filename stringByDeletingPathExtension];
            if ([locales count] != 0 && !IS_DEBUG && ![locales containsObject:key]) {
                continue;
            }
            NSString* val = [bundle stringByAppendingPathComponent:filename];
            [dict setObject:val forKey:key];
        }
        // Store the list of valid locales so other NLS can use them.
        self.validLocales = locales;
        self.localeToFile = [NSDictionary dictionaryWithDictionary:dict];
      
        [self setCurrentLocale:[NSLocale currentLocale]];
    }
    return self;
}

static NLS* __nls = nil;
+ (NLS*)nls {
    if (!__nls) {
        __nls = [NLS nlsWithName:@"viewer" andValidLocales:@[]];
    }
    return __nls;
}

+ (NLS*)nlsWithName:(NSString *)name andValidLocales:(NSArray *)locales {
    NSString* bundle = [[NSBundle mainBundle] pathForResource:name
                                                       ofType:@"bundle"];
    NLS* nls = [[NLS alloc] initWithStringsBundlePath:bundle andValidLocales:locales];
    if (__nls) {
        [nls setCurrentLocale:[NLS nls].locale];
    }
    return nls;
}

+ (void)setNLS:(NLS*)nls {
    __nls = nls;
}

+ (NSString*)currencyStringFrom:(NSNumber*)n {
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    f.locale = [NLS nls].locale;
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    return [f stringFromNumber:n];
}

- (NSDictionary*)stringsForLocale:(NSLocale *)locale {
    NSString* path = [self.localeToFile objectForKey:[locale localeIdentifier]];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

- (NSString*)stringFor:(NSString *)key default:(NSString *)def {
    NSString* val = [self.currentStrings objectForKey:key];
    if (val) {
        return val;
    }
    return def;
}

- (NSString*)pluralizedStringFor:(NSString*)key withCount:(NSInteger)n default:(NSString*)def {
    NSString* val = [self stringFor:key default:def];
    
    NSArray* comps = [val componentsSeparatedByString:@"|"];
    if ([comps count] <= 1) {
        return val;
    }
    
    NSString* interp = comps[1];
    if (n == 1) {
        interp = comps[0];
    }
    
    NSString* str = [NSString stringWithFormat:@"%li",(long)n];
    
    return [interp stringByReplacingOccurrencesOfString:@"%count%" withString:str];
}

- (void)setCurrentLocale:(NSLocale *)locale {
    self.locale = locale;
    self.currentStrings = [self stringsForLocale:self.locale];
    if (!self.currentStrings) {
        NSLog(@"WARNING! There is no nls strings file for locale %@",locale);
    }
}

@end
