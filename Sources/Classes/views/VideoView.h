//
//  VideoView.h
//  Pods
//
//  Created by Schell Scivally on 1/21/16.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SyndecaSDK/VideoModel.h>
#import <SyndecaSDK/ItemSelectionDelegate.h>

/** A view for displaying on-page video. */
@interface VideoView : UIView {
    VideoModel* _videoModel;
}

@property (readwrite) AVPlayerLayer* videoLayer;


/** A delegate used to proxy video toggle events when a video is modal-only. 
 For details on modal-only video see VideoModel. */
@property (readwrite) id<ItemSelectionDelegate> delegate;
/** The video model. */
@property (readwrite) VideoModel* videoModel;

/** The player associated with this view. */
@property (readonly) AVPlayer* player;

/** Toggles the video between playing or paused. */
- (void)togglePlay;

/** Whether or not the video is currently playing. */
- (BOOL)isPlaying;

@end
