//
//  MyJoinTrainViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/9/27.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "MyJoinTrainViewController.h"
#import "TrainViewModel.h"
#import "TrainDetailViewController.h"
#import "TrainListTableViewCell.h"
@interface MyJoinTrainViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) TrainViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger authStatus;
@end

@implementation MyJoinTrainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    
    [self.itemTableView registerNib:[UINib nibWithNibName:@"TrainListTableViewCell" bundle:nil] forCellReuseIdentifier:@"TrainListTableViewCell"];
    self.viewModel = [[TrainViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        
        if (self.pageIndex == 1) {
            [weakSelf.itemArr removeAllObjects];
            [weakSelf.itemTableView.mj_header endRefreshing];
        }else{
            [weakSelf.itemTableView.mj_footer endRefreshing];
        }
        if ([(NSArray *)returnValue count] < 10) {
            [weakSelf.itemTableView.mj_footer removeFromSuperview];
        }else{
            weakSelf.itemTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(footerRefreshing)];
        }
        [weakSelf.itemArr addObjectsFromArray:returnValue];
        [weakSelf.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        
        if (self.pageIndex == 1) {
            [weakSelf.itemTableView.mj_header endRefreshing];
            
        }else{
            [weakSelf.itemTableView.mj_footer endRefreshing];
        }
        
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self setupRefresh];
    
    // Do any additional setup after loading the view from its nib.
}

/**
 设置刷新
 */
-(void)setupRefresh{
    self.itemTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    [self.itemTableView.mj_header beginRefreshing];
    
}

/**
 下拉刷新
 */
-(void)headerRefreshing{
    self.pageIndex = 0;
    [self footerRefreshing];
}

/**
 上拉加载
 */
-(void)footerRefreshing{
    
    [self.viewModel fetchMyJoinTrainWithPage:@(++ self.pageIndex)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TrainListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrainListTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TrainDetailViewController *vc = [[TrainDetailViewController alloc] init];
    vc.type = 1;
    TrainModel *model = self.itemArr[indexPath.row];
    vc.cateId = model.train_id;
    [self.navigationController pushViewController:vc animated:YES];
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
