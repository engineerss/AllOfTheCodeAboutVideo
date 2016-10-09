
//
//  PlayNetWorkVideo.m
//  VideoTest2
//
//  Created by zs mac on 16/8/25.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "MoviePlayerViewController.h"
#import "PlayNetWorkVideo.h"

@interface PlayNetWorkVideo ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *dataSource;
@end

@implementation PlayNetWorkVideo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor orangeColor];
    self.dataSource = @[@"http://dlhls.cdn.zhanqi.tv/zqlive/112514_d1vaV.m3u8",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://baobab.wdjcdn.com/1455782903700jy.mp4",
                        @"http://baobab.wdjcdn.com/14564977406580.mp4",
                        @"http://baobab.wdjcdn.com/1456316686552The.mp4",
                        @"http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                        @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                        @"http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                        @"http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                        @"http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                        @"http://baobab.wdjcdn.com/1456653443902B.mp4",
                        @"http://baobab.wdjcdn.com/1456231710844S(24).mp4"];
    
    // Do any additional setup after loading the view.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"netListCell"];
    
    
    
    cell.textLabel.text   = [NSString stringWithFormat:@"网络视频%zd",indexPath.row+1];
    return cell;
}
- (IBAction)dissMissBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    MoviePlayerViewController *movieVC = (MoviePlayerViewController *)segue.destinationViewController;
    
    UITableViewCell *cell              = (UITableViewCell *)sender;
    NSIndexPath     *indexPath         = [self.tableView indexPathForCell:cell];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURL           *URL               = [NSURL URLWithString:self.dataSource[indexPath.row]];
    movieVC.videoURL                   = URL;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
