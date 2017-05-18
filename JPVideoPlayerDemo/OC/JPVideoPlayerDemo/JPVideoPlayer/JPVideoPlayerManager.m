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


#import "JPVideoPlayerManager.h"
#import "JPVideoPlayerCompat.h"
#import "JPVideoPlayerCachePathTool.h"
#import "JPVideoPlayerDownloaderOperation.h"
#import "JPVideoPlayerPlayVideoTool.h"
#import "JPVideoPlayerPlayVideoToolItem.h"
#import "JPVideoPlayerCombinedOperation.h"

@interface JPVideoPlayerManager()

@property (strong, nonatomic, readwrite, nonnull) JPVideoPlayerCache *videoCache;

@property (strong, nonatomic, readwrite, nonnull) JPVideoPlayerDownloader *videoDownloader;

@property (strong, nonatomic, nonnull) NSMutableArray<JPVideoPlayerCombinedOperation *> *runningOperations;

@property(nonatomic, getter=isMuted) BOOL mute;

@end

@implementation JPVideoPlayerManager

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (nonnull instancetype)init {
    JPVideoPlayerCache *cache = [JPVideoPlayerCache sharedCache];
    JPVideoPlayerDownloader *downloader = [JPVideoPlayerDownloader sharedDownloader];
    return [self initWithCache:cache downloader:downloader];
}

- (nonnull instancetype)initWithCache:(nonnull JPVideoPlayerCache *)cache downloader:(nonnull JPVideoPlayerDownloader *)downloader {
    if ((self = [super init])) {
        _videoCache = cache;
        _videoDownloader = downloader;
        _runningOperations = [NSMutableArray array];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startDownloadVideo:) name:JPVideoPlayerDownloadStartNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -----------------------------------------
#pragma mark Public

- (nullable id <JPVideoPlayerOperation>)loadVideoWithURL:(nonnull NSURL *)url
                                              showOnView:(nullable UIView<JPPlaybackControlsProtocol> *)showView
                                                 options:(JPVideoPlayerOptions)options
                                                progress:(nullable JPVideoPlayerDownloaderProgressBlock)progressBlock
                                               completed:(nullable JPVideoPlayerCompletionBlock)completedBlock {
    
    if (!url || url.absoluteString.length == 0) {
        [self callCompletionBlockForOperation:nil
                                   completion:completedBlock
                                    videoPath:nil
                                        error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]
                                    cacheType:JPVideoPlayerCacheTypeNone
                                          url:url];
        return nil;
    }
    
    // local video
    if (url.isFileURL) {
        return [self loadLocalVideoWithURL:url showOnView:showView options:options progress:progressBlock completed:completedBlock];
    }
    
    NSString *key = [self cacheKeyForURL:url];
    
    __block JPVideoPlayerCombinedOperation *operation = [[JPVideoPlayerCombinedOperation alloc] init];
    
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    
    __weak typeof(self) weakSelf = self;
    
    operation.cacheOperation =
    
    [self.videoCache queryCacheOperationForKey:key done:^(NSString * _Nullable videoPath, JPVideoPlayerCacheType cacheType) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        
        if (operation.isCancelled) {
            return [strongSelf safelyRemoveOperationFromRunning:operation];
        }
        
        if (cacheType == JPVideoPlayerCacheTypeDisk && videoPath != nil) {
            [[JPVideoPlayerPlayVideoTool sharedTool] playExistedVideoWithURL:url fullVideoCachePath:videoPath options:options showOnView:showView error:^(NSError * _Nullable error) {
                dispatch_main_async_safe(^{
                    if (operation && !operation.isCancelled && completedBlock) {
                        completedBlock(videoPath, error, JPVideoPlayerCacheTypeDisk, url);
                    }
                });
            }];
            
            return [strongSelf safelyRemoveOperationFromRunning:operation];
        }
        
        // cache token.
        __block JPVideoPlayerCacheToken *cacheToken = nil;
        
        // download if no cache, and download allowed by delegate.
        JPVideoPlayerDownloaderOptions downloaderOptions = 0;
        
        if (options & JPVideoPlayerContinueInBackground)
            downloaderOptions |= JPVideoPlayerDownloaderContinueInBackground;
        
        if (options & JPVideoPlayerHandleCookies)
            downloaderOptions |= JPVideoPlayerDownloaderHandleCookies;
        
        if (options & JPVideoPlayerAllowInvalidSSLCertificates)
            downloaderOptions |= JPVideoPlayerDownloaderAllowInvalidSSLCertificates;
            
        // Save received data to disk.
        JPVideoPlayerDownloaderProgressBlock handleProgressBlock = ^(NSData * _Nullable data, NSInteger receivedSize, NSInteger expectedSize, NSString *_Nullable tempVideoCachedPath, NSURL * _Nullable targetURL){
            
            cacheToken = [strongSelf.videoCache storeVideoData:data expectedSize:expectedSize forKey:key completion:^(NSUInteger storedSize, NSError * _Nullable error, NSString * _Nullable fullVideoCachePath) {
                if (!error) {
                    if (!fullVideoCachePath) {
                        if (progressBlock) {
                            progressBlock(data, storedSize, expectedSize, tempVideoCachedPath, targetURL);
                        }
                        
                        if (![JPVideoPlayerPlayVideoTool sharedTool].currentPlayVideoItem) {
                            [[JPVideoPlayerPlayVideoTool sharedTool] playVideoWithURL:targetURL tempVideoCachePath:tempVideoCachedPath options:options videoFileExceptSize:expectedSize videoFileReceivedSize:receivedSize showOnView:showView error:^(NSError * _Nullable error) {
                                if (error) {
                                    if (completedBlock) {
                                        [strongSelf callCompletionBlockForOperation:operation completion:completedBlock videoPath:videoPath error:error cacheType:JPVideoPlayerCacheTypeNone url:targetURL];
                                        [strongSelf safelyRemoveOperationFromRunning:operation];
                                    }
                                }
                            }];
                        } else {
                            NSString *key = [[JPVideoPlayerManager sharedManager] cacheKeyForURL:targetURL];
                            if ([JPVideoPlayerPlayVideoTool sharedTool].currentPlayVideoItem && [key isEqualToString:[JPVideoPlayerPlayVideoTool sharedTool].currentPlayVideoItem.playingKey]) {
                                [[JPVideoPlayerPlayVideoTool sharedTool] didReceivedDataCacheInDiskByTempPath:tempVideoCachedPath videoFileExceptSize:expectedSize videoFileReceivedSize:receivedSize];
                            }
                        }
                    } else {
                        // cache finished, and move the full video file from temporary path to full path.
                        [[JPVideoPlayerPlayVideoTool sharedTool] didCachedVideoDataFinishedFromWebFullVideoCachePath:fullVideoCachePath];
                        [self callCompletionBlockForOperation:operation completion:completedBlock videoPath:fullVideoCachePath error:nil cacheType:JPVideoPlayerCacheTypeNone url:url];
                        [self safelyRemoveOperationFromRunning:operation];
                    }
                }
                else {
                    // some error happens.
                    [self callCompletionBlockForOperation:operation completion:completedBlock videoPath:nil error:error cacheType:JPVideoPlayerCacheTypeNone url:url];
                    
                    [self safelyRemoveOperationFromRunning:operation];
                }
            }];
        };
            
        // delete all temporary first, then download video from web.
        [strongSelf.videoCache deleteAllTempCacheOnCompletion:^{
            
            __weak typeof(strongSelf) _weakSelf = strongSelf;
            
            JPVideoPlayerDownloadToken *subOperationToken =
            
            [strongSelf.videoDownloader downloadVideoWithURL:url options:downloaderOptions progress:handleProgressBlock completed:^(NSError * _Nullable error) {
                __strong typeof(_weakSelf) _strongSelf = _weakSelf;
                
                [_strongSelf callCompletionBlockForOperation:operation completion:completedBlock videoPath:nil error:error cacheType:JPVideoPlayerCacheTypeNone url:url];
               
                [_strongSelf safelyRemoveOperationFromRunning:operation];
            }];
            
            __weak typeof(operation) weakOperation = operation;
            
            operation.cancelBlock = ^{
                __strong typeof(weakOperation) strongOperation = weakOperation;
                
                if (!strongOperation) {
                    return;
                }
                
                [strongSelf.videoCache cancel:cacheToken];
                
                [strongSelf.videoDownloader cancel:subOperationToken];
                
                [strongSelf safelyRemoveOperationFromRunning:strongOperation];
                
                [[JPVideoPlayerManager sharedManager] stopPlay];
            };
        }];
    }];
    
    return operation;
}

- (nullable id<JPVideoPlayerOperation>)loadLocalVideoWithURL:(nullable NSURL *)url
                                                  showOnView:(nullable UIView<JPPlaybackControlsProtocol> *)showView
                                                     options:(JPVideoPlayerOptions)options
                                                    progress:(nullable JPVideoPlayerDownloaderProgressBlock)progressBlock
                                                   completed:(nullable JPVideoPlayerCompletionBlock)completedBlock {
    
    NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[JPVideoPlayerPlayVideoTool sharedTool] playExistedVideoWithURL:url
                                                      fullVideoCachePath:path
                                                                 options:options
                                                              showOnView:showView
                                                                   error:^(NSError * _Nullable error) {
            dispatch_main_async_safe(^{
                if (completedBlock) {
                    completedBlock(nil, error, JPVideoPlayerCacheTypeLocation, url);
                }
            });
        }];
    } else {
        dispatch_main_async_safe(^{
            if (completedBlock) {
                completedBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil], JPVideoPlayerCacheTypeLocation, url);
            }
        });
    }
    
    return nil;
}



- (void)cancelAllDownloads{
    [self.videoDownloader cancelAllDownloads];
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    return [_videoCache cacheKeyForURL:url];
}

- (void)stopPlay{
    dispatch_main_async_safe(^{
        [[JPVideoPlayerPlayVideoTool sharedTool] stopPlay];
    });
}

- (void)setPlayerMute:(BOOL)mute{
    if ([JPVideoPlayerPlayVideoTool sharedTool].currentPlayVideoItem) {
        [[JPVideoPlayerPlayVideoTool sharedTool] setMute:mute];
    }
    self.mute = mute;
}

- (BOOL)playerIsMute{
    return self.mute;
}

#pragma mark -----------------------------------------
#pragma mark Private

- (void)safelyRemoveOperationFromRunning:(nullable JPVideoPlayerCombinedOperation *)operation {
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObject:operation];
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable JPVideoPlayerCombinedOperation *)operation
                             completion:(nullable JPVideoPlayerCompletionBlock)completionBlock
                              videoPath:(nullable NSString *)videoPath
                                  error:(nullable NSError *)error
                              cacheType:(JPVideoPlayerCacheType)cacheType
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (operation && !operation.isCancelled && completionBlock) {
            completionBlock(videoPath, error, cacheType, url);
        }
    });
}

- (void)diskVideoExistsForURL:(nullable NSURL *)url completion:(nullable JPVideoPlayerCheckCacheCompletionBlock)completionBlock {
    
    NSString *key = [self cacheKeyForURL:url];
    
    [self.videoCache diskVideoExistsWithKey:key completion:^(BOOL isInDiskCache) {
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

@end
