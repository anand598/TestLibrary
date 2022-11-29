//
//  PageView.m
//  Pods
//
//  Created by Schell Scivally on 1/22/16.
//
//

#import "PageView.h"
#import "VideoModel.h"
#import "ProductGroupModel.h"
#import "UIImageView+ContentScale.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIImage+animatedGIF.h"
#import "UIImage+SyndecaSDK.h"

@interface PageView ()
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) NSDictionary* videoViews;
@end

@implementation PageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicatorView];
        
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(@40);
        }];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPage:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Updating properties

- (void)setPageModel:(PageModel *)pageModel {
    _pageModel = pageModel;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView startAnimating];
    });
    
    
    if (!pageModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = nil;
        });
        return;
    }
    
    @weakify(self);
    // Load the preview image and use it to figure out the scale.
    NSURLRequest* request = [NSURLRequest requestWithURL:pageModel.imageURL];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            [self.indicatorView stopAnimating];
            self.imageView.frame = [self imageViewFrame];
        });
        [self layoutOnPageVideo];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
    [self updateOnPageVideo];
}

- (PageModel*)pageModel {
    return _pageModel;
}

- (void)setPageAlignment:(PageAlignment)pageAlignment {
    _pageAlignment = pageAlignment;
    [self setNeedsLayout];
}

- (PageAlignment)pageAlignment {
    return _pageAlignment;
}

#pragma mark - Layout

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.frame = self.imageViewFrame;
    });
    [self layoutOnPageVideo];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.frame = self.imageViewFrame;
    });
    [self layoutOnPageVideo];
}

- (CGRect)imageViewFrame {
    if (!self.imageView.image) {
        return self.bounds;
    }
    
    CGRect imgFrame = self.bounds;
    
    
    imgFrame.size = [UIImageView aspectFitSize:self.imageView.image.size insideSize:self.frame.size];
    
//    return imgFrame;
    
    
    CGFloat diffX = (self.frame.size.width - imgFrame.size.width)/2;
    CGFloat diffY = (self.frame.size.height - imgFrame.size.height)/2;
    
    switch (self.pageAlignment) {
        case PageAlignmentNone: {
            imgFrame.origin.x = diffX;
            imgFrame.origin.y = diffY;
            break;
        }
        case PageAlignmentLeft:
            imgFrame.origin.x = 0;
            break;
        case PageAlignmentRight:
            imgFrame.origin.x = diffX * 2;
            break;
        case PageAlignmentBottom:
            imgFrame.origin.y = diffY * 2;
            break;
        case PageAlignmentTop:
            imgFrame.origin.y = 0;
            break;
        default:
            break;
    }
    
    return imgFrame;
}

#pragma mark - Outside management

- (void)reset {
        [self removeOnPageVideo];
        [self.imageView cancelImageRequestOperation];
//    [self.imageView cancelImageDownloadTask];
        self.imageView.image = nil;
        self.pageModel = nil;
        self.pageAlignment = PageAlignmentNone;
}

- (void)toggleVideoForElement:(ElementModel*)element {
    VideoView* video = [self videoViewForElement:element];
    if (video != nil) {
        [video togglePlay];
    }
}

- (VideoView*)videoViewForElement:(ElementModel*)element {
    NSString* ID = element.widgetID;
    if (ID == nil) {
        return nil;
    }
    return [self.videoViews objectForKey:ID];
}

- (ElementModel*)elementForVideoModel:(VideoModel*)video {
    NSString* ID = video.ID;
    for (ElementModel* element in self.pageModel.elementModels) {
        if ([element.widgetID isEqualToString:ID]) {
            return element;
        }
    }
    return nil;
}

#pragma mark - On page video
// @see https://synapsegroup.jira.com/browse/SYN-1772

- (void)removeOnPageVideo {
    // Remove all the player layers from the videoView
    for (VideoView* view in [self.videoViews allValues]) {
        if ([view isPlaying]) {
            [view togglePlay];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
            view.videoModel = nil;
    }
}

- (void)addOnPageVideo {
    NSMutableDictionary* videoViews = [NSMutableDictionary dictionary];
    
    // Add video views and collect them all in a dict keyed by their
    // model's id.
    for (VideoModel* video in self.pageModel.videoModels) {
        if (video.URL == nil) {
            continue;
        }
        
        VideoView* vv = [[VideoView alloc] initWithFrame:CGRectZero];
        vv.delegate = self;
        vv.videoModel = video;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView addSubview:vv];
        });
        [videoViews setObject:vv forKey:video.ID];
    }
    self.videoViews = [NSDictionary dictionaryWithDictionary:videoViews];
}

-(void)layoutOnPageProducts {
    for(ProductGroupModel* product in self.pageModel.elementModelsThatAreProducts){
    }
}
- (void)layoutOnPageVideo {
    // Set all video view's frames.
    for (VideoModel* video in self.pageModel.videoModels) {
        if (video.URL == nil) {
            continue;
        }
        
        VideoView* vv = [self.videoViews objectForKey:video.ID];
        CGRect map = video.pageFrame;
        CGSize sz = [self imageViewFrame].size;
        CGRect frame = CGRectMake(map.origin.x/100 * sz.width, map.origin.y/100 * sz.height, map.size.width/100 * sz.width, map.size.height/100 * sz.height);
        dispatch_async(dispatch_get_main_queue(), ^{
            vv.frame = frame;
        });
        //[self.imageView addSubview:vv];
    }
}

- (void)updateOnPageVideo {
    [self removeOnPageVideo];
    [self addOnPageVideo];
    [self layoutOnPageVideo];
}

- (void)pauseAllVideos {
    for (VideoView* view in [self.videoViews allValues]) {
        if ([view isPlaying]) {
            [view togglePlay];
        }
    }
}

#pragma mark - Modal Only Video Selection

- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    if (selection.selectionType == ItemSelectionTypeVideo && [[self.videoViews allValues] containsObject:container]) {
        VideoModel* video = selection.selection;
        ElementModel* element = [self elementForVideoModel:video];
        if (element && self.delegate && [self.delegate respondsToSelector:@selector(pageView:didSelectElement:)]) {
            [self.delegate pageView:self didSelectElement:element];
        }
    }
}

#pragma mark - User tapping the page

- (void)didTapPage:(UITapGestureRecognizer*)tap {
    CGPoint loc = [tap locationInView:self.imageView];
    // Find which page element the user tapped, if any.
    CGPoint mloc = [self.imageView convertToMappedPoint:loc];
    // Search the page elements to see if the user tapped in a hit area.
    for (ElementModel* element in self.pageModel.elementModels) {
        if ([element.hitAreaPolygon containsPoint:mloc]) {
            if ([self.delegate respondsToSelector:@selector(pageView:didSelectElement:)]) {
                [self.delegate pageView:self didSelectElement:element];
                return;
            } 
        }
    }

}
@end
