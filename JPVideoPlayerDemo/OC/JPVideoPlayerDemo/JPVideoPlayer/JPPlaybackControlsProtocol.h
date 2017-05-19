//
//  JPPlaybackControlsProtocol.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/18.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JPVideoPreLoadDuration;
@class JPVideoPlayerPlayVideoToolItem;

typedef NS_ENUM(NSUInteger, JPPlaybackStatus) {
    JPPlaybackStatusUnknow,
    JPPlaybackStatusPreLoading,
    JPPlaybackStatusPlaying,
    JPPlaybackStatusLoading,
    JPPlaybackStatusPause,
    JPPlaybackStatusResume,
    JPPlaybackStatusRemoved,
    
    JPPlaybackStatusError
};

// 本地视频/缓存视频 播放成功
// JPPlaybackStatusPlaying -> ...

// 预加载未完成时, 从屏幕上移除
// JPPlaybackStatusPreLoading -> JPPlaybackStatusRemoved

// 预加载失败
// JPPlaybackStatusPreLoading -> JPPlaybackStatusError

// 预加载成功, 播放时从屏幕移除
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> JPPlaybackStatusRemoved

// 预加载成功，所有缓存播放完，加载失败
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> JPPlaybackStatusLoading -> JPPlaybackStatusError

// 预加载成功, 播放成功, 从屏幕上移除
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> ... -> JPPlaybackStatusRemoved

// 预加载成功, 播放成功，重复播放
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> ...

// 预加载成功, 播放一个缓冲段，等待加载，继续播放 .. 播放成功
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> JPPlaybackStatusLoading -> JPPlaybackStatusResume -> ...

// 预加载成功，播放第一个缓冲段，暂停，继续播放
// JPPlaybackStatusPreLoading -> JPPlaybackStatusPlaying -> JPPlaybackStatusPause -> JPPlaybackStatusResume -> ...

@protocol JPPlaybackControlsProtocol <NSObject>
@optional

/**
 播放完成后是否自动重播

 @param item 当前播放项目
 @return 是否自动重播
 */
- (BOOL)shouldAutoReplayVideoWithVideoItem:(JPVideoPlayerPlayVideoToolItem *)item;

/**
 预加载持续时长

 @param item 当前播放项目
 @return 预加载持续时间
 */
- (JPVideoPreLoadDuration *)videoPreLoadDurationWith:(JPVideoPlayerPlayVideoToolItem *)item;

/**
 预加载进度回调

 @param item 当前播放项目
 @param progress 预加载进度
 */
- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item preLoadProgress:(CGFloat)progress;

/**
 总加载进度回调

 @param item 当前播放项目
 @param progress 总加载进度
 */
- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item loadProgress:(CGFloat)progress;

/**
 播放状态切换

 @param item 当前播放项目
 @param status 播放状态
 */
- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item statusChange:(JPPlaybackStatus)status;
@end

