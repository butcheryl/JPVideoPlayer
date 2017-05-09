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


#import <UIKit/UIKit.h>
#import "JPVideoPlayerDownloader.h"
#import "JPVideoPlayerCache.h"
#import "JPVideoPlayerOperation.h"
#import "JPVideoPlayerDefine.h"

@class JPVideoPlayerManager;

@protocol JPVideoPlayerManagerDelegate <NSObject>

@optional

/**
 * Controls which video should be downloaded when the video is not found in the cache.
 *
 * @param videoPlayerManager The current `JPVideoPlayerManager`.
 * @param videoURL           The url of the video to be downloaded.
 *
 * @return Return NO to prevent the downloading of the video on cache misses. If not implemented, YES is implied.
 */
- (BOOL)videoPlayerManager:(nonnull JPVideoPlayerManager *)videoPlayerManager shouldDownloadVideoForURL:(nullable NSURL *)videoURL;

/**
 * Controls which video should automatic replay when the video is play completed.
 *
 * @param videoPlayerManager The current `JPVideoPlayerManager`.
 * @param videoURL  the url of the video to be play.
 *
 * @return Return NO to prevent replay for the video. If not implemented, YES is implied.
 */
- (BOOL)videoPlayerManager:(nonnull JPVideoPlayerManager *)videoPlayerManager shouldAutoReplayForURL:(nullable NSURL *)videoURL;

@end

@interface JPVideoPlayerManager : NSObject

@property (weak, nonatomic, nullable) id <JPVideoPlayerManagerDelegate> delegate;

@property (strong, nonatomic, readonly, nullable) JPVideoPlayerCache *videoCache;

@property (strong, nonatomic, readonly, nullable) JPVideoPlayerDownloader *videoDownloader;

#pragma mark - Singleton and initialization

/**
 * Returns global JPVideoPlayerManager instance.
 *
 * @return JPVideoPlayerManager shared instance
 */
+ (nonnull instancetype)sharedManager;

/**
 * Allows to specify instance of cache and video downloader used with video manager.
 * @return new instance of `JPVideoPlayerManager` with specified cache and downloader.
 */
- (nonnull instancetype)initWithCache:(nonnull JPVideoPlayerCache *)cache
                           downloader:(nonnull JPVideoPlayerDownloader *)downloader NS_DESIGNATED_INITIALIZER;

#pragma mark - Video Data Load And Play Video Options

/**
 * Downloads the video for the given URL if not present in cache or return the cached version otherwise.
 
 * @param url            The URL to the video.
 * @param showView       The view of video layer display on.
 * @param options        A mask to specify options to use for this request.
 * @param progressBlock  A block called while image is downloading.
 * @param completedBlock A block called when operation has been completed.
 *
 *   This parameter is required.
 *
 *   This block has no return value and takes the requested video cache path as first parameter.
 *   In case of error the video path parameter is nil and the second parameter may contain an NSError.
 *
 *   The third parameter is an `JPVideoPlayerCacheType` enum indicating if the video was retrieved from the disk cache from the network.
 *
 *   The last parameter is the original image URL.
 *
 * @return Returns an NSObject conforming to JPVideoPlayerOperation. Should be an instance of JPVideoPlayerDownloaderOperation.
 */
- (nullable id <JPVideoPlayerOperation>)loadVideoWithURL:(nonnull NSURL *)url
                                              showOnView:(nullable UIView *)showView
                                                 options:(JPVideoPlayerOptions)options
                                                progress:(nullable JPVideoPlayerDownloaderProgressBlock)progressBlock
                                               completed:(nullable JPVideoPlayerCompletionBlock)completedBlock;

/**
 * Cancels all download operations in the queue.
 */
- (void)cancelAllDownloads;

/**
 * Return the cache key for a given URL.
 */
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;


#pragma mark - Play Control

/**
 * Call this method to stop play video.
 */
- (void)stopPlay;

/**
 * Call this method to play or pause audio of current video.
 *
 * @param mute the audio status will change to.
 */
- (void)setPlayerMute:(BOOL)mute;

/**
 * Call this method to get the audio statu for current player.
 *
 * @return the audio status for current player.
 */
- (BOOL)playerIsMute;

@end
