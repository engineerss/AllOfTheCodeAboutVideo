//
//  ZSPlayerModel.h
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSPlayerModel : NSObject
/** 标题 */
@property (nonatomic, copy  ) NSString *title;
/** 描述 */
@property (nonatomic, copy  ) NSString *video_description;
/** 视频地址 */
@property (nonatomic, copy  ) NSString *playUrl;
/** 封面图 */
@property (nonatomic, copy  ) NSString *coverForFeed;
/** 视频分辨率的数组 */
@property (nonatomic, strong) NSMutableArray *playInfo;

@end
