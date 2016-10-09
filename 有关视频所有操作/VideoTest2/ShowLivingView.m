//
//  ShowLivingView.m
//  VideoTest2
//
//  Created by zs mac on 16/9/29.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import "ShowLivingView.h"
@interface ShowLivingView()


@property (atomic,retain)id <IJKMediaPlayback>player;
@property (weak,nonatomic) UIView *playerView;
@end
@implementation ShowLivingView

-(void)viewDidLoad
{
    [super viewDidLoad];
    _player = [[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.model.stream_addr] withOptions:nil];
    UIView *playerView = [self.player view];
    
    UIView *displayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    self.playerView = displayView;
    
    self.playerView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.playerView];
    
    playerView.frame = self.playerView.bounds;
    
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.playerView insertSubview:playerView atIndex:1];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFill];
    [self installMovieNotificationObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    
    
    
    self.navigationController.navigationBarHidden=YES;
    
    UIButton * back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(self.view.bounds.size.width-50, self.view.bounds.size.height-50, 40, 40);
    [back setTitle:@"关闭" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView addSubview:back];
}
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            self.playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            
            
        }
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        {
            self.playerView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            self.playerView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
            break;
        default:
            break;
    }
    
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if (![self.player isPlaying]) {
        [self.player prepareToPlay];
    }
}


-(void)loadStateDidChange:(NSNotification *)notification
{
    IJKMPMovieLoadState loadState = self.player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"111-----播放的状态1========%lu",(unsigned long)loadState);
        
    }else if ((loadState & IJKMPMovieLoadStateStalled)!= 0)
    {
        NSLog(@"222========播放的状态====%lu",(unsigned long)loadState);
        
    }else
    {
          NSLog(@"333========播放的状态====%lu",(unsigned long)loadState);
    }
    

}

-(void)moviePlayBackFinish:(NSNotification *)notification
{
    int reason = [[[notification userInfo]valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    
    
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }

    
}

-(void)mediaIsPreparedToPlayDidChange:(NSNotification *)notification
{
    NSLog(@"这个是什么几把");
}


- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}



-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}
- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}
-(void)dealloc
{
    [self.player shutdown];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
