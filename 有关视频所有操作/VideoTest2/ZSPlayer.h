//
//  ZSPlayer.h
//  VideoTest2
//
//  Created by zs mac on 16/8/25.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#ifndef ZSPlayer_h
#define ZSPlayer_h


#endif /* ZSPlayer_h */

#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//监听tableView 的contentoffset
#define KZSPlayerViewContentOffset           @"contentOffset"

//palyer 的单利
#define ZSPlayerShared                       [ZSBrightnessView shareBrightnessView]

//屏幕的宽
#define ScreenWidth                           [[UIScreen mainScreen] bounds].size.width

//屏幕的高
#define ScreenHeight                          [[UIScreen mainScreen] bounds].size.height


// 颜色值RGB
#define RGBA(r,g,b,a)                        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// 图片路径
#define ZSPlayerSrcName(file)               [@"ZSPlayer.bundle" stringByAppendingPathComponent:file]

#define ZSPlayerFrameworkSrcName(file)      [@"Frameworks/ZFPlayer.framework/ZSPlayer.bundle" stringByAppendingPathComponent:file]

#define ZSPlayerImage(file)                 [UIImage imageNamed:ZSPlayerSrcName(file)] ? :[UIImage imageNamed:ZSPlayerFrameworkSrcName(file)]

#import "ZSPlayerView.h"
#import "ZSPlayerControlView.h"
#import "ZSBrightnessView.h"

