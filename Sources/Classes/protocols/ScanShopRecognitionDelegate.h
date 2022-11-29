//
//  ScanShopRecognitionDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 1/16/18.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/CatalogModel.h>
@protocol ScanShopRecognitionDelegate <NSObject>

- (void)didRecognizeBarCode:(NSString*)productId;
- (void)didRecognizeQRCode:(NSString*)urlString;
- (void)didRecognizeCatalog:(NSString*)catalogId andPage:(NSString*)pageId;

@end

