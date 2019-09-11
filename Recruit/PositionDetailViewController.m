//
//  PositionDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/2.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "PositionDetailViewController.h"
#import "CompanyProductViewController.h"
#import "ActivityDetailViewController.h"
#import "SupportProductViewController.h"
#import "StartUpDetailViewController.h"
#import "CompanyInfoModel.h"
#import "CompanyViewModel.h"
#import "PositionTableViewCell.h"
#import "PositionInfoTableViewCell.h"
#import "CompanyIntroduceTableViewCell.h"
#import "RectuitViewModel.h"
#import "RecruitDetailModel.h"
#import "CompanyInfoViewController.h"
#import "CollectViewModel.h"
#import "RecruitTableViewCell.h"
#import "StartUpTableViewCell.h"
#import "ArmyProductTableViewCell.h"
#import "ActivityTableViewCell.h"
@interface PositionDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
@property (weak, nonatomic) IBOutlet UIView *trainView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;


@property (nonatomic, retain) RectuitViewModel *viewModel;
@property (nonatomic, retain) RecruitDetailModel *jobModel;
@property (nonatomic, retain) CompanyInfoModel *infoModel;
@property (nonatomic, assign) CGFloat staticHeight;
@property (nonatomic, assign) CGFloat dutyHeight;
@property (nonatomic, assign) CGFloat skillHeight;

@end

@implementation PositionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"PositionTableViewCell" bundle:nil] forCellReuseIdentifier:@"PositionTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"PositionInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"PositionInfoTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"CompanyIntroduceTableViewCell" bundle:nil] forCellReuseIdentifier:@"CompanyIntroduceTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"RecruitTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecruitTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ArmyProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArmyProductTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ActivityTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActivityTableViewCell"];

    CompanyViewModel *viewModel = [[CompanyViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        self.infoModel = returnValue;
        [self.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchCompanyRelateInfomationWithId:@(15)];
    
    NSDictionary *userinfo = [UserDefaults readUserDefaultObjectValueForKey:user_info];
    UserModel *userModel = [[UserModel alloc] initWithDict:userinfo];
    if ([userModel.type integerValue] == 3) {
        self.btnApply.enabled = NO;
        self.btnApply.backgroundColor = [UIColor colorWithHexString:@"bbbbbb"];
    }
    
    self.viewModel = [[RectuitViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        
        weakSelf.jobModel = returnValue;
        [weakSelf.itemTableView.mj_header endRefreshing];
        [weakSelf.itemTableView reloadData];
        if ([self.isFull integerValue] == 1) {
            [weakSelf reloadbottomView];
//            [weakSelf reloadFullView];
        }else{
//            [weakSelf reloadPartView];
        }
        
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
    
    [self.viewModel fetchRecruitDetailWithId:self.jobId type:self.isFull];
    
}
-(void)reloadbottomView{
    if ([self.jobModel.status integerValue] == 1) {
        self.trainView.hidden = NO;
    }else{
        self.trainView.hidden = YES;
        //-3-未申请 -2-放弃培训 -1 未通过 0-已申请（等待面试） 1-是否培训 2-培训中 3-已完成（通过）
        switch ([self.jobModel.status integerValue]) {
            case -1:
                self.statusView.hidden = NO;
                self.statusLabel.text = @"未通过面试，不予录用";
                break;
            case 0:
                self.statusView.hidden = NO;
                self.statusLabel.text = @"已申请，请等待面试通知";
                break;
            case 2:
                self.statusView.hidden = NO;
                self.statusLabel.text = @"等待分配培训机构";
                break;
            case 3:
                self.statusView.hidden = NO;
                self.statusLabel.text = @"培训中";
            case 4:
                self.statusView.hidden = NO;
                self.statusLabel.text = @"您已通过入职流程，已入职";
                break;
            default:
                self.statusView.hidden = YES;
                break;
        }
    }
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)collectionAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    if (self.btnCollect.selected == NO) {
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:@"收藏成功"];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            self.btnCollect.selected = YES;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel collectWithId:self.jobId type:@(5)];
        [self showJGProgressLoadingWithTag:200];
    }else{
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self showJGProgressWithMsg:@"已取消收藏"];
            [self dissJGProgressLoadingWithTag:200];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
            self.btnCollect.selected = NO;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel cancelCollectWithId:self.jobId type:@(5)];
        [self showJGProgressLoadingWithTag:200];
    }
}
- (IBAction)applyAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    if ([self.isFull integerValue] == 1) {
        
//        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"是否培训"                                                                             message: @"该岗位需要具备对应技能，是否参加入岗培训"                                                                           preferredStyle:UIAlertControllerStyleAlert];
//
//        //添加Button
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self goToTrainingWithStatus:2];
//
//        }];
//        //添加Button
//        UIAlertAction *addAction = [UIAlertAction actionWithTitle: @"不参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self goToTrainingWithStatus:-2];
//        }];
//
//        UIAlertAction *cancelAction =  [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:nil];
//
//        [cancelAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
//        [okAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
//        [addAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
//
//
//        [alertController addAction:okAction];
//        [alertController addAction:addAction];
//        [alertController addAction:cancelAction];
//        [self presentViewController: alertController animated: YES completion: nil];
    }else{
        RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:@"申请成功"];
        
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel applyJobsWithIdArr:@[self.jobId]];
        [self showJGProgressLoadingWithTag:200];
    }
    
    
}
-(void)goToTrainingWithStatus:(NSInteger)status{
    
    RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        [self headerRefreshing];
        [self showAlertMessage];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel applyJobsWithIdArr:@[self.jobId]];
    [self showJGProgressLoadingWithTag:200];
}
-(void)showAlertMessage{
   
    
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"提示"                                                                             message: @""                                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    //修改message
    NSString *alertMessage = @"";
    if (self.jobModel.requirements) {
        alertMessage = [alertMessage stringByAppendingString:[NSString stringWithFormat:@"一、相关技能需求：\n%@\n\n二、请等待面试邀请\n\n三、如面试通过后需要培训，请按照系统提示进行下一步操作",self.jobModel.requirements]];
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:alertMessage];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"555555"] range:NSMakeRange(0, alertMessage.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, alertMessage.length)];
        [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        
        UIView *subView1 = alertController.view.subviews[0];
        UIView *subView2 = subView1.subviews[0];
        UIView *subView3 = subView2.subviews[0];
        UIView *subView4 = subView3.subviews[0];
        UIView *subView5 = subView4.subviews[0];
        NSLog(@"%@",subView5.subviews);
        //取title和message：
        
        UILabel *message = subView5.subviews[2];
        message.textAlignment = NSTextAlignmentLeft;
    }
    
    
    
    //添加Button
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
    }];
    
    [okAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
    
    [alertController addAction:okAction];
    [self presentViewController: alertController animated: YES completion: nil];
}
- (IBAction)resignTraining:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self headerRefreshing];
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:@"提交成功"];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel isEnrollHandleWithId:self.jobId status:-2];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)joinTraining:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self headerRefreshing];
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:@"提交成功"];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel isEnrollHandleWithId:self.jobId status:2];
    [self showJGProgressLoadingWithTag:200];
}



#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < 3) {
        if (section == 1) {
            return 2;
        }
        return 1;
    }
    if (section == 3) {
        return self.infoModel.recruitment_list.count > 3 ? 3 : self.infoModel.recruitment_list.count;
    }
    if (section == 4) {
        return self.infoModel.investment_list.count > 3 ? 3 : self.infoModel.investment_list.count;
    }
    if (section == 5) {
        return self.infoModel.goods_list.count > 3 ? 3 : self.infoModel.goods_list.count;
    }
    
    return self.infoModel.activity_list.count > 3 ? 3 : self.infoModel.activity_list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if (indexPath.section == 0) {
        PositionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PositionTableViewCell"];
        [cell initCellWithModel:self.jobModel];
        return cell;
    }else if (indexPath.section == 1){
        PositionInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PositionInfoTableViewCell"];
        if (indexPath.row == 0) {
            [cell initCellWithModel:self.jobModel isSkill:1 isFull:self.isFull];
        }else{
            [cell initCellWithModel:self.jobModel isSkill:0 isFull:self.isFull];
        }
        
        return cell;
    }else if (indexPath.section == 2){
        CompanyIntroduceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanyIntroduceTableViewCell"];
        [cell initCellWithModel:self.jobModel];
        return cell;
    }if (indexPath.section == 3){
        RecruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecruitTableViewCell"];
        [cell initCellWithModel:self.infoModel.recruitment_list[indexPath.row] isHide:1];
        return cell;
    }else if (indexPath.section == 4){
        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
        [cell initCellWithModel:self.infoModel.investment_list[indexPath.row]];
        return cell;
    }else if (indexPath.section == 5){
        ArmyProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArmyProductTableViewCell"];
        [cell initCellWithModel:self.infoModel.goods_list[indexPath.row]];
        return cell;
    }
    
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];
    [cell initCellWithModel:self.infoModel.activity_list[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [PositionTableViewCell getCellHeightWithModel:self.jobModel];
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            return [PositionInfoTableViewCell getCellHeightWithModel:self.jobModel isSkill:1 isFull:self.isFull];
        }
        return [PositionInfoTableViewCell getCellHeightWithModel:self.jobModel isSkill:0 isFull:self.isFull];
    }else if (indexPath.section == 2){
        return [CompanyIntroduceTableViewCell getCellWithModel:self.jobModel];
    }else if (indexPath.section == 3){
        return 84.f;
    }else if (indexPath.section == 4){
        return 110.f;
    }else if (indexPath.section == 5){
        return 128.f;
    }
    return 128.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section < 3) {
        return 10.f;
    }
    return 40.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < 3) {
        if (section == 1) {
            return 40.f;
        }
        return 0.0001f;
    }
    return 40.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 20)];
        label.text = @"职位描述";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithHexString:@"333333"];
        [view addSubview:label];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, ScreenWidth - 20, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
        [view addSubview:lineLabel];
    }
    if (section > 2) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
        switch (section) {
            case 3:
                label.text = @"热门职位";
                break;
            case 4:
                label.text = @"创业项目";
                break;
            case 5:
                label.text = @"拥军产品";
                break;
            case 6:
                label.text = @"拥军活动";
                break;
                
            default:
                break;
        }
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHexString:@"f26f05"];
        [view addSubview:label];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, ScreenWidth - 20, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
        [view addSubview:lineLabel];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (section > 2) {
        UIButton *bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        [bottomBtn setTitle:@"点击查看更多 >" forState:UIControlStateNormal];
        bottomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        bottomBtn.tag = section + 999;
        [bottomBtn addTarget:self action:@selector(skipToProduct:)
            forControlEvents:UIControlEventTouchUpInside];
        
        bottomBtn.backgroundColor = [UIColor colorWithHexString:@"5d873b"];
        [bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addSubview:bottomBtn];
        view.backgroundColor = [UIColor whiteColor];
    }
    view.backgroundColor = [UIColor whiteColor];
    if (section < 3) {
        view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    }
    return view;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 3:
        {
            PositionDetailViewController *vc = [[PositionDetailViewController alloc] init];
            RecruitModel *model = self.infoModel.recruitment_list[indexPath.row];
            vc.jobId = model.Id;
            vc.isFull = @(1);
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 4:
        {
            
            StartUpDetailViewController *vc = [[StartUpDetailViewController alloc] init];
            StartUpModel *model = self.infoModel.investment_list[indexPath.row];
            vc.Id = model.Id;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            SupportProductViewController *vc = [[SupportProductViewController alloc] init];
            GoodsModel *model = self.infoModel.goods_list[indexPath.row];
            vc.goodsId = model.goods_id;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {
            ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
            ActivityModel *model = self.infoModel.activity_list[indexPath.row];
            vc.acticityId = model.activity_id;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            
        default:
            break;
    }
    
}
-(void)skipToProduct:(UIButton *)button{
    CompanyProductViewController *vc = [[CompanyProductViewController alloc] init];
    vc.type = button.tag - 999 - 2;
    switch (button.tag - 999 - 2) {
        case 0:
            vc.dataArr = self.infoModel.recruitment_list;
            break;
        case 1:
            vc.dataArr = self.infoModel.investment_list;
            break;
        case 2:
            vc.dataArr = self.infoModel.goods_list;
            break;
        case 3:
            vc.dataArr = self.infoModel.activity_list;
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
