//
//  SyndecaRequestDelegate.h
//  CocoaViewer
//
//  Created by Schell Scivally on 11/16/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SyndecaRequest;

@protocol SyndecaRequestDelegate <NSObject>

/** Called by the SyndecaRequest on start. */
- (void)requestDidStart:(SyndecaRequest*)request;
/** Called by the SyndecaRequest on finish. */
- (void)requestDidFinish:(SyndecaRequest*)request;
/** Called by the SyndecaRequest on fail. */
- (void)requestDidFail:(SyndecaRequest*)request;

@end
