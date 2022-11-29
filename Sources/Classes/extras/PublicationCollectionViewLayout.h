//
//  PublicationCollectionViewLayout.h
//  Pods
//
//  Created by Schell Scivally on 4/14/16.
//
//

#import <UIKit/UIKit.h>

/** A UICollecitonViewLayout for laying out the pages of a publication. */
@interface PublicationCollectionViewLayout : UICollectionViewLayout

/** The size of a page image. */
@property (readwrite) CGSize imageSize;
@property (readwrite) BOOL usesSinglePages;
@property (readwrite) BOOL hasCover;

@end
