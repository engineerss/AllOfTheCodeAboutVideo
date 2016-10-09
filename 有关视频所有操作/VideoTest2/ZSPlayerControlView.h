//
//  ZSPlayerControlView.h
//  VideoTest2
//
//  Created by zs mac on 16/9/5.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ZSPlayer.h"
#import "ASValueTrackingSlider.h"
#import <UIKit/UIKit.h>

typedef void (^ChangeResolutionBlock)(UIButton *button);
typedef void (^SliderTapBlock)(CGFloat value);


@interface ZSPlayerControlView : UIView

//标题
@property (nonatomic,strong,readonly) UILabel                           *titleLable;

//开始播放按钮
@property (nonatomic,strong,readonly) UIButton                          *startBtn;

//当前播放时长的lable
@property (nonatomic,strong,readonly) UILabel                           *currentTimeLabel;

//视频总时长lable
@property (nonatomic,strong,readonly) UILabel                           *totalTimeLabel;

//缓冲进度条
@property (nonatomic,strong,readonly) UIProgressView                    *progressView;
//滑竿
@property (nonatomic,strong,readonly) ASValueTrackingSlider             *videoSlider;

//全屏按钮
@property (nonatomic,strong,readonly) UIButton                           *fullScreenBtn;

//锁定屏幕方向按钮
@property (nonatomic,strong,readonly) UIButton                           *lockBtn;

//快进快退lable
@property (nonatomic,strong,readonly) UILabel                            *horizontalLable;

//系统菊花

@property (nonatomic,strong,readonly) UIActivityIndicatorView            *activity;

//返回按钮
@property (nonatomic,strong,readonly) UIButton                           *backBtn;

//重播按钮
@property (nonatomic,strong,readonly) UIButton                           *repeatBtn;

//bottomView
@property (nonatomic,strong,readonly) UIImageView                        *bottomImageView;

//topView
@property (nonatomic,strong,readonly) UIImageView                        *topImageView;

//缓存按钮
@property (nonatomic,strong,readonly) UIButton                           *downLoadBtn;

//切换分辨率按钮
@property (nonatomic,strong,readonly) UIButton                           *resolutionBtn;

//播放按钮
@property (nonatomic,strong,readonly) UIButton                           *playBtn;


//分辨率名称
@property (nonatomic,strong)          NSArray                           *resolutionArray;

//切换分辨率的block
@property (nonatomic,copy)            ChangeResolutionBlock             resolutionBlock;

//slidertap事件Block
@property (nonatomic,copy)            SliderTapBlock                    tapBlock;


//重置controlView

-(void)resetControlView;

//切换分辨率时候调用的方法

-(void)resetControlViewForResolution;

//显示top，bottom，lockBtn
-(void)showControlView;

//隐藏
-(void)hideControlView;


@end



























