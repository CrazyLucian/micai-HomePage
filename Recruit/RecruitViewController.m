//
//  RecruitViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/29.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "RecruitViewController.h"
#import "RecruitSearchViewController.h"
#import "RecruitDetailViewController.h"
#import "PositionDetailViewController.h"
#import "ChooseCityViewController.h"
#import "UserResumeViewController.h"
#import "RecruitTableViewCell.h"
#import "MoreScreenView.h"
#import "AreaScreenView.h"
#import "SingleChooseListView.h"
#import "ProvinceCityZoneView.h"
#import "RectuitViewModel.h"
#import "CollectViewModel.h"
#import "CompanyViewModel.h"
@interface RecruitViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnMoney;
@property (weak, nonatomic) IBOutlet UIButton *btnAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnAllSelect;
@property (nonatomic, retain) NSMutableArray *deleteArr;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) RectuitViewModel *viewModel;
@property (nonatomic, retain) CompanyViewModel *comViewModel;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger currentPriceIndex;
@property (nonatomic, assign) NSInteger currentTypeIndex;
@property (nonatomic, copy) NSString *choosedStr;
@property (nonatomic, copy) NSString *searchKey;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, assign) NSInteger type;//0地区 1薪资 2other
@property (nonatomic, copy) NSString *cityStr;
@property (nonatomic, assign) NSInteger provinceIndex;
@property (nonatomic, assign) NSInteger cityIndex;
@property (nonatomic, assign) NSInteger zoneIndex;
@property (nonatomic, retain) NSMutableArray *typeArr;
@end

@implementation RecruitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deleteArr = [[NSMutableArray alloc] init];
    self.dataArray = [[NSMutableArray alloc] init];
    self.typeArr = [[NSMutableArray alloc] init];
    
    NSString *str = [UserDefaults readUserDefaultObjectValueForKey:location_city];
    self.type = 1;
    self.cityStr = str ? str : @"全国";
    self.region = str ? str :@"";
    
    [self.btnAddress setTitle:self.cityStr forState:UIControlStateNormal];
    
    self.provinceIndex = 0;
    self.cityIndex = 0;
    self.zoneIndex = 0;
    
    [self.btnAddress setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnMoney setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnMore setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    self.btnApply.layer.masksToBounds = YES;
    self.btnApply.layer.cornerRadius = 4.f;
    self.btnCollect.layer.borderWidth = 1;
    self.btnCollect.layer.borderColor = [UIColor colorWithHexString:@"bbbbbb"].CGColor;
    
//    self.itemTableView.allowsMultipleSelectionDuringEditing = YES;
//    self.itemTableView.editing = YES;
    [self.itemTableView registerNib:[UINib nibWithNibName:@"RecruitTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecruitTableViewCell"];
    __weak typeof(self)weakSelf = self;
    self.comViewModel = [[CompanyViewModel alloc] init];
    [self.comViewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf.typeArr addObjectsFromArray:returnValue];
    } WithErrorBlock:^(id errorCode) {
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self.view endEditing:YES];
    
    self.viewModel = [[RectuitViewModel alloc] init];
    
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        if (self.pageIndex == 1) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.itemTableView.mj_header endRefreshing];
        }else{
            [weakSelf.itemTableView.mj_footer endRefreshing];
        }
        if ([(NSArray *)returnValue count] < 10) {
            [weakSelf.itemTableView.mj_footer removeFromSuperview];
        }else{
            weakSelf.itemTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(footerRefreshing)];
        }
        [weakSelf.dataArray addObjectsFromArray:returnValue];
        weakSelf.amountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)weakSelf.deleteArr.count,(long)weakSelf.dataArray.count];
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
    ++ self.pageIndex;
    if (self.type == 0) {
        [self.viewModel fetchRecruitmentListWithType:@(1) page:@(self.pageIndex)];
    }else if (self.type == 1){

        if (self.currentPriceIndex == 0 && self.position.length == 0 && self.region.length == 0) {
            [self.viewModel fetchRecruitmentListWithType:@(1) page:@(self.pageIndex)];
        }else{
            [self.viewModel searchJobsWithSalary:self.money position:self.position region:self.region page:@(self.pageIndex)];
        }
    }else{
        if (self.searchKey.length == 0) {
            [self.viewModel fetchRecruitmentListWithType:@(1) page:@(self.pageIndex)];
        }else{
            [self.viewModel searchJobsWithKey:self.searchKey];
        }
        
    }
    if (self.typeArr.count == 0) {
        
        [self.comViewModel fetchCompanyAboutInfo:7];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)skipToSearch:(id)sender {
    RecruitSearchViewController *vc = [[RecruitSearchViewController alloc] init];
    [vc setReturnSearchBlock:^(NSString *key) {
        
//        [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
//            [self.dataArray removeAllObjects];
//            [self.dataArray addObjectsFromArray:returnValue];
//            [self.itemTableView reloadData];
//        } WithErrorBlock:^(id errorCode) {
//            [self showJGProgressWithMsg:errorCode];
//        }];
        self.searchKey = key;
        self.type = 2;
        [self headerRefreshing];
        
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)chooseMore:(id)sender {
    self.btnMore.selected = YES;
    self.btnMoney.selected = NO;
    self.btnAddress.selected = NO;
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 997) {
            return;
        }
    }
//    MoreScreenView *screenView = [[[NSBundle mainBundle] loadNibNamed:@"MoreScreenView" owner:self options:nil] firstObject];
//    [screenView initCellWith];
//    UIView *backView = [[UIView alloc] init];
//    backView.tag = 801;
//    backView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y);
//    [backView addSubview:screenView];
//    [self.view addSubview:backView];
//    [screenView setCancelBlock:^{
//        [backView removeFromSuperview];
//    }];
    
    //    id baseData = [UserDefaults readUserDefaultObjectValueForKey:base_data];
    //    NSDictionary *dic = baseData[@"care"];
    NSMutableArray *positionArr = [[NSMutableArray alloc] init];
    [positionArr addObject:@{@"id":@0,@"name":@"全部"}];
    [positionArr addObjectsFromArray:self.typeArr];
        SingleChooseListView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"SingleChooseListView" owner:self options:nil] firstObject];
        chooseView.tag = 997;
        chooseView.currentSelectIndex = self.currentTypeIndex;
        chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
        chooseView.selectedBtnImgStr = @"icon_tick";
        chooseView.colorStr = @"f26f05";
        [chooseView initView:positionArr];
        [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
            self.currentTypeIndex = index;
            
            self.position = positionArr[index][@"name"];
            if (index == 0) {
                self.position = @"";
                [self.btnMore setTitle:@"职位筛选" forState:UIControlStateNormal];
                [self.btnMore setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateSelected];
                [self.btnMore setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
            }else{
                [self.btnMore setTitle:positionArr[index][@"name"] forState:UIControlStateNormal];
                [self.btnMore setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateSelected];
                [self.btnMore setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
            }
            self.type = 1;
            
            [self.btnMore setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
            [self headerRefreshing];
        }];
        [chooseView setRemoveBlock:^{
            //        self.priceBtn.selected = NO;
        }];
        [self.view addSubview:chooseView];
    

}
- (IBAction)chooseMoney:(id)sender {
    self.btnMore.selected = NO;
    self.btnMoney.selected = YES;
    self.btnAddress.selected = NO;
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 998) {
            return;
        }
    }
    
    SingleChooseListView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"SingleChooseListView" owner:self options:nil] firstObject];
    chooseView.tag = 998;
    chooseView.currentSelectIndex = self.currentPriceIndex;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    chooseView.selectedBtnImgStr = @"icon_tick";
    chooseView.colorStr = @"f26f05";
    //    id baseData = [UserDefaults readUserDefaultObjectValueForKey:base_data];
    //    NSDictionary *dic = baseData[@"care"];
    NSArray *priceArr = @[@{@"type":@"不限"}, @{@"type":@"1-3k"},@{@"type":@"3-5k"},@{@"type":@"5-8k"},@{@"type":@"8k以上"}];
    [chooseView initView:priceArr];
    [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
        self.currentPriceIndex = index;
        self.type = 1;
        if (index == 0) {
            [self.btnMoney setTitle:@"薪资范围" forState:UIControlStateNormal];
            self.money = @"";
            [self.btnMoney setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateSelected];
            [self.btnMoney setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
        }else{
            self.money = priceArr[index][@"type"];
            [self.btnMoney setTitle:priceArr[index][@"type"] forState:UIControlStateNormal];
            [self.btnMoney setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateSelected];
            [self.btnMoney setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
        }
        [self.btnMoney setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
        [self headerRefreshing];
    }];
    [chooseView setRemoveBlock:^{
        //        self.priceBtn.selected = NO;
    }];
    [self.view addSubview:chooseView];
}
- (IBAction)chooseAddress:(id)sender {
    self.btnMore.selected = NO;
    self.btnMoney.selected = NO;
    self.btnAddress.selected = YES;
    
    for (UIView *view in self.view.subviews) {
        if (view.tag > 800) {
            [view removeFromSuperview];
        }
        if (view.tag == 999) {
            return;
        }
    }
    ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
    chooseView.tag = 999;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    
    chooseView.showAll = YES;
    [chooseView initViewProvince:self.provinceIndex city:self.cityIndex zone:self.zoneIndex location:self.region];
    //    chooseView.curProvinceIndex = self.provinceIndex;
    //    chooseView.curCityIndex = self.cityIndex;
    //    chooseView.curZoneIndex = self.zoneIndex;
    [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){

        self.btnAddress.selected = NO;
        if (provinceIndex == -1) {
            [self.btnAddress setTitle:@"全国" forState:UIControlStateNormal];
            self.region = @"";
            [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateSelected];
            [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
            
        }else{
            self.provinceIndex = provinceIndex;
            self.cityIndex = CityIndex;
            self.zoneIndex = ZoneIndex;
            [self.btnAddress setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
            self.region = zoneArr[ZoneIndex][@"Name"];
            [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateSelected];
            [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
        }
        self.type = 1;
        [self.btnAddress setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self headerRefreshing];
    }];
    [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
        if (zone.length > 0) {
            [self.btnAddress setTitle:zone forState:UIControlStateNormal];
            self.region = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
        }else{
            if (city.length > 0) {
                [self.btnAddress setTitle:city forState:UIControlStateNormal];
                
                if (province.length > 0) {
                    self.region = [NSString stringWithFormat:@"%@%@",province,city];
                }else{
                    self.region = [NSString stringWithFormat:@"%@",city];
                }
            }else{
                [self.btnAddress setTitle:province forState:UIControlStateNormal];
                self.region = [NSString stringWithFormat:@"%@",province];
            }
        }
        
        self.type = 1;
        [self headerRefreshing];
        [self.btnAddress setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateSelected];
        [self.btnAddress setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
    }];
    [chooseView setRemoveBlock:^{
        self.btnAddress.selected = NO;
    }];
    [self.view addSubview:chooseView];
    
}
-(void)showScreenCity{
    AreaScreenView *screenView = [[[NSBundle mainBundle] loadNibNamed:@"AreaScreenView" owner:self options:nil] firstObject];
    screenView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [screenView initViewWithCity:self.cityStr choosedStr:self.choosedStr];
    UIView *backView = [[UIView alloc] init];
    backView.tag = 802;
    backView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y);
    [backView addSubview:screenView];
    [self.view addSubview:backView];
    [screenView setConfirmBlock:^(NSString *choosedStr) {
        
        
        if (choosedStr.length == 0) {
            if (self.cityStr.length == 0) {
                //                [self.btnAddress setTitle:@"全部" forState:UIControlStateSelected];
                
                [self headerRefreshing];
                self.region = @"";
                [self.btnAddress setTitle:@"全部" forState:UIControlStateNormal];
            }else{
                //                [self.btnAddress setTitle:self.cityStr forState:UIControlStateSelected];
                self.region = self.cityStr;
                self.type = 1;
                [self headerRefreshing];
                [self.btnAddress setTitle:self.cityStr forState:UIControlStateNormal];
            }
            
            
        }else{
            self.region = choosedStr;
            self.type = 1;
            [self headerRefreshing];
            self.choosedStr = choosedStr;
            [self.btnAddress setTitle:choosedStr forState:UIControlStateNormal];
            //        [self.btnAddress setTitle:choosedStr forState:UIControlStateSelected];
            [self.btnAddress setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        }
        
        [backView removeFromSuperview];
    }];
    [screenView setCancelBlock:^{
        [backView removeFromSuperview];
    }];
}
- (IBAction)applyAction:(id)sender {
    if (self.deleteArr.count == 0) {
        [self showJGProgressWithMsg:@"未选中职位"];
        return;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"申请岗位"                                                                             message: @"该岗位需要具备对应技能，是否参加入岗培训"                                                                           preferredStyle:UIAlertControllerStyleAlert];
    //    //修改title
    //    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"提示"];
    //    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"1d1d1d"] range:NSMakeRange(0, 2)];
    //    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, 2)];
    //    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    
    //修改message
//    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"您已经是医互助计划会员，无需重复加入，是否邀请您的家人和朋友也加入，让他们也拥有一份健康保障？"];
//    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"555555"] range:NSMakeRange(0, 47)];
//    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 47)];
//    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    //添加Button
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self applyJob];
        
    }];
    //添加Button
    UIAlertAction *addAction = [UIAlertAction actionWithTitle: @"不参加培训" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self applyJob];
    }];
    
    UIAlertAction *cancelAction =  [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:nil];
    
    [cancelAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
    [okAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
    [addAction setValue:[UIColor colorWithHexString:@"555555"] forKey:@"titleTextColor"];
    
    
    [alertController addAction:okAction];
    [alertController addAction:addAction];
    [alertController addAction:cancelAction];
    [self presentViewController: alertController animated: YES completion: nil];

    
}
-(void)applyJob{
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.deleteArr.count; i ++) {
        NSInteger index = [self.deleteArr[i] integerValue];
        RecruitModel *model = self.dataArray[index];
        [muArr addObject:model.Id];
    }
    
    RectuitViewModel *viewModel = [[RectuitViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:@"申请成功"];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
        NSString *message = errorCode;
        if ([message containsString:@"完善"] || [message containsString:@"简历"]) {
            UserResumeViewController *vc = [[UserResumeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [viewModel applyJobsWithIdArr:muArr];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)collectAction:(id)sender {
    
    if (self.deleteArr.count == 0) {
        [self showJGProgressWithMsg:@"未选中职位"];
        return;
    }
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.deleteArr.count; i ++) {
        NSInteger index = [self.deleteArr[i] integerValue];
        RecruitModel *model = self.dataArray[index];
        [muArr addObject:model.Id];
    }
    if (self.btnCollect.selected == NO) {
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:@"收藏成功"];
            self.btnCollect.selected = YES;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel collectWithArray:muArr type:@(5)];
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
        [viewModel cancelCollectWithId:nil type:@(5)];
        [self dissJGProgressLoadingWithTag:200];
    }
}
- (IBAction)allSecectAction:(id)sender {
    if (self.btnAllSelect.selected == NO) {
        self.btnAllSelect.selected = YES;
        [self.deleteArr removeAllObjects];
        for (int i = 0; i < self.dataArray.count; i ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.itemTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.deleteArr addObject:@(i)];
            
        }
        [self changeButtonState];
        NSLog(@"self.deleteArr:%@", self.deleteArr);
        
    }else{
        self.btnAllSelect.selected = NO;
        for (int i = 0; i < self.dataArray.count; i ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.itemTableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        [self.deleteArr removeAllObjects];
        [self changeButtonState];
        NSLog(@"self.deleteArr:%@", self.deleteArr);
        
    }
    [self.itemTableView reloadData];
    self.amountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.deleteArr.count,(long)self.dataArray.count];
}
-(void)changeButtonState{
    if (self.deleteArr.count > 0) {
        self.btnCollect.enabled = YES;
        self.btnCollect.backgroundColor = [UIColor whiteColor];
        self.btnCollect.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
        NSDictionary *userinfo = [UserDefaults readUserDefaultObjectValueForKey:user_info];
        UserModel *userModel = [[UserModel alloc] initWithDict:userinfo];
        if ([userModel.type integerValue] != 3) {
            self.btnApply.enabled = YES;
            self.btnApply.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
        }
    }else{
        self.btnCollect.enabled = NO;
        self.btnCollect.backgroundColor = [UIColor colorWithHexString:@"bbbbbb"];
        self.btnCollect.layer.borderColor = [UIColor colorWithHexString:@"bbbbbb"].CGColor;
        self.btnApply.enabled = NO;
        self.btnApply.backgroundColor = [UIColor colorWithHexString:@"bbbbbb"];
    }
    
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecruitTableViewCell"];
    NSInteger selected = 0;
    for (int i = 0; i < self.deleteArr.count; i ++) {
        if ([self.deleteArr containsObject:@(indexPath.row)]) {
            selected = 1;
        }
    }
    [cell initCellWithModel:self.dataArray[indexPath.row] isHide:selected];
    [cell setReturnSelectBlock:^(NSInteger selected) {
        if (selected == 1) {
            [self.deleteArr addObject:@(indexPath.row)];
            if (self.deleteArr.count == self.dataArray.count) {
                self.btnAllSelect.selected = YES;
                
            }
        }else{
            [self.deleteArr removeObject:@(indexPath.row)];
            self.btnAllSelect.selected = NO;
        }
        [self changeButtonState];
        self.amountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.deleteArr.count,(long)self.dataArray.count];
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 84.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor colorWithHexString:@"e1e1e1"];
    return headView;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
    
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.itemTableView.editing == YES) {
        [self.deleteArr addObject:@(indexPath.row)];
         self.amountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.deleteArr.count,(long)self.dataArray.count];
    }else{
        PositionDetailViewController *vc = [[PositionDetailViewController alloc] init];
        RecruitModel *model = self.dataArray[indexPath.row];
        vc.isFull = model.type;
        vc.jobId = model.Id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//取消选中时 将存放在self.deleteArr中的数据移除

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
   
    [self.deleteArr removeObject:@(indexPath.row)];
     self.amountLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.deleteArr.count,(long)self.dataArray.count];
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
