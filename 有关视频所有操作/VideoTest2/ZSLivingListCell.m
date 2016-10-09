//
//  ZSLivingListCell.m
//  VideoTest2
//
//  Created by zs mac on 16/9/29.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "UIImageView+WebCache.h"

#import "ZSLivingListCell.h"

@implementation ZSLivingListCell

-(void)configCellWithModel:(ListModel *)listModel
{
   
   
    
    NSLog(@"model=========%@",listModel.online_users);
    
    //头像img
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",listModel.creator[@"portrait"]]] completed:nil];
    [self.ShowImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",listModel.creator[@"portrait"]]] completed:nil];
    
    self.nickNameLabel.text = listModel.creator[@"nick"];
    
    
    NSString *str = [NSString stringWithFormat:@"%@ 在看",listModel.online_users];
    
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:str];
    [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor orangeColor]} range:NSMakeRange(0, attribute.length -2)];
    [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(attribute.length-2, 2)];
    
    self.onlineLabel.attributedText = attribute;
    if (![listModel.creator[@"location"] isEqualToString:@""]) {
        self.locationLable.text = listModel.creator[@"location"];
    }else
    {
        self.locationLable.text = @"我是谁？";
    }
    
    
    
    
    
}






@end
