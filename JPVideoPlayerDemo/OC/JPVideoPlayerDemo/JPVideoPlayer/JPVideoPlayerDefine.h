//
//  JPVideoPlayerDefine.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#ifndef JPVideoPlayerDefine_h
#define JPVideoPlayerDefine_h

#define JPLog(FORMAT, ...); fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

typedef NS_OPTIONS(NSUInteger, JPVideoPlayerOptions) {
    /**
     * In iOS 4+, continue the download of the video if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     */
    JPVideoPlayerContinueInBackground = 1 << 0,
    
    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     */
    JPVideoPlayerHandleCookies = 1 << 1,
    
    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     */
    JPVideoPlayerAllowInvalidSSLCertificates = 1 << 2,
    
    /**
     * Playing video muted.
     */
    JPVideoPlayerMutedPlay = 1 << 5,
    
    /**
     * Stretch to fill layer bounds.
     */
    JPVideoPlayerLayerVideoGravityResize = 1 << 6,
    
    /**
     * Preserve aspect ratio; fit within layer bounds.
     * Default value.
     */
    JPVideoPlayerLayerVideoGravityResizeAspect = 1 << 7,
    
    /**
     * Preserve aspect ratio; fill layer bounds.
     */
    JPVideoPlayerLayerVideoGravityResizeAspectFill = 1 << 8,
};

typedef NS_ENUM(NSInteger, JPVideoPlayerCacheType) {
    
    /**
     * The video wasn't available the JPVideoPlayer caches, but was downloaded from the web.
     */
    JPVideoPlayerCacheTypeNone,
    
    /**
     * The video was obtained from the disk cache.
     */
    JPVideoPlayerCacheTypeDisk,
    
    /**
     * The video was obtained from local file.
     */
    JPVideoPlayerCacheTypeLocation
};

typedef void(^JPVideoPlayerCacheQueryCompletedBlock)(NSString * _Nullable videoPath, JPVideoPlayerCacheType cacheType);

typedef void(^JPVideoPlayerCheckCacheCompletionBlock)(BOOL isInDiskCache);

typedef void(^JPVideoPlayerCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);

typedef void(^JPVideoPlayerNoParamsBlock)();

typedef void(^JPVideoPlayerStoreDataFinishedBlock)(NSUInteger storedSize, NSError * _Nullable error, NSString * _Nullable fullVideoCachePath);

typedef void(^JPVideoPlayerCompletionBlock)(NSString * _Nullable fullVideoCachePath, NSError * _Nullable error, JPVideoPlayerCacheType cacheType, NSURL * _Nullable videoURL);

typedef void(^JPVideoPlayerPlayVideoToolErrorBlock)(NSError * _Nullable error);

#endif /* JPVideoPlayerDefine_h */
