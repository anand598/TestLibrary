//
//  CatalogLinkDelegate.h
//  Pods
//
//  Created by Schell Scivally on 10/14/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CatalogLinkDelegate <NSObject>
- (void)linkToCatalog:(NSString*)catalog page:(NSString*)page;
- (void)returnFromPublication;
- (void)returnToRootPublication;
@end

NS_ASSUME_NONNULL_END
