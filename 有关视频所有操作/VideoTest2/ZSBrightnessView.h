//
//  ZSBrightnessView.h
//  VideoTest2
//
//  Created by zs mac on 16/9/12.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSBrightnessView : UIView

//调用单利记录播放状态是否锁定屏幕的方向
@property (nonatomic,assign) BOOL                   isLock;

//cell上添加player时候，不允许横屏，只运行状态
@property (nonatomic,assign) BOOL                   isAllowLandscape;

+(instancetype)shareBrightnessView;




@end
