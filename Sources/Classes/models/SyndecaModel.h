//
//  SyndecaModel.h
//  CocoaViewer
//
//  Created by Schell Scivally on 12/3/12.
//  Copyright (c) 2012 Synapse Group International, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/HasID.h>

/** The base model. Only contains a dictionary object and an method for extracting 
 an ID from the dictionary. */
@interface SyndecaModel : NSObject <HasID>

/** Creates a new model with the given dictionary data. */
- (id)initWithInfo:(NSDictionary*)info;

/** The model's dictionary object. */
@property (readwrite) NSDictionary* info;

/** Returns the ID of this model. */
- (NSString*)ID;

@end
