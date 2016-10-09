//
//  MoviePlayerViewController.m
//  VideoTest2
//
//  Created by zs mac on 16/8/25.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ZSPlayerView.h"
#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()
@property (weak, nonatomic) IBOutlet ZSPlayerView *playerView;

@property (nonatomic,assign)         BOOL         isPlaying;
@end

@implementation MoviePlayerViewController
-(void)dealloc
{
    NSLog(@"%@ 释放了",self.class);
    [self.playerView cancelAutoFadeOutControlBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    if (self.playerView) {
        [self.playerView setNeedsLayout];
    }
    
    //pop回来时候是否自动播放
    if (self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        [self.playerView play];
        
    }
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
//    push 出下一级页面时候暂停
    if (self.playerView && !self.playerView.isPauseByUser) {
        self.isPlaying = YES;
        [self.playerView pause];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

//    设置播放前的展位图（需要在设置视频URL之前设置）
    
    self.playerView.placeholderImageName = @"loading_bgView1";
    self.playerView.videoURL = self.videoURL;
    
    self.playerView.title = @"可以设置视频的标题";
    
    self.playerView.palyerLayerGravity = ZSPlayerLayerGravityResizeAspect;
    
    
    //打开下载功能
    self.playerView.hasDownload = YES;
    
//    下载按钮的回调
    self.playerView.downloadBlock = ^(NSString *urlStr){
    
        //此处是截取的下载地址，可以自己根据服务器的视频名称赋值
        NSString *name = [urlStr lastPathComponent];
        
    
    };
    
    
    [self.playerView autoPlayTheVideo];
    
    __weak typeof (self) weakSelf = self;
    
    self.playerView.goBackBlock = ^{
    
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    };
    
    
    // Do any additional setup after loading the view.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        NSLog(@"屏幕竖直方向");
        self.view.backgroundColor = [UIColor whiteColor];
        
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"屏幕水平的方向");
        self.view.backgroundColor = [UIColor blackColor];
    }
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
