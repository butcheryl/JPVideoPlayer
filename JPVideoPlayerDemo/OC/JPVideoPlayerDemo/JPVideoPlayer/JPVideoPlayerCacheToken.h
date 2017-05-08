//
//  JPVideoPlayerCacheToken.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPVideoPlayerCacheToken : NSObject
/**
 * outputStream.
 */
@property(nonnull, nonatomic, strong) NSOutputStream *outputStream;

/**
 * Received video size.
 */
@property(nonatomic, assign) NSUInteger receivedVideoSize;

/**
 * key.
 */
@property(nonnull, nonatomic, strong) NSString *key;
@end
