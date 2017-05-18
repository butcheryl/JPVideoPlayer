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
    
    JPPlaybackStatusBegan,
    JPPlaybackStatusEnded,
    JPPlaybackStatusRemoved,
    
    JPPlaybackStatusPlay,
    JPPlaybackStatusStop,
    JPPlaybackStatusPause,
    JPPlaybackStatusResume,
    
    JPPlaybackStatusPreLoading,
    JPPlaybackStatusBuffer,
    JPPlaybackStatusContinue,
    
    JPPlaybackStatusError
};

// 本地视频/缓存视频 播放成功
// JPPlaybackStatusBegan -> ... JPPlaybackStatusEnded -> ...

// 预加载未完成时, 从屏幕上移除
// JPPlaybackStatusPreLoading -> JPPlaybackStatusRemoved

// 预加载失败
// JPPlaybackStatusPreLoading -> JPPlaybackStatusError

// 预加载成功, 播放时从屏幕移除
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> JPPlaybackStatusRemoved

// 预加载成功，所有缓存播放完，加载失败
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> JPPlaybackStatusBuffer -> JPPlaybackStatusError

// 预加载成功, 播放成功, 不重复播放
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> ... -> JPPlaybackStatusEnded

// 预加载成功, 播放成功，重复播放
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> JPPlaybackStatusEnded -> JPPlaybackStatusBegan -> JPPlaybackStatusEnded -> ...

// 预加载成功, 播放一段，等待加载，继续播放 .. 播放成功
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> JPPlaybackStatusBuffer -> JPPlaybackStatusContinue -> JPPlaybackStatusBuffer -> JPPlaybackStatusContinue -> ...

// 预加载成功，播放第一段，暂停，继续播放
// JPPlaybackStatusPreLoading -> JPPlaybackStatusBegan -> JPPlaybackStatusPause -> JPPlaybackStatusResume -> ...



@protocol JPPlaybackControlsProtocol <NSObject>
@optional

- (BOOL)shouldAutoReplayVideoWithVideoItem:(JPVideoPlayerPlayVideoToolItem *)item;

- (JPVideoPreLoadDuration *)videoPreLoadDurationWith:(JPVideoPlayerPlayVideoToolItem *)item;

- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item preLoadProgress:(CGFloat)progress;

- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item loadProgress:(CGFloat)progress;

- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item statusChange:(JPPlaybackStatus)status;
@end

