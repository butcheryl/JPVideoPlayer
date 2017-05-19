//
//  JPVideoPlayerPlayVideoToolItem.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JPVideoPlayerResourceLoader.h"
#import "JPVideoPlayerDefine.h"
#import "JPPlaybackControlsProtocol.h"

@interface JPVideoPlayerPlayVideoToolItem : NSObject

@property (nonatomic, assign) JPPlaybackStatus status;

/**
 * The playing URL
 */
@property(nonatomic, strong, nullable, readonly) NSURL *url;

/**
 * The Player to play video.
 */
@property(nonatomic, strong, nullable, readonly) AVPlayer *player;

/**
 * The current player's layer.
 */
@property(nonatomic, strong, nullable, readonly) AVPlayerLayer *currentPlayerLayer;

/**
 * The background layer for video layer.
 */
@property(nonatomic, strong, nullable, readonly) CALayer *backgroundLayer;

/**
 * The current player's item.
 */
@property(nonatomic, strong, nullable, readonly) AVPlayerItem *currentPlayerItem;

/**
 * The current player's urlAsset.
 */
@property(nonatomic, strong, nullable, readonly) AVURLAsset *videoURLAsset;

/**
 * The view of the video picture will show on.
 */
@property(nonatomic, weak, nullable) UIView<JPPlaybackControlsProtocol> *unownShowView;

/**
 * A flag to book is cancel play or not.
 */
@property(nonatomic, assign, getter=isCancelled) BOOL cancelled;

/**
 * Error message.
 */
@property(nonatomic, strong, nullable) JPVideoPlayerPlayVideoToolErrorBlock error;

/**
 * The resourceLoader for the videoPlayer.
 */
@property(nonatomic, strong, nullable) JPVideoPlayerResourceLoader *resourceLoader;

/**
 * options
 */
@property(nonatomic, assign) JPVideoPlayerOptions playerOptions;

/**
 * The current playing url key.
 */
@property(nonatomic, strong, nonnull) NSString *playingKey;

/**
 * The last play time for player.
 */
@property(nonatomic, assign) NSTimeInterval lastTime;


- (nonnull instancetype)initWithURL:(nonnull NSURL *)videoURL playingKey:(nonnull NSString *)playingKey;

- (nonnull instancetype)initWithURL:(nonnull NSURL *)videoURL assetURL:(nullable NSURL *)assetURL playingKey:(nonnull NSString *)playingKey;

- (void)stopPlayVideo;
- (void)pausePlayVideo;
- (void)resumePlayVideo;
@end
