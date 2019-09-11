//
//  PolicyFileNumberViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PolicyFileNumberViewController.h"
#import "PolicyDetailViewController.h"
#import "PolicyViewModel.h"
#import "FileNumberTableViewCell.h"
@interface PolicyFileNumberViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, retain) PolicyViewModel *viewModel;
@end

@implementation PolicyFileNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"FileNumberTableViewCell" bundle:nil] forCellReuseIdentifier:@"FileNumberTableViewCell"];
    PolicyViewModel *viewModel = [[PolicyViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self.itemArr addObjectsFromArray:returnValue];
        [self.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fileNumberSearch];
    self.viewModel = [[PolicyViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
//        if (self.pageIndex == 1) {
            [weakSelf.itemArr removeAllObjects];
            [weakSelf.itemTableView.mj_header endRefreshing];
//        }else{
//            [weakSelf.itemTableView.mj_footer endRefreshing];
//        }
//        if ([(NSArray *)returnValue count] < 10) {
//            [weakSelf.itemTableView.mj_footer removeFromSuperview];
//        }else{
//            weakSelf.itemTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(footerRefreshing)];
//        }
        [weakSelf.itemArr addObjectsFromArray:returnValue];
        [weakSelf.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
//        if (self.pageIndex == 1) {
            [weakSelf.itemTableView.mj_header endRefreshing];
//        }else{
//            [weakSelf.itemTableView.mj_footer endRefreshing];
//        }
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
    ++ self.pageIndex;
    [self.viewModel fileNumberSearch];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FileNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileNumberTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
}
#pragma mark - UITableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 110.f;
//}


//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    PolicyDetailViewController *vc = [[PolicyDetailViewController alloc]init];
    PolicyModel *model = self.itemArr[indexPath.row];
    self.returnBlock(model.document_number);
    [self backAction:nil];
//    vc.policyId = model.article_id;
//    [self.navigationController pushViewController:vc animated:YES];
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
