//
//  SearchModel.h
//  SyndecaSDK
//
//  Created by Schell Scivally on 6/20/21.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/GuideModel.h>

NS_ASSUME_NONNULL_BEGIN

/* One item in an array of results obtained by sending a search request to the API. */
@interface SearchModel : NSObject

@property (readwrite) NSString* index;
@property (readwrite) NSString* type;
@property (readwrite) NSString* ID;
@property (readwrite) CGFloat score;

@property (readwrite) NSString* catalogLink;
@property (readwrite) NSString* title;
@property (readwrite) NSString* desc;
@property (readwrite) NSURL* thumb;

- (id)initWithInfo:(NSDictionary*)info fromGuide:(GuideModel*)guide;

@end

NS_ASSUME_NONNULL_END
