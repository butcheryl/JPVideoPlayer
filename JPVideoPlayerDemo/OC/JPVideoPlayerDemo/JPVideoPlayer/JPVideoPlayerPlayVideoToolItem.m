//
//  JPVideoPlayerPlayVideoToolItem.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "JPVideoPlayerPlayVideoToolItem.h"
#import "JPVideoPlayerPlayVideoTool.h"
#import "JPVideoPlayerCompat.h"

@interface JPVideoPlayerPlayVideoToolItem()
@property(nonatomic, strong, nullable, readwrite) CALayer *backgroundLayer;
@end

@implementation JPVideoPlayerPlayVideoToolItem

- (nonnull instancetype)initWithURL:(nonnull NSURL *)videoURL assetURL:(nullable NSURL *)assetURL playingKey:(nonnull NSString *)playingKey {
    if (self = [super init]) {
        _url = videoURL;
        
        NSURL *requestURL = assetURL ? : videoURL;
        
        AVURLAsset *videoURLAsset = [AVURLAsset URLAssetWithURL:requestURL options:nil];
        
        if (assetURL) {
            _resourceLoader = [[JPVideoPlayerResourceLoader alloc] init];
            
            [videoURLAsset.resourceLoader setDelegate:_resourceLoader queue:dispatch_get_main_queue()];
        }
        
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

    self.status = JPPlaybackStatusRemoved;
    
    [self reset];
}

- (void)pausePlayVideo {
    self.status = JPPlaybackStatusPause;
    
    [self.player pause];
}

- (void)resumePlayVideo {
    self.status = JPPlaybackStatusResume;
    
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

- (void)setStatus:(JPPlaybackStatus)status {
    
    if (status != _status) {
        if ([self.unownShowView respondsToSelector:@selector(videoItem:statusChange:)]) {
            dispatch_main_async_safe(^{
                [self.unownShowView videoItem:self statusChange:status];
            });
        }
    }
    
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}

@end
