//
//  ScanShopSelectionDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 1/16/18.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ScanShopResult.h>
#import <SyndecaSDK/PageModel.h>

@protocol ScanShopSelectionDelegate <NSObject>

- (void)didSelectScanResult:(ScanShopResult*)result;
- (void)didSelectPage:(PageModel*)page;

-(BOOL)shouldForceWebView;
-(BOOL)shouldRemoveResultsView;

@end

