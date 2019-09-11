//
//  InvoiceManageViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "InvoiceManageViewController.h"
#import "InvoiceUpdateViewController.h"
#import "PayInvoiceTableViewCell.h"
#import "TrainViewModel.h"

@interface InvoiceManageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) TrainViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@end

@implementation InvoiceManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"PayInvoiceTableViewCell" bundle:nil] forCellReuseIdentifier:@"PayInvoiceTableViewCell"];
    self.viewModel = [[TrainViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf.itemTableView.mj_header endRefreshing];
        [weakSelf.itemArr removeAllObjects];
        [weakSelf.itemArr addObjectsFromArray:returnValue];
        [weakSelf.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [weakSelf.itemTableView.mj_header endRefreshing];
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
    [self footerRefreshing];
}

/**
 上拉加载
 */
-(void)footerRefreshing{
    
    [self.viewModel fetchUserInvoiceWithInvoiceId:nil];
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
    
    PayInvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayInvoiceTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.f;
}


//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    InvoiceUpdateViewController *vc = [[InvoiceUpdateViewController alloc]init];
    vc.invoiceModel = self.itemArr[indexPath.row];
    [vc setReturnReloadBlock:^{
        [self headerRefreshing];
    }];
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
