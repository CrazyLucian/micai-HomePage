//
//  SearchStartUpViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "SearchStartUpViewController.h"
#import "StartUpDetailViewController.h"
#import "StartStarDetailViewController.h"
#import "StartUpTableViewCell.h"
#import "StartUpStarTableViewCell.h"
#import "StartUpViewModel.h"
@interface SearchStartUpViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@property (nonatomic, retain) StartUpViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation SearchStartUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    self.viewModel = [[StartUpViewModel alloc] init];
    
    self.txtSearch.text = self.searchKey;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.txtSearch];
    
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpStarTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpStarTableViewCell"];
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
    if (self.txtSearch.text.length != 0) {
        if (self.titleIndex == 0) {
            [self.viewModel fetchStartUpListWithIndustry:nil money:nil region:nil hotindustry:nil keywords:self.txtSearch.text page:@(self.pageIndex)];
        }else{
            [self.viewModel fetchStartHelpWithIndustry:nil money:nil region:nil hotindustry:nil keywords:self.txtSearch.text page:@(self.pageIndex) cat_id:@(1)];
        }
    }
    
    
}
 
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.titleIndex == 0) {
        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
        [cell initCellWithModel:self.itemArr[indexPath.row]];
        return cell;
    }
    StartUpStarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpStarTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
    
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 110.f;
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.titleIndex == 0) {
        StartUpDetailViewController *vc = [[StartUpDetailViewController alloc]init];
        StartUpModel *model = self.itemArr[indexPath.row];
        vc.Id = model.Id;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
        StartUpModel *model = self.itemArr[indexPath.row];
        vc.Id = model.Id;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *inputTextView = (UITextField *)obj.object;
    NSString *toBeString = inputTextView.text;

    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [inputTextView markedTextRange];       //获取高亮部分
        UITextPosition *position = [inputTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 1600) {
                inputTextView.text = [toBeString substringToIndex:1600];
            }else{

            }
            
        }       // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length >= 1600) {
            inputTextView.text = [toBeString substringToIndex:1600];

        }
    }
    [self headerRefreshing];
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
