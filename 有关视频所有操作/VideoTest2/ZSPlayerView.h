//
//  ZSPlayerView.h
//  VideoTest2
//
//  Created by zs mac on 16/8/25.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import <UIKit/UIKit.h>
//返回按钮的block
typedef void(^ZSPlayerBackCallBack)(void);

//下载按钮的回调
typedef void(^ZSDownloadCallBack)(NSString *urlStr);


//paalyerLayer 的填充模式 （默认：等比例填充，知道一个维度到达边界区域）

typedef NS_ENUM(NSInteger,ZSPlayerLayerGravity)
{
    ZSplayerLayerGravityResize,  //非均匀模式。两个维度完全填充至整个视图区域
    ZSPlayerLayerGravityResizeAspect,  //等比例填充，知道一个维度到达区域边界
    ZAPlayerLayerGravityResizeAspectFill   //等比例填充，知道填充满整个视图区域，其中一个维度的部分会被裁剪
};

@interface ZSPlayerView : UIView


//视频URL
@property (nonatomic,strong) NSURL                  *videoURL;


//视频的标题
@property (nonatomic,strong) NSString               *title;


//视频url的数组
@property (nonatomic,strong) NSArray                *videoURLArray;

//返回按钮BLock
@property (nonatomic,copy)  ZSPlayerBackCallBack    goBackBlock;

@property (nonatomic,copy)  ZSDownloadCallBack      downloadBlock;

//设置palyerLayer 的填充模式
@property (nonatomic,assign) ZSPlayerLayerGravity   palyerLayerGravity;


//是否有下载功能
@property (nonatomic,assign) BOOL                   hasDownload;

//切换分辨率传的字典（key:分辨率的名称，value：分辨率的url）
@property (nonatomic,strong) NSDictionary           *resolutionDic;


//从**秒开始播放视频
@property (nonatomic,assign) NSInteger              seekTime;


//播放前站位图片的名称，不设置就默认展位图（需要在设置视频URL之前设置）
@property (nonatomic,copy) NSString                 *placeholderImageName;


//是否被用户暂停
@property (nonatomic,assign,readonly) BOOL          isPauseByUser;


//自动播放
-(void)autoPlayTheVideo;


//取消延时隐藏controlView的方法，在ViewController的delloc的方法中调用
//用于解决刚打开视频播放器，就关闭页面，makView的延时隐藏还未执行
-(void)cancelAutoFadeOutControlBar;


//单利，用于列表cell上多个视频 retrun ZSPlayer
+(instancetype)sharePlayerView;

//player添加到cell上  cell 添加player的cellImageView
-(void)addPlayerToCellImageView:(UIImageView *)imageView;


//在当前页面，设置新的Player的URL调用此方法
-(void)resetToPlayNewURL;


//播放
-(void)play;


//暂停
-(void)pause;

/**
 *  重置player
 */
- (void)resetPlayer;

//设置URL的setter方法
-(void)setVideoURL:(NSURL *)videoURL;


//用于cell上播放的palyer
-(void)setVideo:(NSURL *)videoURL withTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexpath withImageViewTag:(NSInteger)tag;






@end
