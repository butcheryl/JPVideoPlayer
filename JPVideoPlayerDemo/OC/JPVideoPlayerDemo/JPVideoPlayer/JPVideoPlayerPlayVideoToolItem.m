//
//  JPVideoPlayerPlayVideoToolItem.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "JPVideoPlayerPlayVideoToolItem.h"

@interface JPVideoPlayerPlayVideoToolItem()


@end

#define JPLog(FORMAT, ...); fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


@implementation JPVideoPlayerPlayVideoToolItem

-(void)stopPlayVideo{
    
    self.cancelled = YES;
    
    //    [self.unownShowView hideProgressView];
    //    [self.unownShowView hideActivityIndicatorView];
    
    [self reset];
}

-(void)pausePlayVideo{
    [self.player pause];
}

-(void)resumePlayVideo{
    [self.player play];
}

-(void)reset{
//    // remove video layer from superlayer.
//    if (self.backgroundLayer.superlayer) {
//        [self.currentPlayerLayer removeFromSuperlayer];
//        [self.backgroundLayer removeFromSuperlayer];
//    }
//    
//    // remove observe.
//    JPVideoPlayerPlayVideoTool *tool = [JPVideoPlayerPlayVideoTool sharedTool];
//    [_currentPlayerItem removeObserver:tool forKeyPath:@"status"];
//    [_currentPlayerItem removeObserver:tool forKeyPath:@"loadedTimeRanges"];
//    
//    // remove player
//    [self.player pause];
//    [self.player cancelPendingPrerolls];
//    self.player = nil;
//    [self.videoURLAsset.resourceLoader setDelegate:nil queue:dispatch_get_main_queue()];
//    self.currentPlayerItem = nil;
//    self.currentPlayerLayer = nil;
//    self.videoURLAsset = nil;
    self.resourceLoader = nil;
}

-(CALayer *)backgroundLayer{
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer new];
        _backgroundLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _backgroundLayer;
}

@end
