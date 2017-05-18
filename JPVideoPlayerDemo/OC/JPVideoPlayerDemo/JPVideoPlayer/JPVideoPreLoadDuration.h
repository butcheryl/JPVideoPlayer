//
//  JPVideoPreLoadDuration.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/18.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPVideoPreLoadDuration : NSObject

+ (JPVideoPreLoadDuration *(^)(NSTimeInterval t))second;

+ (JPVideoPreLoadDuration *(^)(NSTimeInterval t))minute;

// 0.0 ~ 1.0
+ (JPVideoPreLoadDuration *(^)(CGFloat r))ratio;

/**
 don’t allow the preload

 @return preload time
 */
+ (JPVideoPreLoadDuration *)without;

/**
 default preloading time is a 1/5 video total time

 @return preload time
 */
+ (JPVideoPreLoadDuration *)defaultTime;
@end

@interface JPVideoPreLoadDurationTime: JPVideoPreLoadDuration
@property (nonatomic, assign) CGFloat time;
@end

@interface JPVideoPreLoadDurationRatio: JPVideoPreLoadDuration
@property (nonatomic, assign) CGFloat ratio;
@end


