//
//  RecruitSearchViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/29.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "RecruitSearchViewController.h"
#import "RecruitSearchTableViewCell.h"
#import "RectuitViewModel.h"
@interface RecruitSearchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, retain) NSMutableArray *hotArr;
@property (nonatomic, retain) NSMutableArray *visitArr;
@end

@implementation RecruitSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hotArr = [[NSMutableArray alloc] init];
    self.visitArr = [[NSMutableArray alloc] init];
    self.txtSearch.placeholder = @"输入您想应聘的职位信息";
    [self.searchTableView registerNib:[UINib nibWithNibName:@"RecruitSearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecruitSearchTableViewCell"];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self.hotArr addObjectsFromArray:returnValue[0]];
        [self.visitArr addObjectsFromArray:returnValue[1]];
        [self.searchTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchHotKeywords];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)searchAction:(id)sender {
    self.returnSearchBlock(self.txtSearch.text);
    [self backAction:nil];
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecruitSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecruitSearchTableViewCell"];
    if (indexPath.section == 0) {
        [cell initCellWithArray:self.visitArr];
    }else{
        [cell initCellWithArray:self.hotArr];
    }
    [cell setReturnItemBlock:^(NSString *key) {
        self.returnSearchBlock(key);
        [self backAction:nil];
    }];
    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    return footView;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 100, 16)];
    switch (section) {
        case 0:
            titleLabel.text = @"最近浏览";
            break;
        case 1:
            titleLabel.text = @"热门职位";
            break;
        default:
            break;
            
    }
    titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [headView addSubview:titleLabel];
    
    return headView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
