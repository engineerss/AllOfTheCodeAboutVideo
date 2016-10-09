//
//  StartLiveVC.h
//  VideoTest2
//
//  Created by zs mac on 16/9/30.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "LiveVideoCoreSDK.h"
#import "ASValueTrackingSlider.h"
#import <UIKit/UIKit.h>

@interface StartLiveVC : UIViewController <LIVEVCSessionDelegate, ASValueTrackingSliderDelegate, ASValueTrackingSliderDelegate>
@property (nonatomic,copy) NSURL *RtmpUrl;
@property (nonatomic,assign)BOOL isHorizontal;

@end
