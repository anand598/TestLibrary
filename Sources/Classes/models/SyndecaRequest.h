//
//  SyndecaRequest.h
//  CocoaViewer
//
//  Created by Schell Scivally on 11/16/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/SyndecaRequestDelegate.h>
#import <SyndecaSDK/SyndecaOpImplementationAF2.h>

/** All the different types of syndeca service requests. */
typedef enum {
    SyndecaRequestType_Unknown,
    SyndecaRequestType_Guide,
    SyndecaRequestType_Catalog,
    SyndecaRequestType_Product,
    SyndecaRequestType_ProductMany,
    SyndecaRequestType_SharalityList,
    SyndecaRequestType_SharalityIcons,
    SyndecaRequestType_SharalityURL,
    SyndecaRequestType_Tracking
} SyndecaRequestType;

/** The status types of a request. */
typedef enum {
    SyndecaRequestStatus_None,
    SyndecaRequestStatus_Started,
    SyndecaRequestStatus_Successful,
    SyndecaRequestStatus_Failed
} SyndecaRequestStatus;

/** The method of the request. */
typedef enum {
    SyndecaRequestMethod_Default,
    SyndecaRequestMethod_Head
} SyndecaRequestMethod;

/** The name of the download complete event. 
 Used for testing. 
 */
static NSString* const SyndecaRequestComplete = @"syndecaRequestComplete";

/** The block sig that handles a successful request. */
typedef void (^SyndecaRequestCompleteBlock)(SyndecaRequest* request);

/** The block that handles an error during the request. 
 The NSError's userInfo dictionary will contain the original request.
 */
typedef void (^SyndecaRequestFailBlock)(NSError* error);

/** The request object. */
@interface SyndecaRequest : NSObject

#pragma mark - Control
/** Starts the request. */
- (void)start;
/** Starts the request with some blocks instead of delegation. */
- (void)startWithCompleteBlock:(SyndecaRequestCompleteBlock)complete andError:(SyndecaRequestFailBlock)error;
/** Cancels the request. */
- (void)cancel;
/** Sets the archive flag on the request. */
- (void)enableArchiveFlag;

#pragma mark - Properties
/** The underlying request operation implementation. */
@property (readwrite) SyndecaOpImplementationAF2* operation;
/** The resource path string. */
@property (readwrite) NSString* resource;
/** The result of the request. */
@property (readwrite) id result;
/** The status delegate of this request. */
@property (readwrite) id<SyndecaRequestDelegate> delegate;
/** The type of the request. */
@property (readwrite) SyndecaRequestType type;
/** The method of the request. */
@property (readwrite) SyndecaRequestMethod method;
/** The status of the request. */
@property (readwrite) SyndecaRequestStatus status;
/** The post variables. */
@property (readwrite) NSData* postData;

@end
