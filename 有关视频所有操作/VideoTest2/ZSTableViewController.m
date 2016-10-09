//
//  ZSTableViewController.m
//  VideoTest2
//
//  Created by zs mac on 16/9/20.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ZSPlayerResolution.h"
#import "ZSPlayerCell.h"
#import "ZSPlayerModel.h"
#import "ZSPlayerView.h"
#import "ZSTableViewController.h"

@interface ZSTableViewController ()

@property (nonatomic,strong)     NSMutableArray *dataSource;
@property (nonatomic,strong)     ZSPlayerView   *playerView;

@end

@implementation ZSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 397.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self requestData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    
    [self.playerView resetPlayer];
    
}
-(void)requestData
{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"videoData" ofType:@"json"];
    
    NSData   *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    self.dataSource = @[].mutableCopy;
    
    NSArray *videoList = [rootDict objectForKey:@"videoList"];
    
    for (NSDictionary *dataDic in videoList)
    {
        ZSPlayerModel *model = [[ZSPlayerModel alloc]init];
        [model setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:model];
        
    }
    
    
    
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *identifier             = @"playerCell";
    ZSPlayerCell *cell                      = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    __block ZSPlayerModel *model            = self.dataSource[indexPath.row];
    
    cell.model                              = model;
    
    __block NSIndexPath *weakIndexPath      = indexPath;
    __block ZSPlayerCell  *weakCell         = cell;
    __weak typeof (self) weakSelf           = self;
    

    ///点击播放的回调
    cell.playBlock = ^(UIButton *btn){
    
        weakSelf.playerView = [ZSPlayerView sharePlayerView];
        
//        设置播放前的站位图（需要在设置视频URL之前设置）
        weakSelf.playerView.placeholderImageName = @"loading_bgView1";
        
        //分辨率字典（key：分辨率名称，value：分辨率url）
        NSMutableDictionary *dic = @{}.mutableCopy;
        
        for (ZSPlayerResolution *resolution in model.playInfo) {
            [dic setValue:resolution.url forKey:resolution.name];
        }
        
        //取出字典中的第一视频url
        NSURL *videoURL = [NSURL URLWithString:dic.allValues.firstObject];
        
        NSLog(@"videoURL====%@",videoURL);
        
        //设置player相关的参数（需要设置imageView的tag值，此处设置的为101）
        [weakSelf.playerView setVideo:videoURL withTableView:weakSelf.tableView AtIndexPath:weakIndexPath withImageViewTag:101];
        
        
        [weakSelf.playerView addPlayerToCellImageView:weakCell.picView];
        
        weakSelf.playerView.title = @"可以设置视频的标题";
        
        //下载功能
        weakSelf.playerView.hasDownload = YES;
        
        //下载按钮的回调
        weakSelf.playerView.downloadBlock = ^(NSString *urlStr){
        
            //此处是截取的下载地址，可以根据服务器的视频名称来赋值
            NSString *name = [urlStr lastPathComponent];
            
            

        };
        
        weakSelf.playerView.resolutionDic = dic;
        weakSelf.playerView.palyerLayerGravity = ZAPlayerLayerGravityResizeAspectFill;
        [weakSelf.playerView autoPlayTheVideo];

    };

    
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
