//
//  RootViewController.m
//  JPVideoPlayerDemo
//
//  Created by butcheryl on 2017/5/11.
//  Copyright © 2017年 NewPan. All rights reserved.
//

#import "RootViewController.h"
#import "JPVideoPlayerManager.h"
#import "JPVideoPreLoadDuration.h"


@interface BYPlayerView : UIImageView <JPPlaybackControlsProtocol>
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIButton *retryButton;
@end

@implementation BYPlayerView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityIndicatorView stopAnimating];
        [self addSubview:self.activityIndicatorView];
        
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.retryButton.hidden = YES;
        self.retryButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.retryButton setTitle:@"重试" forState:UIControlStateNormal];
        [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.retryButton sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
    
    self.blurEffectView.frame = self.bounds;
}

- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item statusChange:(JPPlaybackStatus)status {
    if (status == JPPlaybackStatusError) {
        [self.activityIndicatorView stopAnimating];
        self.retryButton.hidden = NO;
        self.retryButton.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
        [self addSubview:self.retryButton];
        return;
    } else {
        self.retryButton.hidden = YES;
        [self.retryButton removeFromSuperview];
    }
    
    switch (status) {
        case JPPlaybackStatusPreLoading:
            [self.activityIndicatorView startAnimating];
            
            [self.blurEffectView removeFromSuperview];
            
            [self addSubview:self.blurEffectView];
            
            [self bringSubviewToFront:self.activityIndicatorView];
            
            break;
        case JPPlaybackStatusLoading:
            [self.activityIndicatorView startAnimating];
            break;
        case JPPlaybackStatusPlaying:
            [self.activityIndicatorView stopAnimating];
            
            [self.blurEffectView removeFromSuperview];
            break;
        case JPPlaybackStatusResume:
            [self.activityIndicatorView stopAnimating];
            break;
        default:
            break;
            
    }
}

- (BOOL)shouldAutoReplayVideoWithVideoItem:(JPVideoPlayerPlayVideoToolItem *)item {
    return YES;
}

- (JPVideoPreLoadDuration *)videoPreLoadDurationWith:(JPVideoPlayerPlayVideoToolItem *)item {
    return JPVideoPreLoadDuration.second(30);
    return JPVideoPreLoadDuration.without;
}

- (void)videoItem:(JPVideoPlayerPlayVideoToolItem *)item preLoadProgress:(CGFloat)progress {
    NSLog(@"%.2f", progress);
}
@end

@interface RootViewController ()
@property (nonatomic, strong) BYPlayerView *playerView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerView = [[BYPlayerView alloc] init];
    [self.view addSubview:self.playerView];
    
//    NSURL *videoURL = [NSURL URLWithString:@"http://lavaweb-10015286.video.myqcloud.com/%E5%B0%BD%E6%83%85LAVA.mp4"];
    NSURL *videoURL = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"];
    

    [[JPVideoPlayerManager sharedManager] loadVideoWithURL:videoURL
                                                showOnView:_playerView
                                                   options:JPVideoPlayerContinueInBackground
                                                  progress:^(NSData * _Nullable data, NSInteger receivedSize, NSInteger expectedSize, NSString * _Nullable tempCachedVideoPath, NSURL * _Nullable targetURL) {
                                                      
                                                  } completed:^(NSString * _Nullable fullVideoCachePath, NSError * _Nullable error, JPVideoPlayerCacheType cacheType, NSURL * _Nullable videoURL) {
                                                      NSLog(@"%@", error);
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
