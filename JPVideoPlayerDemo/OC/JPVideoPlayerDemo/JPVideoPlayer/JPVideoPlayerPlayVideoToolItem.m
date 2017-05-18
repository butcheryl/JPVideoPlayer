//
//  JPVideoPlayerPlayVideoToolItem.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "JPVideoPlayerPlayVideoToolItem.h"
#import "JPVideoPlayerPlayVideoTool.h"

@interface JPVideoPlayerPlayVideoToolItem()
@property(nonatomic, strong, nullable, readwrite) CALayer *backgroundLayer;
@end

@implementation JPVideoPlayerPlayVideoToolItem

- (nonnull instancetype)initWithURL:(nonnull NSURL *)videoURL assetURL:(nullable NSURL *)assetURL playingKey:(nonnull NSString *)playingKey {
    if (self = [super init]) {
        _url = videoURL;
        
        NSURL *requestURL = assetURL ? : videoURL;
        
        AVURLAsset *videoURLAsset = [AVURLAsset URLAssetWithURL:requestURL options:nil];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoURLAsset];
        
        _currentPlayerItem = playerItem;
        
        _videoURLAsset = videoURLAsset;
        
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        
        _currentPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        
        _playingKey = playingKey;
    }
    
    return self;
}

- (nonnull instancetype)initWithURL:(nonnull NSURL *)videoURL playingKey:(nonnull NSString *)playingKey {
    return [self initWithURL:videoURL assetURL:nil playingKey:playingKey];
}


- (void)stopPlayVideo {
    self.cancelled = YES;

    if ([self.unownShowView respondsToSelector:@selector(videoItem:statusChange:)]) {
        [self.unownShowView videoItem:self statusChange:JPPlaybackStatusRemoved];
    }
    
    [self reset];
}

- (void)pausePlayVideo {
    if ([self.unownShowView respondsToSelector:@selector(videoItem:statusChange:)]) {
        [self.unownShowView videoItem:self statusChange:JPPlaybackStatusPause];
    }
    [self.player pause];
}

- (void)resumePlayVideo {
    if ([self.unownShowView respondsToSelector:@selector(videoItem:statusChange:)]) {
        [self.unownShowView videoItem:self statusChange:JPPlaybackStatusResume];
    }
    [self.player play];
}

- (void)reset {
    // remove video layer from superlayer.
    if (self.backgroundLayer.superlayer) {
        [self.currentPlayerLayer removeFromSuperlayer];
        [self.backgroundLayer removeFromSuperlayer];
    }

    // remove observe.
    JPVideoPlayerPlayVideoTool *tool = [JPVideoPlayerPlayVideoTool sharedTool];
    [_currentPlayerItem removeObserver:tool forKeyPath:@"status"];
    [_currentPlayerItem removeObserver:tool forKeyPath:@"loadedTimeRanges"];

    // remove player
    [self.player pause];
    [self.player cancelPendingPrerolls];
    
    _player = nil;
    [self.videoURLAsset.resourceLoader setDelegate:nil queue:dispatch_get_main_queue()];
    _currentPlayerItem = nil;
    _currentPlayerLayer = nil;
    _videoURLAsset = nil;
    _resourceLoader = nil;
}

-(CALayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer new];
        _backgroundLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _backgroundLayer;
}

@end
