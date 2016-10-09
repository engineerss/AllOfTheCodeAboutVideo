//
//  ZSPlayerCell.h
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import "ZSPlayer.h"
#import "ZSPlayerModel.h"
#import <UIKit/UIKit.h>

typedef void(^PlayBtnCallBackBlock) (UIButton *);

@interface ZSPlayerCell : UITableViewCell





@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (nonatomic,strong) UIButton               *playBtn;
@property (nonatomic,strong) ZSPlayerModel          *model;
@property (nonatomic,copy) PlayBtnCallBackBlock      playBlock;
@end
