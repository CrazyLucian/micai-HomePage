//
//  QueryResultViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "QueryResultViewController.h"
#import "PolicyDetailViewController.h"
#import "QueryResultTableViewCell.h"
#import "PolicyViewModel.h"
@interface QueryResultViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@property (nonatomic, retain) PolicyViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation QueryResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"QueryResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"QueryResultTableViewCell"];
    self.viewModel = [[PolicyViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        if (self.pageIndex == 1) {
            [weakSelf.itemArr removeAllObjects];
            if ([(NSArray *)returnValue count] == 0) {
                weakSelf.noDataView.hidden = NO;
            }else{
                weakSelf.noDataView.hidden = YES;
            }
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
            weakSelf.noDataView.hidden = NO;
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
    ++ self.pageIndex;
    NSInteger type = [self.type integerValue] + 1;
    [self.viewModel policySearchWithKeywords:self.keywords department:self.department cat_id:self.catId location:self.location type:@(type) page:@(self.pageIndex)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)viewChange:(id)sender {
    
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QueryResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryResultTableViewCell"];
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
        PolicyDetailViewController *vc = [[PolicyDetailViewController alloc]init];
    PolicyModel *model = self.itemArr[indexPath.row];
    if ([self.type integerValue] == 2) {
        vc.type = @(1);
    }else{
        vc.type = 0;
    }
    vc.policyId = model.article_id;
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
