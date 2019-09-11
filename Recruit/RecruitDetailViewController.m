//
//  RecruitDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/6/15.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "RecruitDetailViewController.h"
#import "RectuitViewModel.h"
#import "RecruitDetailModel.h"
#import "CompanyInfoViewController.h"
#import "CollectViewModel.h"
#import "RecruitTableViewCell.h"
#import "StartUpTableViewCell.h"
#import "TrainListTableViewCell.h"
#import "ActivityTableViewCell.h"
@interface RecruitDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *salaryLabel;
@property (weak, nonatomic) IBOutlet UIButton *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *eduLabel;
@property (weak, nonatomic) IBOutlet UIButton *workExpLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanyType;
@property (weak, nonatomic) IBOutlet UIButton *btnAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnQuality;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UIView *dutyView;
@property (weak, nonatomic) IBOutlet UIView *skillView;
@property (weak, nonatomic) IBOutlet UILabel *dutyLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomItemView;
@property (weak, nonatomic) IBOutlet UILabel *titleOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleTwoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleViewHeight;
@property (weak, nonatomic) IBOutlet UIView *companyView;
@property (weak, nonatomic) IBOutlet UIView *positionDescribeView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;



@property (nonatomic, retain) RectuitViewModel *viewModel;
@property (nonatomic, retain) RecruitDetailModel *jobModel;
@property (nonatomic, assign) CGFloat staticHeight;
@property (nonatomic, assign) CGFloat dutyHeight;
@property (nonatomic, assign) CGFloat skillHeight;

@property (nonatomic, strong) UITableView *itemTableView;
@end

@implementation RecruitDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnCollect.layer.borderWidth = 1;
    self.btnCollect.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.backgroundViewHeight.constant += ScreenHeight;
    self.staticHeight = self.backgroundViewHeight.constant;
    CGRect rectduty = self.dutyView.frame;
    self.dutyHeight = rectduty.size.height;
    CGRect rectSkill = self.skillView.frame;
    self.skillHeight = rectSkill.size.height;
    self.viewModel = [[RectuitViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        
        weakSelf.jobModel = returnValue;
        [weakSelf.itemScrollView.mj_header endRefreshing];
        if ([self.isFull integerValue] == 1) {
            [weakSelf reloadFullView];
        }else{
            [weakSelf reloadPartView];
        }
        
    } WithErrorBlock:^(id errorCode) {
        [weakSelf.itemScrollView.mj_header endRefreshing];
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self setupRefresh];
    
        NSDictionary *userinfo = [UserDefaults readUserDefaultObjectValueForKey:user_info];
        UserModel *userModel = [[UserModel alloc] initWithDict:userinfo];
        if ([userModel.type integerValue] == 3) {
            self.btnApply.enabled = NO;
            self.btnApply.backgroundColor = [UIColor colorWithHexString:@"bbbbbb"];
        }
    if (self.type == 1) {
        self.bottomItemView.hidden = YES;
    }
    self.itemTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.companyView.frame.origin.y + self.companyImageView.frame.size.height, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.itemTableView.delegate = self;
    self.itemTableView.dataSource = self;
    [self.itemTableView registerNib:[UINib nibWithNibName:@"RecruitTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecruitTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"TrainListTableViewCell" bundle:nil] forCellReuseIdentifier:@"TrainListTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ActivityTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActivityTableViewCell"];

    [self.backgroundView addSubview:self.itemTableView];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)reloadFullView{
    
    self.jobNameLabel.text = self.jobModel.position;
    if ([self.jobModel.salary integerValue]) {
        self.salaryLabel.text = [NSString stringWithFormat:@"%@",self.jobModel.salary];
    }else{
        self.salaryLabel.text = [NSString stringWithFormat:@"%@",self.jobModel.salary];
    }
    if ([self.jobModel.is_collect integerValue] == 1) {
        self.btnCollect.selected = YES;
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
    }
    //-3-未申请 -2-放弃培训 -1 未通过 0-已申请（等待面试） 1-是否培训 2-培训中 3-已完成（通过）
    if ([self.jobModel.status integerValue] == 1) {
        [self.btnApply setTitle:@"是否培训" forState:UIControlStateNormal];
    }
    NSArray *array = [self.jobModel.welfare componentsSeparatedByString:@";"];
    UIView *view = [[UIView alloc] init];
    CGFloat X = 0;
    CGFloat Y = 0;
    for (int i = 0; i < array.count; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = array[i];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"f26f05"];
        CGSize size = [array[i] sizeWithFont:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(ScreenWidth-20, 100)];
        label.frame = CGRectMake(X, Y, size.width + 5, 20);
        X += size.width + 10;
        if (X > ScreenWidth-20) {
            if (i == 0) {
                X = 0;
                label.frame = CGRectMake(X, Y, size.width + 5, 20);
                Y += 25;
                X += size.width + 10;
            }else{
                X = 0;
                Y += 25;
                label.frame = CGRectMake(X, Y, size.width + 5, 20);
                X += size.width + 10;
            }
        }
        label.layer.borderColor = [UIColor colorWithHexString:@"f26f05"].CGColor;
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = 2.f;
        label.layer.masksToBounds = YES;
        [view addSubview:label];
    }
    view.frame = CGRectMake(10, 60, ScreenWidth - 20, Y + 25);
    [self.topView addSubview:view];
    if (array.count > 0) {
        self.topViewHeight.constant = 83 + Y;
    }
//    [self.amountLabel setTitle:[NSString stringWithFormat:@"%@人",self.jobModel.type] forState:UIControlStateNormal];
    CGRect rectedu = self.eduLabel.frame;
    CGRect rectwork = self.workExpLabel.frame;
    rectedu.origin.x = 10;
    rectwork.origin.x = rectedu.origin.x + rectedu.size.width + 10;
    self.eduLabel.frame = rectedu;
    self.workExpLabel.frame = rectwork;
    self.amountLabel.hidden = YES;
    [self.eduLabel setTitle:self.jobModel.schooling forState:UIControlStateNormal];
    [self.workExpLabel setTitle:self.jobModel.working_year forState:UIControlStateNormal];
    self.companyNameLabel.text = self.jobModel.company.company_name;
    [self.btnCompanyType setTitle:self.jobModel.company.company_type forState:UIControlStateNormal];
    
    
    self.addressLabel.text = [NSString stringWithFormat:@"公司地址：%@",self.jobModel.company.company_address];
    [self.btnAmount setTitle:self.jobModel.company.company_scale forState:UIControlStateNormal];
    [self.btnQuality setTitle:self.jobModel.company.company_industry forState:UIControlStateNormal];
    self.dutyLabel.text = self.jobModel.responsibilities;
    self.dutyLabel.numberOfLines = 0;
    CGSize size = [self.dutyLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    CGRect rect = self.dutyLabel.frame;
    rect.size.height = size.height;
    self.dutyLabel.frame = rect;
    CGRect rectduty = self.dutyView.frame;
    rectduty.size.height = self.dutyHeight + size.height;
    self.dutyView.frame = rectduty;
    
    self.skillLabel.text = self.jobModel.requirements;
    self.skillLabel.numberOfLines = 0;
    CGSize skillSize = [self.skillLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    CGRect rect1 = self.skillLabel.frame;
    rect1.size.height = skillSize.height;
    self.skillLabel.frame = rect1;
    CGRect rectSkill = self.skillView.frame;
    rectSkill.origin.y = rectduty.size.height + rectduty.origin.y + 10;
    rectSkill.size.height = self.skillHeight + skillSize.height;
    self.skillView.frame = rectSkill;
    
    CGFloat height = 0;
    if (self.jobModel.company.company_image.count > 0) {
        [self.companyImageView setImageWithString:self.jobModel.company.company_image[0] placeHoldImageName:@""];
        height = 165;
        self.middleViewHeight.constant = 275;
    }
    if (self.jobModel.company.company_desc.length > 0) {
        self.descLabel.text = [NSString stringWithFormat:@"公司简介：%@",self.jobModel.company.company_desc];
        height += 30;
        self.middleViewHeight.constant = 300;
    }
    
    self.backgroundViewHeight.constant = self.staticHeight - 260 + size.height + skillSize.height + self.topViewHeight.constant - 58 + height;
}
-(void)reloadPartView{
    self.jobNameLabel.text = self.jobModel.title;
    if ([self.jobModel.salary integerValue]) {
        self.salaryLabel.text = [NSString stringWithFormat:@"%@元/天",self.jobModel.salary];
    }else{
        self.salaryLabel.text = [NSString stringWithFormat:@"%@",self.jobModel.salary];
    }
    if ([self.jobModel.is_collect integerValue] == 1) {
        self.btnCollect.selected = YES;
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
    }
    [self.eduLabel setTitle:[NSString stringWithFormat:@"%@",self.jobModel.pay_type] forState:UIControlStateNormal];
    [self.amountLabel setTitle:[NSString stringWithFormat:@"%@人",self.jobModel.num] forState:UIControlStateNormal];
    [self.workExpLabel setTitle:self.jobModel.type forState:UIControlStateNormal];
    self.companyNameLabel.text = self.jobModel.company.company_name;
    [self.btnCompanyType setTitle:self.jobModel.company.company_type forState:UIControlStateNormal];
    self.addressLabel.text = [NSString stringWithFormat:@"公司地址：%@",self.jobModel.company.company_address];
    [self.btnAmount setTitle:self.jobModel.company.company_scale forState:UIControlStateNormal];
    [self.btnQuality setTitle:self.jobModel.company.company_industry forState:UIControlStateNormal];
    self.dutyLabel.text = self.jobModel.region;
    self.dutyLabel.numberOfLines = 0;
    self.titleOneLabel.text = @"工作区域：";
    CGSize size = [self.dutyLabel.text sizeWithFont:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    CGRect rect = self.dutyLabel.frame;
    rect.size.height = size.height;
    self.dutyLabel.frame = rect;
    CGRect rectduty = self.dutyView.frame;
    rectduty.size.height = self.dutyHeight + size.height;
    self.dutyView.frame = rectduty;
    
    self.skillLabel.text = self.jobModel.content;
    self.titleTwoLabel.text = @"工作内容：";
    self.skillLabel.numberOfLines = 0;
    CGSize skillSize = [self.skillLabel.text sizeWithFont:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    CGRect rect1 = self.skillLabel.frame;
    rect1.size.height = skillSize.height;
    self.skillLabel.frame = rect1;
    CGRect rectSkill = self.skillView.frame;
    rectSkill.origin.y = rectduty.size.height + rectduty.origin.y + 10;
    rectSkill.size.height = self.skillHeight + skillSize.height;
    self.skillView.frame = rectSkill;
    
    CGFloat height = 0;
    if (self.jobModel.company.company_image.count > 0) {
        [self.companyImageView setImageWithString:self.jobModel.company.company_image[0] placeHoldImageName:@""];
        height = 165;
        self.middleViewHeight.constant = 105 + 170;
    }
    if (self.jobModel.company.company_desc.length > 0) {
        self.descLabel.text = [NSString stringWithFormat:@"公司简介：%@",self.jobModel.company.company_desc];
        height += 30;
        self.middleViewHeight.constant = 300;
    }
    
    self.backgroundViewHeight.constant = self.staticHeight - 260 + size.height + skillSize.height + height;
}

/**
 设置刷新
 */
-(void)setupRefresh{
    self.itemScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    [self.itemScrollView.mj_header beginRefreshing];
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
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)applyAction:(id)sender {
    if ([self.jobModel.status integerValue] == 1) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"是否培训"                                                                             message: @"该岗位需要具备对应技能，是否参加入岗培训"                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        //添加Button
        UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self goToTrainingWithStatus:2];
            
        }];
        //添加Button
        UIAlertAction *addAction = [UIAlertAction actionWithTitle: @"不参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self goToTrainingWithStatus:-2];
        }];
        
        UIAlertAction *cancelAction =  [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:nil];
        
        [cancelAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
        [okAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
        [addAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
        
        
        [alertController addAction:okAction];
        [alertController addAction:addAction];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated: YES completion: nil];
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
        if (status == 2) {
            [self showJGProgressWithMsg:@"提交成功,请等待审核通知"];
        }else{
//            [self showJGProgressWithMsg:@"提交成功"];
            [self.btnApply setTitle:@"放弃培训" forState:UIControlStateNormal];
        }
        
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel isEnrollHandleWithId:self.jobModel.Id status:status];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)collectAction:(id)sender {
    
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
- (IBAction)skipToCompanyInfo:(id)sender {
    CompanyInfoViewController *vc = [[CompanyInfoViewController alloc] init];
    vc.companyId = self.jobModel.company.Id;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        RecruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecruitTableViewCell"];
        return cell;
    }else if (indexPath.section == 1){
        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
        return cell;
    }else if (indexPath.section == 2){
        TrainListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrainListTableViewCell"];
        return cell;
    }
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 84.f;
    }else if (indexPath.section == 1){
        return 110.f;
    }else if (indexPath.section == 2){
        return 110.f;
    }
    return 128.f;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
