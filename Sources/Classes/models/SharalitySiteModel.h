//
//  SharalitySiteModel.h
//  SyndecaSDK
//
//  Created by Schell Scivally on 2/26/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <SyndecaSDK/SyndecaModel.h> 

@interface SharalitySiteModel : SyndecaModel

-(BOOL)isBookmarkable;
-(BOOL)isEmbedable;
-(NSString*)iconPath;
-(NSString*)key;
-(NSString*)name;

- (NSURL*)iconURLWithWidth:(NSUInteger)width andHeight:(NSUInteger)height;

@end
