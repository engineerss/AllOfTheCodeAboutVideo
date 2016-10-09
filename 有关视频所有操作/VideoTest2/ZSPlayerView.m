//
//  ZSPlayerView.m
//  VideoTest2
//
//  Created by ； mac on 16/8/25.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "Masonry.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZSPlayer.h"
#import "ZSPlayerView.h"



static const CGFloat  ZSPlayerAnimationTimeInterval                 = 7.0f;
static const CGFloat  ZSPlayerControlBarAutoFadeOutTimeInterval     = 0.35;

//枚举值，包含水平移动方向和垂直移动方向

typedef NS_ENUM(NSInteger,PanDirection)
{
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};


//播放器的几种状态
typedef NS_ENUM(NSInteger, ZSPlayerState)
{
    ZSPlayerStateFailed, //播放失败
    ZSPlayerStateBuffering, //缓冲中
    ZSPlayerStatePlaying, //播放中
    ZSPlayerStateStopped, //停止播放
    ZSPlayerStatePause, //暂停播放
};

@interface ZSPlayerView()<UIGestureRecognizerDelegate,UIAlertViewDelegate>
//播放属性
@property (nonatomic,strong) AVPlayer                                 *player;
@property (nonatomic,strong) AVPlayerItem                             *playerItem;
@property (nonatomic,strong) AVURLAsset                               *urlAsset;
@property (nonatomic,strong) AVAssetImageGenerator                    *imageGenerator;

//playlayer
@property (nonatomic,strong) AVPlayerLayer                            *playerLayer;
@property (nonatomic,strong) id                                       timeObserve;

//滑竿
@property (nonatomic,strong) UISlider                                 *volumeViewSlider;

//控制层的view
@property (nonatomic,strong) ZSPlayerControlView                      *controlView;

//用来保存快进的时长
@property (nonatomic,assign) CGFloat                                  sumTime;

//定义一个实例变量，保存枚举值
@property (nonatomic,assign) PanDirection                             panDirection;

//播放器的几种状态
@property (nonatomic,assign) ZSPlayerState                            state;

//是否为全屏
@property (nonatomic,assign) BOOL                                     isFullScreen;

//是否锁定屏幕的方向
@property (nonatomic,assign) BOOL                                     isLock;

//是否在调节音量
@property (nonatomic,assign) BOOL                                     isVolume;

//是否显示controlView
@property (nonatomic,assign) BOOL                                     isMaskShowing;


//是否被用户暂停
@property (nonatomic,assign) BOOL                                     isPauseByUser;

//是否播放本地的视频
@property (nonatomic,assign) BOOL                                     isLocalVideo;

//slider上次的值
@property (nonatomic,assign) CGFloat                                   sliderLastValue;

//是否再次设置URL播放视频
@property (nonatomic,assign) BOOL                                     repeatToPlay;


//播放完了
@property (nonatomic,assign) BOOL                                     playDidEnd;

//进入后台
@property (nonatomic,assign) BOOL                                     didEnterBackground;

//是否自动播放
@property (nonatomic,assign) BOOL                                     isAutoPlay;
@property (nonatomic,strong) UITapGestureRecognizer                   *tap;
@property (nonatomic,strong) UITapGestureRecognizer                   *doubleTap;

#pragma mark -UITableViewCell PlayerView

//palyer加到tableView上
@property (nonatomic,strong) UITableView                              *tableView;

//player 所在cell的indexPath
@property (nonatomic,strong) NSIndexPath                              *indexPath;
//cell上imageView的tag
@property (nonatomic,assign) NSInteger                                cellImageViewTag;

//viewController中页面是否消失
@property (nonatomic,assign) BOOL                                     viewDisappear;

//是否在cell上播放video
@property (nonatomic,assign) BOOL                                     isCellVideo;

//是否缩小视频在底部
@property (nonatomic,assign) BOOL                                     isBottomVideo;
//是否切换分辨率
@property (nonatomic,assign) BOOL                                     isChangeResolution;



@end

@implementation ZSPlayerView
/*
单例 ，用于列表cell上多个视频
*/

+(instancetype)sharePlayerView
{
    static ZSPlayerView *playerView = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        playerView = [[ZSPlayerView alloc]init];
        
    });
    
    return playerView;
    
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeThePlayer];
    
}
-(void)dealloc
{
    self.playerItem = nil;
    self.tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //移除time观察者
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
}
//代码初始化调用此方法

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeThePlayer];
    }
    return self;
}

//初始化player
-(void)initializeThePlayer
{
    //每次播放都解锁屏幕锁定
    [self unLockTheScreen];
}

/**
 *  解锁屏幕方向锁定
 */
-(void)unLockTheScreen
{
    //调用appdelegate单利记录播放状态是否锁屏
    ZSPlayerShared.isLock =  NO;
    self.controlView.lockBtn.selected = NO;
    
    self.isLock = NO;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
    
    
    
    
}

//强制屏幕转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    
    
    
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        
        
        
        
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscape];
        
    }else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortrait];
        
    }
    /*
     // 非arc下
     if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
     [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
     withObject:@(orientation)];
     }
     
     // 直接调用这个方法通不过apple上架审核
     [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
     */

}
//设置横屏的约束

- (void)setOrientationLandscape
{
    
    
    
    
    
    if (self.isCellVideo)
    {
        [self.tableView removeObserver:self forKeyPath:KZSPlayerViewContentOffset];
        
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        //亮度view加到window 最上层
        ZSBrightnessView *brightnessView = [ZSBrightnessView shareBrightnessView];
        
        [[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
    }
    
}

//设置竖屏的约束
-(void)setOrientationPortrait
{
    if (self.isCellVideo) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        [self removeFromSuperview];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
        NSArray *visableCells = self.tableView.visibleCells;
        self.isBottomVideo = NO;
        
        if (![visableCells containsObject:cell]) {
            [self updatePlayerViewToBottom];
            
        }else
        {
            UIImageView *cellImageView = [cell viewWithTag:self.cellImageViewTag];
            [self addPlayerToCellImageView:cellImageView];
        }
        
        
        
        
       
    }
}

//用于cell上播放player


-(void)setVideo:(NSURL *)videoURL withTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexpath withImageViewTag:(NSInteger)tag
{
    
    
    NSLog(@"---------------------");
    
//    如果页面没有消失，并且playerItem有值，需要重置player（其实就是点击播放其他视频的时候）
    if (!self.viewDisappear && self.playerItem) {
        [self resetPlayer];
    }
    
//    在cell上播放视频
    self.isCellVideo = YES;
    
    self.viewDisappear = NO;
    self.cellImageViewTag = tag;
    
    
    self.tableView = tableView;
    
//    设置indexPath
    self.indexPath = indexpath;
    
    //设置视频URL
    [self setVideoURL:videoURL];
    
    
    
    
}
//videoUrl的setter方法
-(void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    
    if (!self.placeholderImageName) {
        UIImage *image = ZSPlayerImage(@"ZFPlayer_loading_bgView");
        self.layer.contents = (id)image.CGImage;
        
    }
    
    //每次加载视频URL都设置重新播放为NO
    self.repeatToPlay = NO;
    
    self.playDidEnd = NO;
    
//    添加通知
    [self addNotifications];

}



//添加通知，观察者

-(void)addNotifications
{
    //app退到后台
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    
    
    
    //app进入前台
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //slider开始滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    
    //slider开始滑动中的事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //slider结束滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    
//    播放按钮点击事件
    [self.controlView.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //cell上播放视频的话，该返回按钮为x
    if (self.isCellVideo) {
        [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
        
    }else
    {
        [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
    }
    
    //返回按钮事件
    [self.controlView.backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    //全屏按钮点击事件
    [self.controlView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //锁定屏幕方向点击事件
    [self.controlView.lockBtn addTarget:self action:@selector(lockScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //重播
    [self.controlView.repeatBtn addTarget:self action:@selector(repeatPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    //中间按钮播放
    [self.controlView.playBtn addTarget:self action:@selector(configZSPlayer) forControlEvents:UIControlEventTouchUpInside];
    
    [self.controlView.downLoadBtn addTarget:self action:@selector(downloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    
    //切换分辨率
    self.controlView.resolutionBlock = ^(UIButton *button){
    
        //记录切换分辨率时刻
        NSInteger currentTime = (NSInteger)CMTimeGetSeconds([weakSelf.player currentTime]);
      
        NSString  *videoStr = weakSelf.videoURLArray[button.tag - 200];
        
        NSURL     *videoURL = [NSURL URLWithString:videoStr];
        
        if ([videoURL isEqual:weakSelf.videoURL]) {
            return ;
        }
        
        weakSelf.isChangeResolution = YES;
        //reset player
        [weakSelf resetToPlayNewURL];
        weakSelf.videoURL = videoURL;
        //从xx秒播放
        weakSelf.seekTime = currentTime;
        
        //切换完分辨率自动播放
        [weakSelf autoPlayTheVideo];
        
        
    };
    
    //点击slider快进
    self.controlView.tapBlock = ^(CGFloat value){
    
        [weakSelf pause];
        
        //视频总时间长度
        CGFloat total = (CGFloat)weakSelf.playerItem.duration.value/weakSelf.playerItem.duration.timescale;
        
        //计算出拖动的当前 的秒数
        NSInteger dragedSeconds = floorf(total *value);
        
        weakSelf.controlView.startBtn.selected = YES;
        [weakSelf seekToTime:dragedSeconds completionHandler:^(BOOL finished) {
            {}
        }];
        
        
    };

    //检测设备方向
    [self listeningRotating];

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
//    只要屏幕旋转就显示控制层
    self.isMaskShowing = NO;
    
    //延迟隐藏controlView
    [self animateShow];
    
    // 4s，屏幕宽高比不是16：9的问题,player加到控制器上时候
    if (iPhone4s && !self.isCellVideo) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(ScreenWidth*2/3);
        }];
    }
    // fix iOS7 crash bug
    [self layoutIfNeeded];

}

/**
 *  监听设备旋转通知
 */
- (void)listeningRotating
{
    
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    
}

-(void)downloadVideo:(UIButton *)sender
{
    NSString *urlStr = self.videoURL.absoluteString;
    if (self.downloadBlock) {
        self.downloadBlock(urlStr);
    }
}

//重播点击事件
-(void)repeatPlay:(UIButton *)sender
{
    //没有播放完
    self.playDidEnd = NO;
    
    //重播该为NO
    self.repeatToPlay = NO;
    //准备显示控制层
    self.isMaskShowing = NO;
    [self animateShow];
    
//    重置控制层
    [self.controlView resetControlView];
    [self seekToTime:0 completionHandler:nil];
    
    
    
    
    
}
//返回按钮事件
-(void)backButtonAction
{
    if (self.isLock) {
        [self unLockTheScreen];
        return;
    }else
    {
        if (!self.isFullScreen) {
            //在cell上播放视频
            if (self.isCellVideo) {
                [self resetPlayer];
                [self removeFromSuperview];
                return;
            }
            
            //player加到控制器上，只有一个player的时候
            [self pause];
            if (self.goBackBlock) {
                self.goBackBlock();
            }
            
        }else{
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
    }
}
//播放暂停按钮

-(void)startAction:(UIButton *)button
{
    button.selected = !button.selected;
    self.isPauseByUser = !self.isPauseByUser;
    if (button.selected) {
        [self play];
        if (self.state == ZSPlayerStatePause) {
            self.state = ZSPlayerStatePlaying;
        }
    }else
    {
        [self pause];
        if (self.state == ZSPlayerStatePlaying) {
            self.state = ZSPlayerStatePause;
        }
    }

}

//slider开始滑动事件
-(void)progressSliderTouchBegan:(ASValueTrackingSlider *)slider
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}



//滑动中的事件
- (void)progressSliderValueChanged:(ASValueTrackingSlider *)slider
{
//    拖动改变视频播放进度
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        NSString *style  = @"";
        
        CGFloat value = slider.value - self.sliderLastValue;
        
        if (value >0) {
            style = @">>";
        }
        if (value<0) {
            style = @"<<";
        }
        if (value ==0) {
            return;
        }
        
        self.sliderLastValue = slider.value;
        
        [self pause];
        
        CGFloat total = (CGFloat)_playerItem.duration.value/_playerItem.duration.timescale;
        
        //计算出拖动的当期秒杀
        NSInteger dragedSeconds = floorf(total * slider.value);
        
//        转化成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        //拖拽的时长
        NSInteger proMin = (NSInteger)CMTimeGetSeconds(dragedCMTime)/60; //当前秒数
        
        NSInteger proSec = (NSInteger)CMTimeGetSeconds(dragedCMTime)%60; // 当前的分钟
        
        //duration 总时长
    
        NSInteger durMin        = (NSInteger)total / 60;//总秒
        NSInteger durSec        = (NSInteger)total % 60;//总分钟
        
        NSString *currentTime   = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        NSString *totalTime     = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
        
        //当总时间>0时候才能拖动slider
        if (total>0)
        {
            self.controlView.videoSlider.popUpView.hidden = !self.isFullScreen;
            self.controlView.currentTimeLabel.text = currentTime;
            
            
            if (self.isFullScreen) {
                [self.controlView.videoSlider setText:currentTime];
                dispatch_queue_t queue = dispatch_queue_create("com.playerPic.queue", DISPATCH_QUEUE_CONCURRENT);
                dispatch_async(queue, ^{
                    NSError *error;
                    CMTime actualTime;
                    CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:dragedCMTime actualTime:&actualTime error:&error];
                    CMTimeShow(actualTime);
                    
                    UIImage *image = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.controlView.videoSlider setImage:image?:ZSPlayerImage(@"ZFPlayer_loading_bgView")];
                        
                    });
                });
                
            }else{
            
                self.controlView.horizontalLable.hidden = NO;
                self.controlView.horizontalLable.text = [NSString stringWithFormat:@"%@ %@ / %@",style,currentTime,totalTime];
            }
        }else
        {
            slider.value = 0;
        }

    }else
    {
        //player 状态加载失败，此时设置slider值为0
        slider.value = 0;
    }
    
    
}

//slider滑动结束事件
-(void)progressSliderTouchEnded:(ASValueTrackingSlider *)slider
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.controlView.horizontalLable.hidden = YES;
        });
        
        //结束滑动时候把开始播放按钮改为播放状态
        self.controlView.startBtn.selected = YES;
        self.isPauseByUser = NO;
        
        
        
        //滑动结束延时隐藏controlView
        [self autoFadeOutControlBar];
        
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
        [self seekToTime:dragedSeconds completionHandler:nil];
    }
}




//应用进入前台
-(void)appDidEnterPlayGround
{
    self.didEnterBackground = NO;
    self.isMaskShowing = NO;
    //延迟隐藏controlView
    [self animateShow];
    
    if (!self.isPauseByUser)
    {
        self.state = ZSPlayerStatePlaying;
        self.controlView.startBtn.selected = YES;
        self.isPauseByUser = NO;
        
        [self play];
        
        
    }
}


/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    self.state            = ZSPlayerStateStopped;
    if (self.isBottomVideo && !self.isFullScreen) { // 播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
        self.repeatToPlay = NO;
        self.playDidEnd   = NO;
        [self resetPlayer];
    } else {
        self.controlView.backgroundColor  = RGBA(0, 0, 0, .6);
        self.playDidEnd                   = YES;
        self.controlView.repeatBtn.hidden = NO;
        // 初始化显示controlView为YES
        self.isMaskShowing                = NO;
        // 延迟隐藏controlView
        [self animateShow];
    }
}


//应用退到后台
-(void)appDidEnterBackground
{
    
    self.didEnterBackground = YES;
    [_player pause];
    self.state = ZSPlayerStatePause;
    [self cancelAutoFadeOutControlBar];
    self.controlView.startBtn.selected = NO;
}


//自动播放，默认不自动播放
-(void)autoPlayTheVideo
{
    self.isAutoPlay = YES;
    //设置player相关参数
    [self configZSPlayer];
    
    
}
 //设置player相关参数
-(void)configZSPlayer
{
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];;
    
    //初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    
    //每次重新创建player。替换replaceCurrentItemWithPlayerItem，该方法阻塞线程
//    [AVPlayer cu]
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    //初始化playerlayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //此处默认视频填充模式
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    
    //初始化显示controlView为yes
    self.isMaskShowing = YES;
    
    //延迟隐藏controlView
    [self autoFadeOutControlBar];
    
    //添加手势
    [self createGesture];
    
    //添加播放器计时器
    [self createTimer];
    
    //获取系统时间
    [self configureVolume];
    
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.state = ZSPlayerStatePlaying;
        self.isLocalVideo = YES;
        self.controlView.downLoadBtn.enabled = NO;
        
    }else
    {
        self.state = ZSPlayerStateBuffering;
        self.isLocalVideo = NO;
    }
    
    //开始播放
    [self play];
    self.controlView.startBtn.selected = YES;
    self.isPauseByUser = NO;
    self.controlView.playBtn.hidden = YES;
    
    //强制让系统调用layoutSubviews 两个方法必须同时写
    [self setNeedsLayout]; //是标记 异步刷新 会调但是慢
    [self layoutIfNeeded]; //加上此代码立刻刷新
    
    
    
    
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:self.controlView];
        
        //屏幕下方slider区域 || 在cell上播放视频&&不是全屏状态 ||播放完了  都不响应pan手势
        if ((point.y > self.bounds.size.height - 40)||(self.isCellVideo && !self.isFullScreen) || self.playDidEnd) {
            return NO;
        }
        return YES;
    }
    // 在cell上播放视频&&不是全屏&&点在控制层上
    
    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView) {
        [self fullScreenAction:self.controlView.fullScreenBtn];
        return NO;
    }
    if (self.isBottomVideo && !self.isFullScreen && touch.view == self.controlView.backBtn) {
        //关闭player
        
        [self resetPlayer];
        [self removeFromSuperview];
        return NO;
    }
    
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex == 0) {
            [self backButtonAction];
        }
        if (buttonIndex == 1) {
            [self configZSPlayer]; //点击确定，设置player的相关参数
        }
    }
}

//单击的方法
-(void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBottomVideo && !self.isFullScreen) {
            [self fullScreenAction:self.controlView.fullScreenBtn];
            return;
        }
        self.isMaskShowing?([self hideControlView]):([self animateShow]);
        
    }
    
    
}

//通过颜色来生成一个纯色的图片
-(UIImage *)buttonImageFromColor:(UIColor *)color
{
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
    
}
//设置播放状态
-(void)setState:(ZSPlayerState)state
{
    _state = state;
    if (state == ZSPlayerStatePlaying) {
        //改为黑色背景，不然展位图会显示
        
        UIImage *image = [self buttonImageFromColor:[UIColor blackColor]];
        self.layer.contents = (id) image.CGImage;
    }else if (state == ZSPlayerStateFailed)
    {
        self.controlView.downLoadBtn.enabled = NO;
    }
    
    state  == ZSPlayerStateBuffering? ([self.controlView.activity stopAnimating]):([self.controlView.activity stopAnimating]);
    
    
}

//根据playerItem，来添加移除观察者
-(void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

//根据tableview 的值来添加、移除观察者
-(void)setTableView:(UITableView *)tableView
{
    if (_tableView == tableView) {
        return;
    }
    if (_tableView) {
        [_tableView removeObserver:self forKeyPath:KZSPlayerViewContentOffset];
    }
    _tableView  = tableView;
    if (tableView) {
        [tableView addObserver:self forKeyPath:KZSPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
    }
    
}

//设置palyerLayer的填充模式
-(void)setPalyerLayerGravity:(ZSPlayerLayerGravity)palyerLayerGravity
{
    _palyerLayerGravity = palyerLayerGravity;
    // AVLayerVideoGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    // AVLayerVideoGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    // AVLayerVideoGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    switch (palyerLayerGravity) {
        case ZSplayerLayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case ZSPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case ZAPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
    
}


//是否有下载功能
-(void)setHasDownload:(BOOL)hasDownload
{
    _hasDownload = hasDownload;
    
    self.controlView.downLoadBtn.hidden = !hasDownload;
    
}

-(void)setResolutionDic:(NSDictionary *)resolutionDic
{
    _resolutionDic = resolutionDic;
    self.controlView.resolutionBtn.hidden = NO;
    self.videoURLArray = [resolutionDic allValues];
    self.controlView.resolutionArray = [resolutionDic allKeys];
    
}

//设置播放前的展位图
-(void)setPlaceholderImageName:(NSString *)placeholderImageName
{
    _placeholderImageName = placeholderImageName;
    if (placeholderImageName) {
        UIImage *image = [UIImage imageNamed:self.placeholderImageName];
        self.layer.contents = (id)image.CGImage;
    }else
    {
        UIImage *image = ZSPlayerImage(@"ZFPlayer_loading_bgView");
        self.layer.contents = (id)image.CGImage;
    }
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.controlView.titleLable.text = title;
}

#pragma mark - Getter
-(ZSPlayerControlView *)controlView
{
    
    if (!_controlView) {
        _controlView = [[ZSPlayerControlView alloc]init];
        [self addSubview:_controlView];
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.equalTo(self);
        }];
    }
    return _controlView;
    
    
}




//双击播放、暂停
- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    [self animateShow];
    [self startAction:self.controlView.startBtn];
    
}

//创建手势
-(void)createGesture
{
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    self.tap.delegate = self;
    
    [self addGestureRecognizer:self.tap];
    
    
    //双击 （播放、暂停）
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    [self.doubleTap setNumberOfTapsRequired:2];
    
    [self addGestureRecognizer:self.doubleTap];
    
    
    //解决当前点击view时候响应其他控件事件
    self.tap.delaysTouchesBegan = YES;
    
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    
    
    
    
    
    
    
}


-(void)createTimer
{
    __weak typeof(self) weakSelf = self;
    
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray      *loadedRanges = currentItem.seekableTimeRanges;
        
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0)
        {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            
            //当前时长进度progress
            NSInteger proMin      = currentTime / 60; //当前秒数
            NSInteger proSec      = currentTime % 60;  //   当前分钟数
            CGFloat  totalTime    = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            
            //duration总时长
            NSInteger durMin      = (NSInteger)totalTime/60 ; //总秒数
            NSInteger durSec      = (NSInteger)totalTime%60; //总分钟数
            
            
            NSLog(@"时间长度=====%ld",(long)proSec);

            //更新slider
            
            weakSelf.controlView.videoSlider.value = CMTimeGetSeconds([currentItem currentTime])/totalTime;
            
               NSLog(@"时间长度str=====%@",[NSString stringWithFormat:@"%02zd:%02zd",proMin,proSec]);
//            更新当前播放时间
            weakSelf.controlView.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",proMin,proSec];
            
            //更新总时间
            weakSelf.controlView.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",durMin,durSec];
            
   
        }
    }];
    
    
}
//获取系统音量
-(void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    
    _volumeViewSlider = nil;
    
    for (UIView *vi in [volumeView subviews]) {
        if ([vi.class.description isEqualToString:@"MPVolumeSlider"])
        {
            _volumeViewSlider = (UISlider *)vi;
            break;
        }
    }
    
    //使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    
    
    
    if (!success) {
        NSLog(@"错误======%@",setCategoryError);
        
    }
    
    
    //监听耳机插入和拔掉的通知
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];

}


//耳机插入。拔出事件
-(void)audioRouteChangeListenerCallback:(NSNotification *)notification
{
    
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger    routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey]integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        { //耳机拔掉 拔掉耳机继续播放
            [self play];
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
    
    
}





-(void)hideControlView
{
    if (!self.isMaskShowing) {
        return;
    }
    
    [UIView animateWithDuration:ZSPlayerAnimationTimeInterval animations:^{
        [self.controlView hideControlView];
        if (self.isFullScreen) {
            self.controlView.backBtn.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            
        }else if (self.isBottomVideo && !self.isFullScreen)
        {
            self.controlView.backBtn.alpha = 1;
            
        }else
        {
            self.controlView.backBtn.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        self.isMaskShowing = NO;
    }];
}

//显示控制层
-(void)animateShow
{
    if(self.isMaskShowing){return;}
    [UIView animateWithDuration:ZSPlayerControlBarAutoFadeOutTimeInterval animations:^{
        self.controlView.backBtn.alpha = 1;
        if (self.isBottomVideo && !self.isFullScreen) { [self.controlView hideControlView]; } // 视频在底部bottom小屏,并且不是全屏状态
        else if (self.playDidEnd) { [self.controlView hideControlView]; } // 播放完了
        else { [self.controlView showControlView]; }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.isMaskShowing = YES;
        [self autoFadeOutControlBar];
    }];

    
    
    
    
    
}
#pragma mark - ShowOrHideControlView

-(void)autoFadeOutControlBar
{
    if (!self.isMaskShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:ZSPlayerAnimationTimeInterval];
    
    
    
    
}



#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.player.currentItem)
    {
        if ([keyPath isEqualToString:@"status"])
        {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                self.state = ZSPlayerStatePlaying;
                
                //加载完成后，再添加平移手势
                //添加平移手势，用来控制音量、亮度、快进快退
                
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
                
                
                
                pan.delegate = self;
                [self addGestureRecognizer:pan];
                
                
                //调到xx秒播放视频
                if (self.seekTime)
                {
                    [self seekToTime:self.seekTime completionHandler:nil];
                }
                
            }else if (self.player.currentItem.status == AVPlayerItemStatusFailed)
            {
                self.state = ZSPlayerStateFailed;
                self.controlView.horizontalLable.hidden = NO;
                self.controlView.horizontalLable.text = @"视频加载失败";
                
            }
            
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"])
        {
//            计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime         duration     =  self.playerItem.duration;
            CGFloat        totalDuration=  CMTimeGetSeconds(duration);
            [self.controlView.progressView setProgress:timeInterval/totalDuration animated:NO];
            
            if (!self.isPauseByUser && !self.didEnterBackground && (self.controlView.progressView.progress - self.controlView.videoSlider.value > 0.05)) {
                [self play];
                
            }
            
            
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            //当缓冲为空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = ZSPlayerStateBuffering;
                [self bufferingSomeSecond];
                
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            //当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == ZSPlayerStateBuffering) {
                self.state = ZSPlayerStatePlaying;
            }
        }
    }else if (object == self.tableView)
    {
        if ([keyPath isEqualToString:KZSPlayerViewContentOffset]) {
           if (([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)) { return; }
            //当tableview 滚动时处理playerView的位置
            
            [self handleScrollOffsetWithDict:change];
        }
    }
}

//pan手势事件

-(void)panDirection:(UIPanGestureRecognizer *)pan
{
    
//    根据在view上pan的位置，确定是调节音量的还是调节亮度的
    CGPoint  locationPoint = [pan locationInView:self];
    
    //我们要响应水平移动和垂直移动
//    根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    //判断是水平移动还是
    switch (pan.state) {
            
            
        case UIGestureRecognizerStateBegan:
        {
            //使用绝对值来判断移动方向
            
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            
            if ( x>y ) //水平移动
            {
                //取消隐藏
                self.controlView.horizontalLable.hidden = NO;
                self.panDirection = PanDirectionHorizontalMoved;
                CMTime time = self.player.currentTime;
                self.sumTime = time.value/time.timescale;
                //暂停播放
                [self pause];
                
            }else if (x<y) //垂直移动
            {
                self.panDirection = PanDirectionVerticalMoved;
                
                //开始滑动的时候，状态改为正在控制音量
                if (locationPoint.x >self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else
                {
                    //状态改为显示亮度调节
                    self.isVolume = NO;
                }
                
                
                
            }
            
            
            
            break;
        }
            case UIGestureRecognizerStateChanged ://正在移动
            
        {
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:
                {
                    //移动中一直显示快进lable
                    self.controlView.horizontalLable.hidden = NO;
                    //水平移动的方法只要x方向的值
                    [self horizontalMoved:veloctyPoint.x];
                    
                    
                    break;
                }
                case PanDirectionVerticalMoved:
                {
                    //垂直移动方法只要y方向的值
                    [self verticalMoved:veloctyPoint.y];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded://移动停止
        {
            //移动结束也需要判断垂直或者是平移
//            比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量玩之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:
                {
                    [self play];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.controlView.horizontalLable.hidden = YES;
                    });
                    
                    //快进、快退的时候把开始播放按钮改为播放状态
                    self.controlView.startBtn.selected = YES;
                    self.isPauseByUser = NO;
                    [self seekToTime:self.sumTime completionHandler:nil];
                    self.sumTime = 0;
                    break;
                }
                    case PanDirectionVerticalMoved:
                {
                    //垂直移动结束后，把状态改为不在控制音量
                    self.isVolume = NO;
                    
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        
                        self.controlView.horizontalLable.hidden = YES;
                    });;
                    
                    
                    
                    
                    
                    
                    break;
                }
                default:
                    break;
            }
            break;
            
        }
            default:
            break;
    }
    
    
    
    
}

//pan垂直移动的方法
-(void)verticalMoved:(CGFloat)value
{
    
    self.isVolume ? (self.volumeViewSlider.value -= value/10000) : ([UIScreen mainScreen].brightness -= value/10000);
    
}
//pan水平移动的方法
-(void)horizontalMoved:(CGFloat)value
{
    //快进快退的方法
    
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
    }
    if (value>0) {
        style = @">>";
    }
    if (value == 0) {
        return;
    }
    
    //每次滑动需要叠加时间
    self.sumTime += value/200;
    
    //需要限定suntime的范围
    CMTime totalTime    =   self.playerItem.duration;
    
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    
    if (self.sumTime >totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }
    if (self.sumTime < 0) {
        self.sumTime = 0;
    }
    
    //当前快进的时间
    NSString *nowTime = [self durationStringWithTime:(int)self.sumTime];
    
    //总时间
    NSString *durationTime = [self durationStringWithTime:(int)totalMovieDuration];
    
    //更新快进lable的时长
    self.controlView.horizontalLable.text = [NSString stringWithFormat:@"%@ %@ /%@",style,nowTime,durationTime];
    //更新slider的进度
    self.controlView.videoSlider.value = self.sumTime/totalMovieDuration;
    
    //更新现在播放的时间
    self.controlView.currentTimeLabel.text = nowTime;
    
    
    
    

    
    
    
}
//根据时长求出字符串
-(NSString *)durationStringWithTime:(int)time
{
    NSString *min = [NSString stringWithFormat:@"%02d",time/60];
    NSString *sec = [NSString stringWithFormat:@"%02d",time%60];
    return [NSString stringWithFormat:@"%@:%@",min,sec];
}

//缓冲较差的时候回调这里
-(void)bufferingSomeSecond
{
    self.state = ZSPlayerStateBuffering;
    //palybackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用的该方法都忽略
    
    __block BOOL isBuffering = NO;
    
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    //需要先暂停一会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //如果此时用户已经暂停了，则不需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return ;
        }
        
        [self play];
        isBuffering = NO;
        //如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
        
        
    });
    
  
    
    
    
}
#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */

-(NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓存区域
    
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;
    return result;
    
    
    
}






//从xx秒开始播放视频跳转
-(void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        [self.player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
            [self play];
            self.seekTime = 0;
            if (!self.playerItem.isPlaybackLikelyToKeepUp && !self.isLocalVideo) {
                self.state = ZSPlayerStateBuffering;
            }
            
        }];
        
        
        
        
        
        
        
        
        
    }
}

-(void)play
{
    self.controlView.startBtn.selected = YES;
    self.isPauseByUser = NO;
    [_player play];
}
#pragma mark - tableViewContentOffset

/**
 *  KVO TableViewContentOffset
 *
 *  @param dict void
 */

-(void)handleScrollOffsetWithDict:(NSDictionary *)dict
{
    UITableViewCell   *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    NSArray *visableCells = self.tableView.visibleCells;
    
    if ([visableCells containsObject:cell]) {
        //在显示中
        [self updatePlayerViewToCell];
        
    }else
    {
//        显示在底部
        [self updatePlayerViewToBottom];
    }
    
    
    
    
    
    
    
    
}

//缩小到底部，显示小视频
-(void)updatePlayerViewToBottom
{
    if (self.isBottomVideo) {
        return;
    }
    
    self.isBottomVideo = YES;
    if (self.playDidEnd) //如果播放完了，滑到小屏bottom位置时，直接resetPlayer
    {
        self.repeatToPlay = NO;
        self.playDidEnd = NO;
        [self resetPlayer];
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // 解决4s，屏幕宽高比不是16：9的问题
    if (iPhone4s) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat width = ScreenWidth*0.5-20;
            make.width.mas_equalTo(width);
            make.trailing.mas_equalTo(-10);
            make.bottom.mas_equalTo(-self.tableView.contentInset.bottom-10);
            make.height.mas_equalTo(width*320/480).with.priority(750);
        }];
    }else {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat width = ScreenWidth*0.5-20;
            make.width.mas_equalTo(width);
            make.trailing.mas_equalTo(-10);
            make.bottom.mas_equalTo(-self.tableView.contentInset.bottom-10);
            make.height.equalTo(self.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
        }];
    }

    
    [self.controlView hideControlView];
    
    

    
    
}

//回到cell显示

-(void)updatePlayerViewToCell
{
    if (!self.isBottomVideo) {
        return;
    }
    self.isBottomVideo = NO;
    //显示控制层
    self.controlView.alpha = 1;
    [self setOrientationPortrait];
    [self.controlView showControlView];
   
    
}







-(void)fullScreenAction:(UIButton *)sender
{
    if (self.isLock)
    {
        [self unLockTheScreen];
        return;
    }
    if (self.isCellVideo && sender.selected == YES) {
        
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        return;
    }
    
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortraitUpsideDown:{
            ZSPlayerShared.isAllowLandscape = NO;
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            ZSPlayerShared.isAllowLandscape = YES;
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            if (self.isBottomVideo || !self.isFullScreen) {
                ZSPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZSPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            if (self.isBottomVideo || !self.isFullScreen) {
                ZSPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZSPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
            
        default: {
            if (self.isBottomVideo || !self.isFullScreen) {
                ZSPlayerShared.isAllowLandscape = YES;
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            } else {
                ZSPlayerShared.isAllowLandscape = NO;
                [self interfaceOrientation:UIInterfaceOrientationPortrait];
            }
        }
            break;
    }

    
    
    
}
//屏幕方向发生改变会调用这里
-(void)onDeviceOrientationChange
{
    if (self.isLock) {
        self.isFullScreen = YES;
        return;
    }
    
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
            }
            // 设置返回按钮的约束
            [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(20);
                make.leading.mas_equalTo(7);
                make.width.height.mas_equalTo(40);
            }];
            self.isFullScreen = YES;
            
        }
            break;
        case UIInterfaceOrientationPortrait:{
            self.isFullScreen = !self.isFullScreen;
            self.controlView.fullScreenBtn.selected = NO;
            if (self.isCellVideo) {
                // 改为只允许竖屏播放
                ZSPlayerShared.isAllowLandscape = NO;
                [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
                [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(10);
                    make.leading.mas_equalTo(7);
                    make.width.height.mas_equalTo(20);
                }];
                
                // 点击播放URL时候不会调用次方法
                if (!self.isFullScreen) {
                    // 竖屏时候table滑动到可视范围
                    [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    // 重新监听tableview偏移量
                    [self.tableView addObserver:self forKeyPath:KZSPlayerViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
                }
                // 当设备转到竖屏时候，设置为竖屏约束
                [self setOrientationPortrait];
                
            }else {
                [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(5);
                    make.leading.mas_equalTo(7);
                    make.width.height.mas_equalTo(40);
                }];
            }
            self.isFullScreen = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
            }
            [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(20);
                make.leading.mas_equalTo(7);
                make.width.height.mas_equalTo(40);
            }];
            self.isFullScreen = YES;
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            self.controlView.fullScreenBtn.selected = YES;
            if (self.isCellVideo) {
                [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
                self.controlView.frame = self.frame;
                
            }
            [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(20);
                make.leading.mas_equalTo(7);
                make.width.height.mas_equalTo(40);
            }];
            self.isFullScreen = YES;
        }
            break;
            
        default:
            break;
    }
    // 设置显示or不显示锁定屏幕方向按钮
    self.controlView.lockBtn.hidden = !self.isFullScreen;
    
    // 在cell上播放视频 && 不允许横屏（此时为竖屏状态,解决自动转屏到横屏，状态栏消失bug）
    if (self.isCellVideo && !ZSPlayerShared.isAllowLandscape) {
        [self.controlView.backBtn setImage:ZSPlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
        [self.controlView.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.leading.mas_equalTo(7);
            make.width.height.mas_equalTo(20);
        }];
        self.controlView.fullScreenBtn.selected = NO;
        self.controlView.lockBtn.hidden = YES;
        self.isFullScreen = NO;
        return;
    }

}
//锁定屏幕方向按钮

-(void)lockScreenAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.isLock = sender.selected;
    ZSPlayerShared.isLock = sender.selected;
    
    
}

-(void)resetPlayer
{
    // 改为为播放完
    self.playDidEnd         = NO;
    self.playerItem         = nil;
    self.didEnterBackground = NO;
    
    
    // 视频跳转秒数置0
    self.seekTime           = 0;
    self.isAutoPlay         = NO;
    
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
        
    }
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    暂停
    [self pause];
    
    //移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    
    self.imageGenerator = nil;
    
    //替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    //把player置换为nil
    self.player = nil;
    
    //切换分辨率
    if (self.isChangeResolution) {
        
        [self.controlView resetControlViewForResolution];
        self.isChangeResolution = NO;
    }else
    {
        [self.controlView resetControlView];
    }
    
    
//    非重播时，移除当前的PlayerView
    if(!self.repeatToPlay)
    {
        [self removeFromSuperview];
    }
    //底部播放的Video改为No
    self.isBottomVideo = NO;
    
    if (self.isCellVideo && !self.repeatToPlay) {
        self.viewDisappear = YES;
        self.isCellVideo = NO;
        self.tableView = nil;
        self.indexPath = nil;
    }
 
    
}
-(void)pause
{
    self.controlView.startBtn.selected = NO;
    self.isPauseByUser = YES;
    [_player pause];
}

//当前页面，设置新的palyer的URL调用此方法
-(void)resetToPlayNewURL
{
    self.repeatToPlay = YES;
    [self resetPlayer];
}



//player添加到cellImageView上
-(void)addPlayerToCellImageView:(UIImageView *)imageView
{
    [imageView addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(imageView);
    }];
}

-(AVAssetImageGenerator *)imageGenerator
{
    if (_imageGenerator) {
        _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.urlAsset];
    }
    return _imageGenerator;
    
}
-(void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}
@end
