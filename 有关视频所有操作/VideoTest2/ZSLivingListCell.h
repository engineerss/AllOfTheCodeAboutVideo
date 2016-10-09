//
//  ZSLivingListCell.h
//  VideoTest2
//
//  Created by zs mac on 16/9/29.
//  Copyright © 2016年 zs mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListModel.h"

@interface ZSLivingListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *locationLable;

@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;

@property (weak, nonatomic) IBOutlet UIImageView *ShowImgView;

@property (nonatomic,strong)ListModel *listModel;
-(void)configCellWithModel:(ListModel *)listModel;

@end
