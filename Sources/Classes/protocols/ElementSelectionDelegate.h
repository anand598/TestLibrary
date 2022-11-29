//
//  ElementSelectionDelegate.h
//  Pods
//
//  Created by Schell Scivally on 1/22/16.
//
//

#import <Foundation/Foundation.h>
#import <SyndecaSDK/ElementModel.h>

@protocol ElementSelectionDelegate <NSObject>
/** Called when a container catches a tap inside a mapped on page element. */
- (void)pageView:(id)pageView didSelectElement:(ElementModel*)element;
@end
