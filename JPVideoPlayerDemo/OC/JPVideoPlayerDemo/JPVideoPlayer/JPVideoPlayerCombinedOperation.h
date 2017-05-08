//
//  JPVideoPlayerCombinedOperation.h
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/8.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPVideoPlayerDefine.h"
#import "JPVideoPlayerOperation.h"

@interface JPVideoPlayerCombinedOperation : NSObject <JPVideoPlayerOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;

@property (copy, nonatomic, nullable) JPVideoPlayerNoParamsBlock cancelBlock;

@property (strong, nonatomic, nullable) NSOperation *cacheOperation;

@end
