//
//  ZSLivingListVC.m
//  VideoTest2
//
//  Created by zs mac on 16/9/29.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ShowLivingView.h"
#import "ListModel.h"
#import "ZSLivingListCell.h"
#import "ZSLivingListVC.h"
#import "HttpRequestTool.h"
@interface ZSLivingListVC()
@property (nonatomic,strong)NSArray *datas;

@end

@implementation ZSLivingListVC

-(NSArray *)datas
{
    if (!_datas) {
        _datas = [NSArray array];
        
    }
    return _datas;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    [self.tableView registerClass:[ZSLivingListCell class] forCellReuseIdentifier:@"ZSLivingListCell"];
    [self loadData];
    
    
}
-(void)loadData
{
    
 
    [HttpRequestTool getWithURLString:@"http://service.ingkee.com/api/live/gettop?imsi=&uid=17800399&proto=5&idfa=A1205EB8-0C9A-4131-A2A2-27B9A1E06622&lc=0000000000000026&cc=TG0001&imei=&sid=20i0a3GAvc8ykfClKMAen8WNeIBKrUwgdG9whVJ0ljXi1Af8hQci3&cv=IK3.1.00_Iphone&devi=bcb94097c7a3f3314be284c8a5be2aaeae66d6ab&conn=Wifi&ua=iPhone&idfv=DEBAD23B-7C6A-4251-B8AF-A95910B778B7&osversion=ios_9.300000&count=10&multiaddr=1" parameters:nil success:^(NSDictionary *dictionary) {
        
        NSLog(@"首页返回数据=====%@",dictionary);
        self.datas = [ListModel mj_objectArrayWithKeyValuesArray:dictionary[@"lives"]];
        
        
       
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
     
        
        
        
    }];
}


#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZSLivingListCell * cell=[tableView dequeueReusableCellWithIdentifier:@"ZSLivingListCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    ListModel * model=self.datas[indexPath.row];
    [cell configCellWithModel:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowLivingView *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ShowLivingViewID"];
    
    
    ListModel * model=self.datas[indexPath.row];
    vc.model=model;
//    show.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
