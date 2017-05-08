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

#import "JPVideoPlayerCachePathTool.h"
#include <sys/param.h>
#import <CommonCrypto/CommonDigest.h>

NSString * const JPVideoPlayerCacheVideoPathForTemporaryFile = @"/TemporaryFile";
NSString * const JPVideoPlayerCacheVideoPathForFullFile = @"/FullFile";

@implementation JPVideoPlayerCachePathTool

#pragma mark -----------------------------------------
#pragma mark Public

+ (nonnull NSString *)videoCachePathForAllTemporaryFile {
    return [self getFilePathWithAppendingString:JPVideoPlayerCacheVideoPathForTemporaryFile];
}

+ (nonnull NSString *)videoCachePathForAllFullFile {
    return [self getFilePathWithAppendingString:JPVideoPlayerCacheVideoPathForFullFile];
}

+ (nonnull NSString *)videoCacheTemporaryPathForKey:(NSString * _Nonnull)key {
    NSString *path = [self videoCachePathForAllTemporaryFile];
    
    if (path.length != 0) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        path = [path stringByAppendingPathComponent:[self cacheFileNameForKey:key]];
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createFileAtPath:path contents:nil attributes:nil];
        }
    }
    
    return path;
}

+ (nonnull NSString *)videoCacheFullPathForKey:(NSString * _Nonnull)key{
    NSString *path = [self videoCachePathForAllFullFile];
    path = [path stringByAppendingPathComponent:[self cacheFileNameForKey:key]];
    return path;
}

+ (nullable NSString *)cacheFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) str = "";
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2],
                          r[3], r[4], r[5],
                          r[6], r[7], r[8],
                          r[9], r[10], r[11],
                          r[12], r[13], r[14],
                          r[15], [key.pathExtension isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension]];
    return filename;
}

#pragma mark -----------------------------------------
#pragma mark Private

+ (nonnull NSString *)getFilePathWithAppendingString:(nonnull NSString *)apdStr {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:apdStr];
    
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

@end
