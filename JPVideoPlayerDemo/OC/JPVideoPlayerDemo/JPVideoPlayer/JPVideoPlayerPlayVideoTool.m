/*
 * This file is part of the JPVideoPlayer package.
 * (c) NewPan <13246884282@163.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Click https://github.com/Chris-Pan
 * or http://www.jianshu.com/users/e2f2d779c022/latest_articles to contact me.
 */

#import "JPVideoPlayerPlayVideoTool.h"
#import "JPVideoPlayerPlayVideoToolItem.h"
#import "JPVideoPlayerCompat.h"
#import "JPVideoPlayerResourceLoader.h"
#import "JPVideoPlayerDownloaderOperation.h"
#import "JPVideoPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "JPVideoPreLoadDuration.h"

static NSString *JPVideoPlayerURLScheme = @"SystemCannotRecognition";

static NSString *JPVideoPlayerURL = @"www.newpan.com";

@interface JPVideoPlayerPlayVideoTool()

@property(nonatomic, strong, nonnull) NSMutableArray<JPVideoPlayerPlayVideoToolItem *> *playVideoItems;

@end

@implementation JPVideoPlayerPlayVideoTool

- (instancetype)init{
    if (self = [super init]) {
        [self addObserverOnce];
        _playVideoItems = [NSMutableArray array];
    }
    return self;
}

+ (nonnull instancetype)sharedTool{
    static dispatch_once_t onceItem;
    static id instance;
    dispatch_once(&onceItem, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark -----------------------------------------
#pragma mark Public

- (nullable JPVideoPlayerPlayVideoToolItem *)playExistedVideoWithURL:(NSURL * _Nullable)url
                                                  fullVideoCachePath:(NSString * _Nullable)fullVideoCachePath
                                                             options:(JPVideoPlayerOptions)options
                                                          showOnView:(UIView<JPPlaybackControlsProtocol> * _Nullable)showView
                                                               error:(nullable JPVideoPlayerPlayVideoToolErrorBlock)error {
    
    if (!fullVideoCachePath || fullVideoCachePath.length == 0) {
        if (error) error([NSError errorWithDomain:@"the file path is disable" code:0 userInfo:nil]);
        return nil;
    }
    
    if (!showView) {
        if (error) error([NSError errorWithDomain:@"the layer to display video layer is nil" code:0 userInfo:nil]);
        return nil;
    }
    
    NSString *playingKey = [[JPVideoPlayerManager sharedManager] cacheKeyForURL:url];
    
    JPVideoPlayerPlayVideoToolItem *item = [[JPVideoPlayerPlayVideoToolItem alloc] initWithURL:url playingKey:playingKey];
    
    item.unownShowView = showView;
    
    item.backgroundLayer.frame = CGRectMake(0, 0, showView.bounds.size.width, showView.bounds.size.height);
    
    item.currentPlayerLayer.frame = item.backgroundLayer.bounds;
    
    item.error = error;
    
    [item.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    
    NSString *videoGravity = AVLayerVideoGravityResizeAspect;
    if (options & JPVideoPlayerLayerVideoGravityResizeAspect) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    } else if (options & JPVideoPlayerLayerVideoGravityResize){
        videoGravity = AVLayerVideoGravityResize;
    } else if (options & JPVideoPlayerLayerVideoGravityResizeAspectFill){
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    item.currentPlayerLayer.videoGravity = videoGravity;
    
    if (options & JPVideoPlayerMutedPlay) {
        item.player.muted = YES;
    }
    
    @synchronized (self) {
        [self.playVideoItems addObject:item];
    }
    
    self.currentPlayVideoItem = item;
    
    return item;
}

- (nullable JPVideoPlayerPlayVideoToolItem *)playVideoWithURL:(NSURL * _Nullable)url
                                          tempVideoCachePath:(NSString * _Nullable)tempVideoCachePath
                                                     options:(JPVideoPlayerOptions)options
                                         videoFileExceptSize:(NSUInteger)exceptSize
                                       videoFileReceivedSize:(NSUInteger)receivedSize
                                                  showOnView:(UIView<JPPlaybackControlsProtocol> * _Nullable)showView
                                                       error:(nullable JPVideoPlayerPlayVideoToolErrorBlock)error {
    
    if (tempVideoCachePath.length == 0) {
        if (error) error([NSError errorWithDomain:@"the file path is disable" code:0 userInfo:nil]);
        return nil;
    }
    
    if (!showView) {
        if (error) error([NSError errorWithDomain:@"the layer to display video layer is nil" code:0 userInfo:nil]);
        return nil;
    }
    
    NSString *playingKey = [[JPVideoPlayerManager sharedManager]cacheKeyForURL:url];
    
    JPVideoPlayerPlayVideoToolItem *item = [[JPVideoPlayerPlayVideoToolItem alloc] initWithURL:url
                                                                                      assetURL:self.handleVideoURL
                                                                                    playingKey:playingKey];
    
    item.unownShowView = showView;
    
    [item.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [item.currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    NSString *videoGravity = AVLayerVideoGravityResizeAspect;
    
    if (options & JPVideoPlayerLayerVideoGravityResizeAspect) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    } else if (options & JPVideoPlayerLayerVideoGravityResize) {
        videoGravity = AVLayerVideoGravityResize;
    } else if (options & JPVideoPlayerLayerVideoGravityResizeAspectFill) {
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    item.currentPlayerLayer.videoGravity = videoGravity;
    
    item.backgroundLayer.frame = CGRectMake(0, 0, showView.bounds.size.width, showView.bounds.size.height);
    
    item.currentPlayerLayer.frame = item.backgroundLayer.bounds;
    
    item.error = error;
    
    item.playerOptions = options;
    
    item.playingKey = [[JPVideoPlayerManager sharedManager]cacheKeyForURL:url];
    
    self.currentPlayVideoItem = item;
    
    if (options & JPVideoPlayerMutedPlay) {
        item.player.muted = YES;
    }
    
    @synchronized (self) {
        [self.playVideoItems addObject:item];
    }
    
    self.currentPlayVideoItem = item;
    
    [self didReceivedDataCacheInDiskByTempPath:tempVideoCachePath videoFileExceptSize:exceptSize videoFileReceivedSize:receivedSize];

    return item;
}

- (void)didReceivedDataCacheInDiskByTempPath:(NSString * _Nonnull)tempCacheVideoPath
                        videoFileExceptSize:(NSUInteger)expectedSize
                      videoFileReceivedSize:(NSUInteger)receivedSize {
    [self.currentPlayVideoItem.resourceLoader didReceivedDataCacheInDiskByTempPath:tempCacheVideoPath
                                                               videoFileExceptSize:expectedSize
                                                             videoFileReceivedSize:receivedSize];
}

- (void)didCachedVideoDataFinishedFromWebFullVideoCachePath:(NSString * _Nullable)fullVideoCachePath{
    if (self.currentPlayVideoItem.resourceLoader) {
        [self.currentPlayVideoItem.resourceLoader didCachedVideoDataFinishedFromWebFullVideoCachePath:fullVideoCachePath];
    }
}

- (void)setMute:(BOOL)mute {
    self.currentPlayVideoItem.player.muted = mute;
}

- (void)stopPlay {
    self.currentPlayVideoItem = nil;
    
    for (JPVideoPlayerPlayVideoToolItem *item in self.playVideoItems) {
        [item stopPlayVideo];
    }
    
    @synchronized (self) {
        if (self.playVideoItems) {
            [self.playVideoItems removeAllObjects];
        }
    }
}


#pragma mark -----------------------------------------
#pragma mark App Observer

- (void)addObserverOnce{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReceivedMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)appReceivedMemoryWarning{
    [self.currentPlayVideoItem stopPlayVideo];
}

- (void)appDidEnterBackground{
    [self.currentPlayVideoItem pausePlayVideo];
}

- (void)appDidEnterPlayGround{
    [self.currentPlayVideoItem resumePlayVideo];
}

- (CGFloat)preLoadDuration:(CGFloat)totalDuration {
    
    CGFloat time = 0;
    
    if ([self.currentPlayVideoItem.unownShowView respondsToSelector:@selector(videoPreLoadDurationWith:)]) {
        
        JPVideoPreLoadDuration *d = [self.currentPlayVideoItem.unownShowView videoPreLoadDurationWith:_currentPlayVideoItem];
        
        if ([d isKindOfClass:[JPVideoPreLoadDurationTime class]]) {
            time = MIN([(JPVideoPreLoadDurationTime *)d time], totalDuration);
        } else if ([d isKindOfClass:[JPVideoPreLoadDurationRatio class]]) {
            time = [(JPVideoPreLoadDurationRatio *)d ratio] * totalDuration;
        }
    }
    
    return time;
}

#pragma mark -----------------------------------------
#pragma mark AVPlayer Observer

- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    
    // ask need automatic replay or not.
    
    if ([self.currentPlayVideoItem.unownShowView respondsToSelector:@selector(shouldAutoReplayVideoWithVideoItem:)] &&
        [self.currentPlayVideoItem.unownShowView shouldAutoReplayVideoWithVideoItem:_currentPlayVideoItem]) {
        
        // Seek the start point of file data and repeat play, this handle have no memory surge.
        
        __weak JPVideoPlayerPlayVideoToolItem *weakItem = self.currentPlayVideoItem;
        
        [self.currentPlayVideoItem.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
            __strong JPVideoPlayerPlayVideoToolItem *strongItem = weakItem;
            
            if (!strongItem) return;
            
            self.currentPlayVideoItem.lastTime = 0;
            
            [strongItem.player play];
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        AVPlayerItemStatus status = playerItem.status;
        
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:{
                // When get ready to play note, we can go to play, and can add the video picture on show view.
                if (!self.currentPlayVideoItem) return;
                
                if (self.currentPlayVideoItem.isCancelled) return ;
                
                CGFloat duration = CMTimeGetSeconds(playerItem.duration);
                
                CGFloat preLoadDuration = [self preLoadDuration:duration];
                
                [self.currentPlayVideoItem.backgroundLayer addSublayer:self.currentPlayVideoItem.currentPlayerLayer];
                
                [self.currentPlayVideoItem.unownShowView.layer addSublayer:self.currentPlayVideoItem.backgroundLayer];
                
                if (preLoadDuration > 0) {
                    self.currentPlayVideoItem.status = JPPlaybackStatusPreLoading;
                } else {
                    [self.currentPlayVideoItem.player play];
                    
                    self.currentPlayVideoItem.status = JPPlaybackStatusPlaying;
                }
            }
                break;
            case AVPlayerItemStatusFailed:{
                if (self.currentPlayVideoItem.error) {
                    self.currentPlayVideoItem.error([NSError errorWithDomain:@"Some errors happen on player" code:0 userInfo:nil]);
                }
                
                self.currentPlayVideoItem.status = JPPlaybackStatusError;
            }
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray *array = self.currentPlayVideoItem.currentPlayerItem.loadedTimeRanges;
        
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲时间范围
        
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        
        CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        NSTimeInterval totalBuffer = startSeconds + durationSeconds; //缓冲总长度
        
        CGFloat preDuration = [self preLoadDuration:CMTimeGetSeconds(self.currentPlayVideoItem.currentPlayerItem.duration)];
        
        
        if (preDuration > 0) {
            if (totalBuffer < preDuration) {
                // 预加载过程中
                if (self.currentPlayVideoItem.status != JPPlaybackStatusPreLoading) {
                    self.currentPlayVideoItem.status = JPPlaybackStatusPreLoading;
                }
                
                if ([self.currentPlayVideoItem.unownShowView respondsToSelector:@selector(videoItem:preLoadProgress:)]) {
                    [self.currentPlayVideoItem.unownShowView videoItem:_currentPlayVideoItem preLoadProgress:MIN(totalBuffer / preDuration, 1)];
                }
                
            } else if (self.currentPlayVideoItem.status == JPPlaybackStatusPreLoading) {
                
                if ([self.currentPlayVideoItem.unownShowView respondsToSelector:@selector(videoItem:preLoadProgress:)]) {
                    [self.currentPlayVideoItem.unownShowView videoItem:_currentPlayVideoItem preLoadProgress:1.0];
                }
                
                [self.currentPlayVideoItem.player play];
                
                self.currentPlayVideoItem.status = JPPlaybackStatusPlaying;
            }
        }
        
        if (self.currentPlayVideoItem.status != JPPlaybackStatusPreLoading) {
            
            NSTimeInterval currentTime = CMTimeGetSeconds(self.currentPlayVideoItem.player.currentTime);
            
            if (currentTime != 0 && currentTime > self.currentPlayVideoItem.lastTime) {
                self.currentPlayVideoItem.lastTime = currentTime;
                self.currentPlayVideoItem.status = JPPlaybackStatusResume;
            } else {
                self.currentPlayVideoItem.status = JPPlaybackStatusLoading;
            }
        }
    }
}


#pragma mark -----------------------------------------
#pragma mark Private
- (void)setCurrentPlayVideoItem:(JPVideoPlayerPlayVideoToolItem *)currentPlayVideoItem {
    [self willChangeValueForKey:@"currentPlayVideoItem"];
    _currentPlayVideoItem = currentPlayVideoItem;
    [self didChangeValueForKey:@"currentPlayVideoItem"];
}

- (NSURL *)handleVideoURL{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:JPVideoPlayerURL] resolvingAgainstBaseURL:NO];
    components.scheme = JPVideoPlayerURLScheme;
    return [components URL];
}

@end
