//
//  StartUpViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/23.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "StartUpViewController.h"
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

@interface StartUpViewController()
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIButton *btnArea;
@property (weak, nonatomic) IBOutlet UIButton *btnAmount;
@property (weak, nonatomic) IBOutlet UIButton *btnEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnProject;
@property (weak, nonatomic) IBOutlet UIView *helpView;

@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnMiddle;//创业帮帮帮
@property (weak, nonatomic) IBOutlet UIButton *btnTitleRight;//创业新闻汇

@property (nonatomic, retain) StartUpViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *cateArr;
@property (nonatomic, retain) NSMutableArray *industryArr;
@property (nonatomic, retain) NSMutableArray *helpTypeArr;
@property (nonatomic, retain) NSMutableArray *helpIdArr;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger titleIndex;
@property (nonatomic, assign) NSInteger reloadIndex;
@property (nonatomic, assign) NSInteger industryIndex;
@property (nonatomic, assign) NSInteger amountIndex;
@property (nonatomic, assign) NSInteger hotIndex;
@property (nonatomic, assign) NSInteger cat_id;
@property (nonatomic, copy) NSString *industryStr;
@property (nonatomic, copy) NSString *hotStr;
@property (nonatomic, copy) NSString *amountStr;
@property (nonatomic, copy) NSString *areaStr;
@property (nonatomic, copy) NSString *searchKey;
@property (nonatomic, assign) NSInteger provinceIndex;
@property (nonatomic, assign) NSInteger cityIndex;
@property (nonatomic, assign) NSInteger zoneIndex;

@end

@implementation StartUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    self.industryArr = [[NSMutableArray alloc] init];
    self.helpTypeArr = [[NSMutableArray alloc] init];
    self.helpIdArr = [[NSMutableArray alloc] init];
    
    [self.btnTitle setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnLeft setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnRight setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [self.btnAmount setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    
    
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartUpStarTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpStarTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"StartHelpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartHelpTableViewCell"];
    self.itemTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    
    self.provinceIndex = 0;
    self.cityIndex = 0;
    self.zoneIndex = 0;
    
    [self.btnEvent setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
    
    self.btnTitle.selected = YES;
    self.btnTitle.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    
    self.btnTitleRight.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.btnTitleRight.layer.borderWidth = 1;
    self.btnMiddle.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.btnMiddle.layer.borderWidth = 1;
    self.btnTitle.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.btnTitle.layer.borderWidth = 0;
    self.btnTitleRight.layer.masksToBounds = YES;
    self.btnTitleRight.layer.cornerRadius = 4.f;
    self.btnMiddle.layer.masksToBounds = YES;
    self.btnMiddle.layer.cornerRadius = 4.f;
    self.btnTitle.layer.masksToBounds = YES;
    self.btnTitle.layer.cornerRadius = 4.f;
    
    
    self.btnTitleRight.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnMiddle.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.btnTitle.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.viewModel = [[StartUpViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        if (self.pageIndex == 1) {
            [weakSelf.itemArr removeAllObjects];
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
        weakSelf.reloadIndex = weakSelf.titleIndex;
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
    
    StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self.industryArr addObjectsFromArray:returnValue];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchStartUpIndustry];
    
    StartUpViewModel *typeViewModel = [[StartUpViewModel alloc] init];
    [typeViewModel setBlockWithReturnBlock:^(id returnValue) {
        [self.helpTypeArr addObjectsFromArray:returnValue];
        if (self.helpTypeArr.count == 2) {
            [self.btnProject setTitle:self.helpTypeArr[1][@"cat_name"] forState:UIControlStateNormal];
            [self.btnEvent setTitle:self.helpTypeArr[0][@"cat_name"] forState:UIControlStateNormal];
            [self.helpIdArr addObject:self.helpTypeArr[0][@"cat_id"]];
            [self.helpIdArr addObject:self.helpTypeArr[1][@"cat_id"]];
        }else{
            [self.helpIdArr addObject:@(1)];
            [self.helpIdArr addObject:@(2)];
        }
        self.cat_id = [self.helpIdArr[0] integerValue];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [typeViewModel fetchStartHelpType];
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
    if (self.titleIndex == 0) {
        [self.viewModel fetchStartUpListWithIndustry:self.industryStr money:self.amountStr region:self.areaStr hotindustry:self.hotStr keywords:self.searchKey page:@(self.pageIndex)];
        
    }else if (self.titleIndex == 1){
        [self.viewModel  fetchStartHelpWithIndustry:self.industryStr money:self.amountStr region:self.areaStr hotindustry:self.hotStr keywords:self.searchKey page:@(self.pageIndex) cat_id:@(self.cat_id)];
    }else{
        [self.viewModel fetchStartStarWithKeywords:nil page:@(self.pageIndex)];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chooseAmount:(id)sender {
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
    chooseView.currentSelectIndex = self.amountIndex;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    chooseView.selectedBtnImgStr = @"对号";
    chooseView.colorStr = @"f26f05";
    //    id baseData = [UserDefaults readUserDefaultObjectValueForKey:base_data];
    //    NSDictionary *dic = baseData[@"care"];
    NSArray *priceArr = @[@{@"type":@"不限"},@{@"type":@"3万以下"}, @{@"type":@"3-5万"}, @{@"type":@"5-10万"}, @{@"type":@"10-20万"}, @{@"type":@"20-50万"}, @{@"type":@"50万以上"}];
    [chooseView initView:priceArr];
    [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
        self.amountIndex = index;
        self.hotStr = @"";
        if (index == 0) {
            self.amountStr = @"";
            [self.btnAmount setTitle:@"投资额度" forState:UIControlStateNormal];
            self.btnAmount.selected = NO;
            
        }else{
            self.amountStr = priceArr[index][@"type"];
            self.btnAmount.selected = YES;
            [self.btnAmount setTitle:priceArr[index][@"type"] forState:UIControlStateNormal];
        }
        self.hotStr = @"";
        self.btnRight.selected = NO;
        [self.btnAmount setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
        [self headerRefreshing];
        
    }];
    [chooseView setRemoveBlock:^{
        //        self.priceBtn.selected = NO;
    }];
    [self.view addSubview:chooseView];
}
- (IBAction)chooseArea:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 999) {
            return;
        }
    }
    NSString *str = [UserDefaults readUserDefaultObjectValueForKey:location_city];
    str = str ? str : @"";
    ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
    chooseView.tag = 999;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    
    chooseView.showAll = YES;
    //    chooseView.curProvinceIndex = self.provinceIndex;
    //    chooseView.curCityIndex = self.cityIndex;
    //    chooseView.curZoneIndex = self.zoneIndex;
    [chooseView initViewProvince:self.provinceIndex city:self.cityIndex zone:self.zoneIndex location:str];
    
    [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){
        self.hotStr = @"";
        
        if (provinceIndex == -1) {
            [self.btnArea setTitle:@"加盟区域" forState:UIControlStateNormal];
            self.btnArea.selected = NO;
            self.areaStr = @"";
        }else{
            self.provinceIndex = provinceIndex;
            self.cityIndex = CityIndex;
            self.zoneIndex = ZoneIndex;
            self.btnArea.selected = YES;
            [self.btnArea setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
            self.areaStr = zoneArr[ZoneIndex][@"Name"];
        }
        self.hotStr = @"";
        self.btnRight.selected = NO;
        [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self headerRefreshing];
    }];
    [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
        self.hotStr = @"";
        self.btnArea.selected = YES;
        if (zone.length > 0) {
            [self.btnArea setTitle:zone forState:UIControlStateNormal];
            self.areaStr = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
        }else{
            if (city.length > 0) {
                [self.btnArea setTitle:city forState:UIControlStateNormal];
                
                if (province.length > 0) {
                    self.areaStr = [NSString stringWithFormat:@"%@%@",province,city];
                }else{
                    self.areaStr = [NSString stringWithFormat:@"%@",city];
                }
            }else{
                [self.btnArea setTitle:province forState:UIControlStateNormal];
                self.areaStr = [NSString stringWithFormat:@"%@",province];
            }
        }
        self.hotStr = @"";
        self.btnRight.selected = NO;
        [self headerRefreshing];
        [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    }];
    [chooseView setRemoveBlock:^{
        self.btnArea.selected = NO;
    }];
    [self.view addSubview:chooseView];
}

- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)titleAction:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 991) {
            return;
        }
    }
    if (self.titleIndex != 0) {
        self.hotStr = @"";
        self.btnRight.selected = NO;
        self.industryStr = @"";
        self.industryIndex = 0;
        self.amountStr = @"";
        self.amountIndex = 0;
        self.areaStr = @"";
        self.btnArea.selected = NO;
        self.btnAmount.selected = NO;
        self.btnLeft.selected = NO;
    }
    
    self.topView.hidden = NO;
    self.helpView.hidden = YES;
    self.topViewHeight.constant = 40;
    self.btnSearch.hidden = NO;
    self.titleIndex = 0;
    
    self.btnMiddle.selected = NO;
    self.btnTitle.selected = YES;
    self.btnTitleRight.selected = NO;
    
    self.btnMiddle.backgroundColor = [UIColor whiteColor];
    self.btnTitle.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    self.btnTitleRight.backgroundColor = [UIColor whiteColor];
    
    self.btnTitle.layer.borderWidth = 0;
    self.btnMiddle.layer.borderWidth = 1;
    self.btnTitleRight.layer.borderWidth = 1;
    [self headerRefreshing];
    //        }else{
    //            self.topView.hidden = YES;
    //            self.topViewHeight.constant = 0;
    //            self.btnSearch.hidden = YES;
    //        }
    //        self.btnTitle.selected = NO;
    
    //        [self.btnTitle setTitle:priceArr[index][@"type"] forState:UIControlStateNormal];
    //        [self.btnTitle setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
    //        [self headerRefreshing];
    //
    //    }];
    //    [chooseView setRemoveBlock:^{
    //                self.btnTitle.selected = NO;
    //    }];
    //    [self.view addSubview:chooseView];
}

- (IBAction)middleTitleAction:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
    }
    
    if (self.titleIndex != 1) {
        self.hotStr = @"";
        self.btnRight.selected = NO;
        self.industryStr = @"";
        self.industryIndex = 0;
        self.amountStr = @"";
        self.amountIndex = 0;
        self.areaStr = @"";
        self.btnArea.selected = NO;
        self.btnAmount.selected = NO;
        self.btnLeft.selected = NO;
    }
    
    self.topView.hidden = YES;
    self.topViewHeight.constant = 40;
    self.reloadIndex = 1;
    self.helpView.hidden = NO;
//    self.topView.hidden = YES;
//    self.topViewHeight.constant = 0;
    self.btnSearch.hidden = NO;
    self.btnMiddle.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    self.btnTitle.backgroundColor = [UIColor whiteColor];
    self.btnTitleRight.backgroundColor = [UIColor whiteColor];
    self.btnMiddle.selected = YES;
    self.btnTitle.selected = NO;
    self.btnTitleRight.selected = NO;
    self.btnTitle.layer.borderWidth = 1;
    self.btnMiddle.layer.borderWidth = 0;
    self.btnTitleRight.layer.borderWidth = 1;
    self.titleIndex = 1;
    [self headerRefreshing];
}
- (IBAction)rightTitleAction:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
    }
    
    if (self.titleIndex != 2) {
        self.hotStr = @"";
        self.btnRight.selected = NO;
        self.industryStr = @"";
        self.industryIndex = 0;
        self.amountStr = @"";
        self.amountIndex = 0;
        self.areaStr = @"";
        self.btnArea.selected = NO;
        self.btnAmount.selected = NO;
        self.btnLeft.selected = NO;
    }
    
    self.topView.hidden = YES;
    self.helpView.hidden = YES;
    self.topViewHeight.constant = 0;
    self.btnSearch.hidden = YES;
    
    self.btnMiddle.selected = NO;
    self.btnTitle.selected = NO;
    self.btnTitleRight.selected = YES;
    self.btnMiddle.backgroundColor = [UIColor whiteColor];
    self.btnTitle.backgroundColor = [UIColor whiteColor];
    self.btnTitleRight.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    self.btnTitle.layer.borderWidth = 1;
    self.btnMiddle.layer.borderWidth = 1;
    self.btnTitleRight.layer.borderWidth = 0;
    self.titleIndex = 2;
    [self headerRefreshing];
}

- (IBAction)searchAction:(id)sender {
    LabelSearchViewController *vc = [[LabelSearchViewController alloc] init];
    vc.titleIndex = self.titleIndex;
    [vc setReturnSearchBlock:^(NSString *str) {
        self.industryStr = @"";
        self.amountStr = @"";
        self.areaStr = @"";
        self.hotStr = @"";
        self.btnLeft.selected = NO;
        self.btnArea.selected = NO;
        self.btnAmount.selected = NO;
        self.btnLeft.selected = NO;
        [self.btnLeft setTitle:@"加盟行业" forState:UIControlStateNormal];
        [self.btnAmount setTitle:@"投资额度" forState:UIControlStateNormal];
        [self.btnArea setTitle:@"加盟区域" forState:UIControlStateNormal];
        [self.btnRight setTitle:@"热门点击" forState:UIControlStateNormal];
        [self.btnLeft setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self.btnRight setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self.btnAmount setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        self.provinceIndex = 0;
        self.cityIndex = 0;
        self.zoneIndex = 0;
        self.industryIndex = 0;
        self.amountIndex = 0;
        self.hotIndex = 0;
        self.searchKey = str;
        [self headerRefreshing];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)rightBtnAction:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 998) {
            return;
        }
    }
    self.hotStr = @"desc";
    self.btnRight.selected = YES;
    self.industryStr = @"";
    self.industryIndex = 0;
    self.amountStr = @"";
    self.amountIndex = 0;
    self.areaStr = @"";
    self.btnArea.selected = NO;
    self.btnAmount.selected = NO;
    self.btnLeft.selected = NO;
    [self headerRefreshing];
    
    
    //        SingleChooseListView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"SingleChooseListView" owner:self options:nil] firstObject];
    //        chooseView.tag = 998;
    //        chooseView.currentSelectIndex = self.hotIndex;
    //        chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    //        chooseView.selectedBtnImgStr = @"对号";
    //        chooseView.colorStr = @"f26f05";
    //        //    id baseData = [UserDefaults readUserDefaultObjectValueForKey:base_data];
    //        //    NSDictionary *dic = baseData[@"care"];
    //
    //    NSArray *priceArr = @[@{@"type":@"热门行业"},@{@"type":@"小吃"}, @{@"type":@"甜品"}, @{@"type":@"西餐料理"}, @{@"type":@"家政"}, @{@"type":@"娱乐"}, @{@"type":@"空气净化"}];
    //    [chooseView initView:priceArr];
    //        [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
    //            if (index == 0) {
    //                self.hotStr = @"";
    //            }else{
    //                self.hotStr = priceArr[index][@"type"];
    //            }
    //            self.hotIndex = index;
    //            [self.self.btnRight setTitle:priceArr[index][@"type"] forState:UIControlStateNormal];
                [self.btnRight setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
    ////            self.hotStr = @"";
    ////            [self headerRefreshing];
    //
    //        }];
    //        [chooseView setRemoveBlock:^{
    //            //        self.priceBtn.selected = NO;
    //        }];
    //        [self.view addSubview:chooseView];
    
    
}
- (IBAction)leftBtnAction:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 900) {
            [view removeFromSuperview];
        }
        if (view.tag == 997) {
            return;
        }
    }
    
    NSMutableArray *priceArr = [[NSMutableArray alloc] init];
    [priceArr addObject:@{@"id":@"0",@"name":@"不限"}];
    [priceArr addObjectsFromArray:self.industryArr];
    if (priceArr.count == 1) {
        StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [priceArr addObjectsFromArray:returnValue];
            [self showIndustryWithArr:priceArr];
        } WithErrorBlock:^(id errorCode) {
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel fetchStartUpIndustry];
    }else{
        [self showIndustryWithArr:priceArr];
    }
    
}
-(void)showIndustryWithArr:(NSArray *)priceArr{
    
    SingleChooseListView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"SingleChooseListView" owner:self options:nil] firstObject];
    chooseView.tag = 997;
    chooseView.currentSelectIndex = self.industryIndex;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    chooseView.selectedBtnImgStr = @"对号";
    chooseView.colorStr = @"f26f05";
    //    id baseData = [UserDefaults readUserDefaultObjectValueForKey:base_data];
    //    NSDictionary *dic = baseData[@"care"];
    
    
    [chooseView initView:priceArr];
    [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
        self.hotStr = @"";
        if (index == 0) {
            self.industryStr = @"";
            self.btnLeft.selected = NO;
            [self.btnLeft setTitle:@"加盟 行业" forState:UIControlStateNormal];
        }else{
            self.industryStr = priceArr[index][@"name"];
            self.btnLeft.selected = YES;
            [self.btnLeft setTitle:priceArr[index][@"name"] forState:UIControlStateNormal];
        }
        self.hotStr = @"";
        self.btnRight.selected = NO;
        self.industryIndex = index;
        [self.btnLeft setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
        [self headerRefreshing];
        
    }];
    [chooseView setRemoveBlock:^{
        //        self.priceBtn.selected = NO;
    }];
    [self.view addSubview:chooseView];
}
- (IBAction)chooseGoodProject:(id)sender {
    [self.btnProject setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
    [self.btnEvent setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    self.cat_id = [self.helpIdArr[1] integerValue];
    
    [self headerRefreshing];
}
- (IBAction)chooseHelpEvent:(id)sender {
    [self.btnProject setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [self.btnEvent setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateNormal];
    self.cat_id = [self.helpIdArr[0] integerValue];
    [self headerRefreshing];
}



#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.reloadIndex == 0) {
        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
        [cell initCellWithModel:self.itemArr[indexPath.row]];
        return cell;
    }else if(self.reloadIndex == 1){
        if (self.cat_id == 1) {
            StartHelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartHelpTableViewCell"];
            [cell initCellWithModel:self.itemArr[indexPath.row]];
            return cell;

        }else{
//            StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
//            [cell initCellWithModel:self.itemArr[indexPath.row]];
//            return cell;
            StartHelpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartHelpTableViewCell"];
            [cell initCellWithModel:self.itemArr[indexPath.row]];
            return cell;
        }
        
    }
    StartUpStarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpStarTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
    
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.reloadIndex == 1) {
        if (self.cat_id == 1) {
            return 240.f;
        }
        return 240.f;
    }
    return 110.f;
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.reloadIndex == 0) {
        StartUpDetailViewController *vc = [[StartUpDetailViewController alloc]init];
        StartUpModel *model = self.itemArr[indexPath.row];
        vc.Id = model.Id;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.reloadIndex == 1){
        if (self.cat_id == 1) {
            StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
            StartStarModel *model = self.itemArr[indexPath.row];
            vc.type = @(1);
            vc.Id = model.Id;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
//            StartUpDetailViewController *vc = [[StartUpDetailViewController alloc]init];
//            StartUpModel *model = self.itemArr[indexPath.row];
//            vc.Id = model.Id;
//            [self.navigationController pushViewController:vc animated:YES];
            StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
            StartStarModel *model = self.itemArr[indexPath.row];
            vc.type = @(1);
            vc.Id = model.Id;
            [self.navigationController pushViewController:vc animated:YES];

        }
        
    }else{
        StartStarDetailViewController *vc = [[StartStarDetailViewController alloc]init];
        StartStarModel *model = self.itemArr[indexPath.row];
        vc.type = 0;
        vc.Id = model.Id;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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
