//
//  ZSPlayerControlView.m
//  VideoTest2
//
//  Created by zs mac on 16/9/5.
//  Copyright © 2016年 zs mac. All rights reserved.

#import "Masonry.h"
#import "ZSPlayerControlView.h"
@interface ZSPlayerControlView()
/** 标题 */
@property (nonatomic, strong) UILabel                 *titleLabel;
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView          *progressView;
/** 滑杆 */
@property (nonatomic, strong) ASValueTrackingSlider   *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lockBtn;
/** 快进快退label */
@property (nonatomic, strong) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *backBtn;
/** 重播按钮 */
@property (nonatomic, strong) UIButton                *repeatBtn;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;
/** 缓存按钮 */
@property (nonatomic, strong) UIButton                *downLoadBtn;
/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton                *resolutionBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView                  *resolutionView;
/** 播放按钮 */
@property (nonatomic, strong) UIButton                *playBtn;
@end
@implementation ZSPlayerControlView


-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];
        
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.progressView];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        
        [self.topImageView addSubview:self.downLoadBtn];
     
        [self addSubview:self.lockBtn];
        [self addSubview:self.backBtn];
        [self addSubview:self.activity];
        [self addSubview:self.repeatBtn];
        [self addSubview:self.horizontalLabel];
        [self addSubview:self.playBtn];
      
        [self.topImageView addSubview:self.resolutionBtn];
        [self.topImageView addSubview:self.titleLabel];
        
//        添加子空间的约束
        [self makeSubViewsConstraints];
//        分辨率btn点击
        [self.resolutionBtn addTarget:self action:@selector(resolutionAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSliderAction:)];
        
        [self.videoSlider addGestureRecognizer:sliderTap];
        
        
        [self.activity stopAnimating];
        self.downLoadBtn.hidden = YES;
        self.resolutionBtn.hidden = YES;
        
        [self resetControlView];
        

        
        
    }
    return  self;


}
-(void)makeSubViewsConstraints
{
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.mas_top).offset(5);
        make.width.height.mas_equalTo(40);
        
        
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(80);
    
        
    }];
    
    [self.downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        
        }];
    
    [self.resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(30);
        make.trailing.equalTo(self.downLoadBtn.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backBtn.mas_trailing).offset(10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.trailing.equalTo(self.resolutionBtn.mas_leading).offset(-10);
        
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(30);
        
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
        
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(-3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(43);
        
    }];
    
   [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.width.height.mas_equalTo(30);
       make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-5);
       make.centerY.equalTo(self.startBtn.mas_centerY);
       
   }];
    
   [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(3);
       make.centerY.equalTo(self.startBtn.mas_centerY);
       make.width.mas_equalTo(43);
       
   }];
   [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
      make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
      make.centerY.equalTo(self.startBtn.mas_centerY);
      
  }];
    
   [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
      make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
      make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
      make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
      make.height.mas_equalTo(30);
  }];
   [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.leading.equalTo(self.mas_leading).offset(15);
      make.centerY.equalTo(self.mas_centerY);
      make.width.height.mas_equalTo(40);
      
  }];
   [self.horizontalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
     make.width.mas_equalTo(150);
     make.height.mas_equalTo(33);
     make.center.equalTo(self);
 } ];
   [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
     make.center.equalTo(self);
 }];
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     make.center.equalTo(self);
 }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     make.center.equalTo(self);
    }];
    
   
    
    
    
}

#pragma  mark - ACtion
//点击topView上的按钮

-(void)resolutionAction:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    self.resolutionView.hidden = !sender.isSelected;
    
}

//点击切换别的分辨率
-(void)changeResolution:(UIButton *)sender
{
    //隐藏分辨率View
    self.resolutionView.hidden = YES;
    
//    分辨率btn改为normal状态
    self.resolutionBtn.selected = NO;
    
//_topImageView 上的按钮的文字
    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    
    if (self.resolutionBlock) {
        self.resolutionBlock(sender);
        
    }
    
    
    
}
//UISlider TapAction
-(void)tapSliderAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UISlider class]]&&self.tapBlock) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        CGFloat tapValue = point.x/length;
        self.tapBlock(tapValue);
        
    }
}

#pragma  mark - Public method

-(void)resetControlView
{
    self.videoSlider.value      = 0;
    self.progressView.progress  = 0;
    self.currentTimeLabel.text  = @"00:00";
    self.totalTimeLabel.text    = @"00:00";
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    self.playBtn.hidden        = YES;
    self.resolutionView.hidden  = YES;
    self.backgroundColor        = [UIColor clearColor];
    self.downLoadBtn.enabled    = YES;
    
}
- (void)resetControlViewForResolution
{
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    self.resolutionView.hidden  = YES;
    self.playBtn.hidden        = YES;
    self.downLoadBtn.enabled    = YES;
    self.backgroundColor        = [UIColor clearColor];
}

- (void)showControlView
{
    self.topImageView.alpha    = 1;
    self.bottomImageView.alpha = 1;
    self.lockBtn.alpha         = 1;
}



- (void)hideControlView
{
    self.topImageView.alpha    = 0;
    self.bottomImageView.alpha = 0;
    self.lockBtn.alpha         = 0;
    // 隐藏resolutionView
    self.resolutionBtn.selected = YES;
    [self resolutionAction:self.resolutionBtn];
}

#pragma mark - setter
-(void)setResolutionArray:(NSArray *)resolutionArray
{
    _resolutionArray = resolutionArray;
    [_resolutionBtn setTitle:resolutionArray.firstObject forState:UIControlStateNormal];
    
    //添加分辨率按钮和分辨率下拉列表
    self.resolutionView = [[UIView alloc]init];
    self.resolutionView.hidden = YES;
    self.resolutionView.backgroundColor = [UIColor orangeColor];
    
    [self addSubview:self.resolutionView];
    
    
    
    
    [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(30*resolutionArray.count);
        make.leading.equalTo(self.resolutionBtn.mas_leading).offset(0);
        make.top.equalTo(self.resolutionBtn.mas_bottom).offset(0);
    }];
    
    for (int i = 0; i<resolutionArray.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 200+i;
        [self.resolutionView addSubview:btn];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.frame = CGRectMake(0, 30*i, 40, 30);
        [btn setTitle:resolutionArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    

}

-(UILabel *)titleLable
{
    if (_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ZSPlayerImage(@"ZFPlayer_back_full") forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.image                  = ZSPlayerImage(@"ZFPlayer_top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.image                  = ZSPlayerImage(@"ZFPlayer_bottom_shadow");
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn
{
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZSPlayerImage(@"ZFPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:ZSPlayerImage(@"ZFPlayer_lock-nor") forState:UIControlStateSelected];
    }
    return _lockBtn;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:ZSPlayerImage(@"ZFPlayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:ZSPlayerImage(@"ZFPlayer_pause") forState:UIControlStateSelected];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
//        _currentTimeLabel.backgroundColor = [UIColor darkGrayColor];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}

- (ASValueTrackingSlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider                       = [[ASValueTrackingSlider alloc] init];
       
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        // 设置slider
        [_videoSlider setThumbImage:ZSPlayerImage(@"ZFPlayer_slider") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZSPlayerImage(@"ZFPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:ZSPlayerImage(@"ZFPlayer_shrinkscreen") forState:UIControlStateSelected];
    }
    return _fullScreenBtn;
}

- (UILabel *)horizontalLabel
{
    if (!_horizontalLabel) {
        _horizontalLabel                 = [[UILabel alloc] init];
        _horizontalLabel.textColor       = [UIColor whiteColor];
        _horizontalLabel.textAlignment   = NSTextAlignmentCenter;
        _horizontalLabel.font            = [UIFont systemFontOfSize:15.0];
        _horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:ZSPlayerImage(@"ZFPlayer_management_mask")];
    }
    return _horizontalLabel;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

- (UIButton *)repeatBtn
{
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:ZSPlayerImage(@"ZFPlayer_repeat_video") forState:UIControlStateNormal];
    }
    return _repeatBtn;
}

- (UIButton *)downLoadBtn
{
    if (!_downLoadBtn) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadBtn setImage:ZSPlayerImage(@"ZFPlayer_download") forState:UIControlStateNormal];
        [_downLoadBtn setImage:ZSPlayerImage(@"ZFPlayer_not_download") forState:UIControlStateDisabled];
    }
    return _downLoadBtn;
}

- (UIButton *)resolutionBtn
{
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _resolutionBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
    }
    return _resolutionBtn;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:ZSPlayerImage(@"ZFPlayer_play_btn") forState:UIControlStateNormal];
    }
    return _playBtn;
}


@end









