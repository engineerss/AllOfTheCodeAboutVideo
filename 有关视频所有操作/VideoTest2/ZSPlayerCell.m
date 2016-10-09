//
//  ZSPlayerCell.m
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import <Masonry/Masonry.h>
#import "UIImageView+WebCache.h"
#import "ZSPlayerCell.h"

@implementation ZSPlayerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = YES;
    self.picView.userInteractionEnabled = YES;
    self.picView.tag = 101;
    
    
    // 代码添加playerBtn到imageView上
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.backgroundColor = [UIColor brownColor];
    [self.playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playBtnclik:) forControlEvents:UIControlEventTouchUpInside];
    [self.picView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.picView);
    }];
    
    // Initialization code
}
-(void)setModel:(ZSPlayerModel *)model
{
    [self.picView sd_setImageWithURL:[NSURL URLWithString:model.coverForFeed] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];

}
-(void)playBtnclik:(UIButton *)sender
{
    
    
    
    if (self.playBlock) {
        
        
        
        self.playBlock(sender);
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
