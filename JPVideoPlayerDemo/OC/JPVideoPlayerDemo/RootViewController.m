//
//  RootViewController.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/11.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "RootViewController.h"
#import "JPVideoPlayerManager.h"

@interface RootViewController ()
@property (nonatomic, strong) UIImageView *playerView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerView = [[UIImageView alloc] init];
    self.playerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.playerView];
    
    NSURL *videoURL = [NSURL URLWithString:@"http://lavaweb-10015286.video.myqcloud.com/%E5%B0%BD%E6%83%85LAVA.mp4"];

    [[JPVideoPlayerManager sharedManager] loadVideoWithURL:videoURL
                                                showOnView:_playerView
                                                   options:JPVideoPlayerContinueInBackground
                                                  progress:^(NSData * _Nullable data, NSInteger receivedSize, NSInteger expectedSize, NSString * _Nullable tempCachedVideoPath, NSURL * _Nullable targetURL) {
                                                      NSLog(@"%@", @(receivedSize).stringValue);
                                                      NSLog(@"%@", @(expectedSize).stringValue);
                                                      NSLog(@"%@", tempCachedVideoPath);
                                                      NSLog(@"%@", targetURL.absoluteString);
                                                  } completed:^(NSString * _Nullable fullVideoCachePath, NSError * _Nullable error, JPVideoPlayerCacheType cacheType, NSURL * _Nullable videoURL) {
                                                      NSLog(@"%@", error);
                                                      NSLog(@"%@", fullVideoCachePath);
                                                  }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    
    self.playerView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
