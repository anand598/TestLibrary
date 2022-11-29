//
//  VideoView.m
//  Pods
//
//  Created by Schell Scivally on 1/21/16.
//
//

#import "VideoView.h"
#import "Icons.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FIRTrackProxy.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACExtScope.h>

@interface VideoView ()
@property (readwrite) UIImageView* playIcon;
@property (readwrite) UIImageView* thumbnail;
@property (readwrite) UIActivityIndicatorView* indicatorView;
@property (readwrite) BOOL isObserving;
@end

@implementation VideoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.indicatorView];
        self.indicatorView.alpha = 0;
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(@(50));
        }];
        
        self.playIcon = [[UIImageView alloc] initWithImage:[Icons sharedIcons].playIconImage()];
        [self addSubview:self.playIcon];
        self.playIcon.alpha = 0;
        [self.playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(50));
            make.height.equalTo(@(50));
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoLayer.frame = self.bounds;
    });
    
}

- (void)setVideoModel:(VideoModel *)video {
    
    _videoModel = video;
    if (self.videoLayer) {
        if(self.videoLayer.player != nil && [self.videoLayer.player currentItem] != nil){
            if(self.isObserving == true){
                [self.videoLayer.player removeObserver:self forKeyPath:@"rate"] ;
                self.isObserving = false;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.videoLayer removeFromSuperlayer];
        });
       
        
        [self.videoLayer.player cancelPendingPrerolls];
        self.videoLayer = nil;
    }
    
    if (self.thumbnail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.thumbnail removeFromSuperview];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorView.alpha = 1;
        [self.indicatorView startAnimating];
    });
    
    if (!video || self.videoModel.isModalOnly) {
        // SYN-1889 Add support for modal only video
        // Thumbnails and video should not display when the video is modal-only.
        return;
    }
    
    
    AVPlayer* player = [AVPlayer playerWithURL:video.URL];
    AVPlayerLayer* layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = self.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    self.videoLayer = layer;
    @weakify(self);
    [RACObserve(self, self.videoLayer.player.status) subscribeNext:^(NSNumber* x) {
        @strongify(self);
        AVPlayerStatus status = [x integerValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay: {
                [self prepareToPlay];
                if(self.videoModel.isAutoPlay && !self.isPlaying){
                    [self togglePlay];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self bringSubviewToFront:self.playIcon];
                        self.playIcon.alpha = 1.0;
                    });
                }
                break;
            }
                
            default:
                break;
        }
    }];
    
    
    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:self.thumbnail];
        [self.thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@(0));
            make.width.height.equalTo(self);
        }];
        [self.thumbnail setImageWithURL:video.thumbURL];
        [self addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    });
}

- (void)prepareToPlay {

    [self.videoLayer.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
    self.videoLayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    if(self.videoModel.isLoopEnabled == true){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.videoLayer.player currentItem]];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEndNoLoop:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.videoLayer.player currentItem]];
    }
    
    self.isObserving = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        //        [self addSubview:self.playIcon];
    });
   
}

- (BOOL)isPlaying {
    return self.player.rate > 0;
}

- (void)togglePlay {
    if (self.videoModel.isModalOnly) {
        return;
    }
    
    if (self.player.rate == 0 && self.player.status == AVPlayerStatusReadyToPlay) {
        
        if(self.videoModel.isLoopEnabled == false){
            [self.player seekToTime:kCMTimeZero];
        }
        
        [self.thumbnail removeFromSuperview];
        
        CMTime current = self.player.currentTime;
        CMTime duration = self.player.currentItem.duration;
        if (CMTimeCompare(current, duration) == 0) {
            [self.player seekToTime:CMTimeMake(0, 1)];
        }
        [self.player play];
        
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            self.playIcon.alpha = 0;
        } completion:^(BOOL finished) { }];
    } else {
        [self.player pause];
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            self.playIcon.alpha = 1;
        } completion:^(BOOL finished) { }];
    }
}

- (VideoModel*)videoModel {
    return _videoModel;
}

- (AVPlayer*)player {
    return self.videoLayer.player;
}

#pragma mark - Responding to player start/stop
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.videoLayer.player.rate >= 1) {
        [[FIRTrackProxy sharedProxy] trackStartVideo:self.videoModel];
    } else {
        [[FIRTrackProxy sharedProxy] trackStopVideo:self.videoModel];
    }
}

#pragma mark - Responding to player loop
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)playerItemDidReachEndNoLoop:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
    [self togglePlay];
}
@end
