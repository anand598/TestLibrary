//
//  Icons.m
//  Syndeca iOS SDK
//
//  Created by Schell on 11/18/13.
//  Copyright (c) 2013 Schell Scivally. All rights reserved.
//

#import "Icons.h"
#import "UIImage+SyndecaSDK.h"
#import "FontAwesomeKit.h"

@implementation Icons
SYNTHESIZE_DI

- (id)init {
    self = [super init];
    if (self) {

        self.homeIconImage = ^ UIImage* () {
             return [UIImage SDKImageNamed:@"the-essentials-2569"];
        };
        self.catalogIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2635"];
        };

        self.heartIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2622-pink"];
        };
        
        self.heartIconEmptyImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2622"];
        };

        self.bagIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"e-commerce-1193"];
        };

        self.thLargeIconImage = ^UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_155_show_big_thumbnails"];
        };
        self.cartIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_202_shopping_cart"];
        };
        self.reorderIconImage = ^ UIImage* () {
            FAKFontAwesome* reorder = [FAKFontAwesome barsIconWithSize:20];
            [reorder addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage* reorderImg = [reorder imageWithSize:CGSizeMake(20, 20)];
            return reorderImg;
        };
        self.emailIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2597"];
            FAKFontAwesome* email = [FAKFontAwesome envelopeIconWithSize:48];
            UIImage* reorderImg = [email imageWithSize:CGSizeMake(48, 48)];
            return reorderImg;
        };
        self.removeIconImage = ^ UIImage* () {
            FAKFontAwesome* close = [FAKFontAwesome timesCircleIconWithSize:48];
            return [close imageWithSize:CGSizeMake(48, 48)];
        };
        self.checkIconImage = ^ UIImage* () {
            FAKFontAwesome* check = [FAKFontAwesome checkCircleIconWithSize:48];
            return [check imageWithSize:CGSizeMake(48, 48)];
        };
        self.globeIconImage = ^ UIImage* () {
            return nil;
        };
        self.saveToDiskImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_414_disk_save"];
        };
        self.removeFromDiskImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2669"];
        };
        self.cogIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_136_cogwheel"];
        };
        self.searchIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2678"];
        };
        self.giftIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_069_gift"];
        };
        self.bookmarkIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_351_book_open"];
        };
        self.playIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"glyphicons_220_play_button"];
        };
        
        self.hamburgerMenuImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-hamburger"];
        };
        self.backButtonImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"arrows-0024"];
        };
        self.cameraButtonImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"gadgets-1512"];
        };
        
        self.hamburgerHomeIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2569"];
        };
        self.hamburgerCameraButtonImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"gadgets-1512"];
        };
        self.hamburgerEmailIconImage = ^ UIImage* () {
            return [UIImage SDKImageNamed:@"the-essentials-2597"];
        };
        
        
        
    }
    return self;
}

static Icons* __sharedIcons = nil;
+ (Icons*)sharedIcons {
    if (!__sharedIcons) {
        __sharedIcons = [[Icons alloc] init];
    }
    return __sharedIcons;
}

+ (void)setSharedIcons:(Icons*)icons {
    __sharedIcons = icons;
}

@end
