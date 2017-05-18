//
//  JPVideoPreLoadDuration.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/18.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "JPVideoPreLoadDuration.h"

@implementation JPVideoPreLoadDurationTime
@end

@implementation JPVideoPreLoadDurationRatio
@end

@interface JPVideoPreLoadDuration ()
@end

@implementation JPVideoPreLoadDuration

+ (JPVideoPreLoadDuration *(^)(NSTimeInterval t))minute {
    JPVideoPreLoadDurationTime *td = [[JPVideoPreLoadDurationTime alloc] init];
    
    return ^JPVideoPreLoadDuration * (NSTimeInterval t) {
        td.time = t * 60;
        return td;
    };
}

+ (JPVideoPreLoadDuration *(^)(NSTimeInterval t))second {
    
    JPVideoPreLoadDurationTime *td = [[JPVideoPreLoadDurationTime alloc] init];
    
    return ^JPVideoPreLoadDuration * (NSTimeInterval t) {
        td.time = t;
        return td;
    };
}

+ (JPVideoPreLoadDuration *(^)(CGFloat r))ratio {
    JPVideoPreLoadDurationRatio *td = [[JPVideoPreLoadDurationRatio alloc] init];
    
    return ^JPVideoPreLoadDuration * (CGFloat r) {
        td.ratio = r;
        return td;
    };
}

+ (JPVideoPreLoadDuration *)without {
    JPVideoPreLoadDurationTime *td = [[JPVideoPreLoadDurationTime alloc] init];
    td.time = 0;
    return td;
}

+ (JPVideoPreLoadDuration *)defaultTime {
    JPVideoPreLoadDurationRatio *rd = [[JPVideoPreLoadDurationRatio alloc] init];
    rd.ratio = 1.0 / 5.0;
    return rd;
}

@end
