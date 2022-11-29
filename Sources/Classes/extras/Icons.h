//
//  Icons.h
//  Syndeca iOS SDK
//
//  Created by Schell on 11/18/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SyndecaSDK/DependencyInjection.h>

typedef UIImage* (^NewIconBlock)(void);

@interface Icons : NSObject <DependencyInjection>

+ (Icons*)sharedIcons;
+ (void)setSharedIcons:(Icons*)icons;

@property (readwrite, copy) NewIconBlock catalogIconImage;
@property (readwrite, copy) NewIconBlock homeIconImage;
@property (readwrite, copy) NewIconBlock heartIconImage;
@property (readwrite, copy) NewIconBlock heartIconEmptyImage;
@property (readwrite, copy) NewIconBlock bagIconImage;
@property (readwrite, copy) NewIconBlock thLargeIconImage;
@property (readwrite, copy) NewIconBlock cartIconImage;
@property (readwrite, copy) NewIconBlock reorderIconImage;
@property (readwrite, copy) NewIconBlock emailIconImage;
@property (readwrite, copy) NewIconBlock removeIconImage;
@property (readwrite, copy) NewIconBlock checkIconImage;
@property (readwrite, copy) NewIconBlock globeIconImage;
@property (readwrite, copy) NewIconBlock saveToDiskImage;
@property (readwrite, copy) NewIconBlock removeFromDiskImage;
@property (readwrite, copy) NewIconBlock cogIconImage;
@property (readwrite, copy) NewIconBlock searchIconImage;
@property (readwrite, copy) NewIconBlock giftIconImage;
@property (readwrite, copy) NewIconBlock bookmarkIconImage;
@property (readwrite, copy) NewIconBlock playIconImage;

@property (readwrite, copy) NewIconBlock cameraButtonImage;
@property (readwrite, copy) NewIconBlock hamburgerMenuImage;
@property (readwrite, copy) NewIconBlock backButtonImage;

@property (readwrite, copy) NewIconBlock hamburgerHomeIconImage;
@property (readwrite, copy) NewIconBlock hamburgerCameraButtonImage;
@property (readwrite, copy) NewIconBlock hamburgerEmailIconImage;
@property (readwrite, copy) NewIconBlock hamburgerPhoneCallIconImage;
@property (readwrite, copy) NewIconBlock hamburgerEventsImage;
@property (readwrite, copy) NewIconBlock hamburgerRequestQuoteImage;
@property (readwrite, copy) NewIconBlock hamburgerCustomerPortalImage;
@property (readwrite, copy) NewIconBlock hamburgerAppFeedbackImage;
@property (readwrite, copy) NewIconBlock hamburgerGlobeIconImage;


@end
