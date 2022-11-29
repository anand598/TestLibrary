//
//  RemovePanelItemDelegate.h
//  Pods
//
//  Created by Rijul Gupta on 4/10/18.
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ProductGroupModel.h>

@protocol RemovePanelItemDelegate <NSObject>
- (void)removePanelItemForProductWithId:(ProductGroupModel*)productGroupModel;

@end


