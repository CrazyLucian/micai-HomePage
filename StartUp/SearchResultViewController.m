//
//  SearchResultViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/8/13.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "SearchResultViewController.h"
#import "StartUpDetailViewController.h"
#import "StartStarDetailViewController.h"
#import "SearchStartUpViewController.h"
#import "LabelSearchViewController.h"
#import "StartUpTableViewCell.h"
#import "StartUpStarTableViewCell.h"
#import "StartHelpTableViewCell.h"
#import "StartUpViewModel.h"
#import "SingleChooseListView.h"
#import "ProvinceCityZoneView.h"
@interface SearchResultViewController ()

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view from its nib.
}
//
///**
// 设置刷新
// */
//-(void)setupRefresh{
//    self.itemTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
//    [self.itemTableView.mj_header beginRefreshing];
//}
//
///**
// 下拉刷新
// */
//-(void)headerRefreshing{
//    self.pageIndex = 0;
//    [self footerRefreshing];
//}
//
///**
// 上拉加载
// */
//-(void)footerRefreshing{
//    ++ self.pageIndex;
//    if (self.titleIndex == 0) {
//        [self.viewModel fetchStartUpListWithIndustry:self.industryStr money:self.amountStr region:self.areaStr hotindustry:self.hotStr keywords:self.searchKey page:@(self.pageIndex)];
//
//    }else if (self.titleIndex == 1){
//        [self.viewModel fetchStartHelpWithKeywords:self.searchKey page:@(self.pageIndex)];
//    }else{
//        [self.viewModel fetchStartStarWithKeywords:nil page:@(self.pageIndex)];
//
//    }
//
//}
//#pragma mark - UITableViewDataSource
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.itemArr.count;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.reloadIndex == 0) {
//        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
//        [cell initCellWithModel:self.itemArr[indexPath.row]];
//        return cell;
//    }else if(self.reloadIndex == 1){
//        StartHelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartHelpTableViewCell"];
//        [cell initCellWithModel:self.itemArr[indexPath.row]];
//        return cell;
//    }
//    StartUpStarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpStarTableViewCell"];
//    [cell initCellWithModel:self.itemArr[indexPath.row]];
//    return cell;
//
//}
//#pragma mark - UITableViewDelegate
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.reloadIndex == 1) {
//        return 305.f;
//    }
//    return 110.f;
//}
//
////选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (self.reloadIndex == 0) {
//        StartUpDetailViewController *vc = [[StartUpDetailViewController alloc]init];
//        StartUpModel *model = self.itemArr[indexPath.row];
//        vc.Id = model.Id;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else if (self.reloadIndex == 1){
//        StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
//        StartStarModel *model = self.itemArr[indexPath.row];
//        vc.type = @(1);
//        vc.Id = model.Id;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
//        StartStarModel *model = self.itemArr[indexPath.row];
//        vc.type = 0;
//        vc.Id = model.Id;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
