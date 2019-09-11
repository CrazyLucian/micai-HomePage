//
//  PolicyDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/6/6.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PolicyDetailViewController.h"
#import "DetailHeaderView.h"
#import "PolicyListTableViewCell.h"
#import "PolicyDetailTableViewCell.h"
#import "PolicyViewModel.h"
#import "PolicyModel.h"
#import "CollectViewModel.h"
@interface PolicyDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *policyScrollView;
@property (nonatomic, retain) UITableView *newsTableView;
@property (nonatomic, retain) DetailHeaderView *headerView;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *contentArr;
@property (nonatomic, retain) UIButton *btnCollect;
@end

@implementation PolicyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.policyScrollView.scrollEnabled = NO;
    self.itemArr = [[NSMutableArray alloc] init];
    self.contentArr = [[NSMutableArray alloc] init];
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"DetailHeaderView" owner:self options:nil] firstObject];
    self.headerView.frame = CGRectMake(0, 0, ScreenWidth, 180);
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, ScreenWidth, 100);
    topView.backgroundColor = [UIColor whiteColor];
//    [self.policyScrollView addSubview:topView];
    [self.headerView addSubview:topView];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:22];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.frame = CGRectMake(20, 10, ScreenWidth - 40, 60);
    label.adjustsFontSizeToFitWidth = YES;
    UIButton *btnClick = [[UIButton alloc] init];
    btnClick.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnClick setTitleColor:[UIColor colorWithHexString:@"787878"] forState:UIControlStateNormal];
    [btnClick setImage:[UIImage imageNamed:@"浏览图标拷贝"] forState:UIControlStateNormal];
    btnClick.frame = CGRectMake(10, 70, 50, 20);
    UIButton *btnTime = [[UIButton alloc] init];
    btnTime.frame = CGRectMake(70, 70, 90, 20);
    btnTime.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnTime setTitleColor:[UIColor colorWithHexString:@"787878"] forState:UIControlStateNormal];
    [btnTime setImage:[UIImage imageNamed:@"时间图标拷贝"] forState:UIControlStateNormal];
    self.btnCollect = [[UIButton alloc] init];
    self.btnCollect.frame = CGRectMake(170, 70, 80, 20);
    self.btnCollect.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.btnCollect setTitleColor:[UIColor colorWithHexString:@"787878"] forState:UIControlStateNormal];
    [self.btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
    [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
    [self.btnCollect setImage:[UIImage imageNamed:@"收藏(1)"] forState:UIControlStateNormal];
    [self.btnCollect setImage:[UIImage imageNamed:@"图层392"] forState:UIControlStateSelected];
    [self.btnCollect setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
    [self.btnCollect addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:label];
    [topView addSubview:btnClick];
    [topView addSubview:btnTime];
    [topView addSubview:self.btnCollect];

    CGFloat Y = 64;
    if (kDevice_Is_iPhoneX) {
        Y = 88;
    }
    self.newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - Y) style:UITableViewStyleGrouped];
    self.newsTableView.tableHeaderView = self.headerView;
    self.newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    [self.newsTableView registerNib:[UINib nibWithNibName:@"PolicyListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PolicyListTableViewCell"];
    [self.newsTableView registerNib:[UINib nibWithNibName:@"PolicyDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"PolicyDetailTableViewCell"];
    
    [self.policyScrollView addSubview:self.newsTableView];
    self.policyScrollView.contentSize = CGSizeMake(ScreenWidth, 100 + self.newsTableView.frame.size.height);
    PolicyViewModel *viewModel = [[PolicyViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        PolicyModel *model = returnValue;
        [self.contentArr addObjectsFromArray:model.children];
        [self.headerView initViewWithModel:model];
        label.text = model.title;
        [btnClick setTitle:[NSString stringWithFormat:@"%@",model.click] forState:UIControlStateNormal];
        [btnClick setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
        [btnTime setTitle:[NSString stringWithFormat:@"%@",model.add_time] forState:UIControlStateNormal];
        [btnTime setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
        if (model.document_number.length > 0) {
            CGSize size = [model.add_time sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(ScreenWidth - 160, 20)];
            CGRect rect = btnTime.frame;
            rect.size.width = size.width + 20;
            btnTime.frame = rect;
            CGRect rectCollect = self.btnCollect.frame;
            rectCollect.origin.x = rect.origin.x + rect.size.width + 10;
            self.btnCollect.frame = rectCollect;
        }else{
            CGSize size = [model.document_number sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(ScreenWidth - 160, 20)];
            CGRect rect = btnTime.frame;
            rect.size.width = size.width;
            btnTime.frame = rect;
            btnTime.hidden = YES;
            CGRect rectCollect = self.btnCollect.frame;
            rectCollect.origin.x = rect.origin.x + rect.size.width + 10;
            self.btnCollect.frame = rectCollect;
        }
        
        
        if ([model.is_collect integerValue] == 1) {
            self.btnCollect.selected = YES;
        }
        [self.newsTableView reloadData];

    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    
    PolicyViewModel *reViewModel = [[PolicyViewModel alloc] init];
    [reViewModel setBlockWithReturnBlock:^(id returnValue) {
        [viewModel fetchPolicyDetailWithId:self.policyId type:self.type];
        [self.itemArr addObjectsFromArray:returnValue];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.newsTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [reViewModel fetchHotPolicy];
    self.newsTableView.estimatedRowHeight = 300.f;
    self.newsTableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view from its nib.
}
//当前页面不在导航控制器中，需重写preferredStatusBarStyle，如下：

-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent; //白色
    
    //    return UIStatusBarStyleDefault; //黑色
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    NSDictionary *userinfo = [UserDefaults readUserDefaultObjectValueForKey:user_info];
    UserModel *userModel = [[UserModel alloc] initWithDict:userinfo];
    NSString *shareUrl = [NSString stringWithFormat:@"http://dl.micaiwang.cn/wx/user/register/user_id/%@.html",userModel.Id];
    [self shareWithPageUrl:shareUrl shareTitle:@"迷彩网" shareDes:@"新迷彩、新生活" thumImage:@"http://dl.micaiwang.cn/public/images/app_logo_s.png" shareType:0];
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
-(void)collectAction{
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    if (self.btnCollect.selected == NO) {
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self showJGProgressWithMsg:@"收藏成功"];
            [self dissJGProgressLoadingWithTag:200];
            self.btnCollect.selected = YES;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel collectWithId:self.policyId type:@(1)];
        [self dissJGProgressLoadingWithTag:200];
    }else{
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self showJGProgressWithMsg:@"已取消收藏"];
            [self dissJGProgressLoadingWithTag:200];
            self.btnCollect.selected = NO;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel cancelCollectWithId:self.policyId type:@(1)];
        [self dissJGProgressLoadingWithTag:200];
    }
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.contentArr.count;
    }
    return self.itemArr.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        PolicyDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PolicyDetailTableViewCell"];
        [cell setCollectBlock:^(NSInteger type) {
            [self reloadViewActionWithRow:indexPath.row];
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell initCellWithModel:self.contentArr[indexPath.row]];
        
        return cell;
    }
    PolicyModel *model = self.itemArr[indexPath.row];
    
        PolicyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PolicyListTableViewCell"];
    [cell initCellWithModel:model];
    return cell;
    

}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [PolicyDetailTableViewCell getCellHeightForModel:self.contentArr[indexPath.row]];
    }
    return 85.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0001f;
    }
    return 30.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    if (section == 1) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(10, 5, 100, 20);
        [button setTitle:@"热门点击" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"图层401拷贝"] forState:UIControlStateNormal];
        [button setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [view addSubview:button];
        view.backgroundColor = [UIColor whiteColor];
    }
    
    
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        PolicyDetailViewController *vc = [[PolicyDetailViewController alloc]init];
        PolicyModel *model = self.itemArr[indexPath.row];
        vc.policyId = model.article_id;
        if ([model.parent_id integerValue] == 0) {
            vc.type = 0;
        }else{
            vc.type = @(1);
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//tableview 加载完成可以调用的方法--因为tableview的cell高度不定，所以在加载完成以后重新计算高度
//-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == ((NSIndexPath*)[[tableView indexPathsForVisibleRows]lastObject]).row){
//        //end of loading
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (indexPath.section == 0) {
//
//            }
//
//            self.newsTableView.frame = CGRectMake(self.newsTableView.frame.origin.x,self.newsTableView.frame.origin.y,ScreenWidth, tableView.contentSize.height);
////            CGRect rect1 = self.newsTableView.frame;
////            self.policyScrollView.contentSize = CGSizeMake(ScreenWidth, rect1.size.height + rect1.origin.y);
//        });
//    }
//}

-(void)reloadViewActionWithRow:(NSInteger)row{
    PolicyViewModel *viewModel = [[PolicyViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        PolicyModel *model = returnValue;
        [self.contentArr removeAllObjects];
        [self.contentArr addObjectsFromArray:model.children];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchPolicyDetailWithId:self.policyId type:self.type];
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
