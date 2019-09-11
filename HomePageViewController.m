//
//  HomePageViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/17.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "HomePageViewController.h"
#import "NewsListViewController.h"
#import "NewsViewController.h"
#import "RecruitViewController.h"
#import "TrainListViewController.h"
#import "PolicyListViewController.h"
#import "ActivityViewController.h"
#import "NewsDetailViewController.h"
#import "UserInfomationViewController.h"
#import "LoginViewController.h"
#import "CompanyDataViewController.h"
#import "StartUpViewController.h"
#import "SearchNewsViewController.h"
#import "JFCityViewController.h"
#import "CompanyMainAreaViewController.h"
#import "CompanyAuthViewController.h"


#import "HomeHeaderView.h"
#import "HomeBannerTableViewCell.h"
#import "HomePagePicTableViewCell.h"
#import "HomePageInfoTableViewCell.h"
#import "HomePageAboutUsTableViewCell.h"
#import "TestViewController.h"

#import "HomeViewModel.h"
#import "NewsViewModel.h"
#import "MineViewModel.h"
#import "NewsModel.h"

#import <UIButton+WebCache.h>
#import "MSWeakTimer.h"
#import "H_PCZ_PickerView.h"
#import "ProvinceCityZoneView.h"

@interface HomePageViewController ()<UITableViewDelegate,UITableViewDataSource,H_PCZ_PickerViewDelegate,JFCityViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnCity;
@property (weak, nonatomic) IBOutlet UIButton *btnCompany;

@property (nonatomic, retain) HomeHeaderView *headerView;
@property (nonatomic, retain) NewsModel *newsModel;
@property (nonatomic, retain) HomeViewModel *viewModel;
@property (nonatomic, retain) HomeViewModel *newsViewModel;
@property (nonatomic, retain) NewsViewModel *hotViewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *bannerArr;
@property (nonatomic, retain) MSWeakTimer           *bannerTimer;
@property (nonatomic, retain) MSWeakTimer           *cellTimer;
@end

@implementation HomePageViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *location = [UserDefaults readUserDefaultObjectValueForKey:location_city];
    //用户头像改为显示定位当前地址
    
    if (location.length > 0) {
        
//        self.btnCity.hidden = NO;
    }else{
        if (self.btnCity.titleLabel.text.length == 0) {
            [self.btnCity setTitle:@"定位中" forState:UIControlStateNormal];
        }
//        self.btnCity.hidden = NO;
    }
    [self.btnCity setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    self.btnCity.hidden = NO;
    
    
    NSNumber * userType = [UserDefaults readUserDefaultObjectValueForKey:user_type];
    if ([userType integerValue] == 3) {
        self.btnCompany.hidden = NO;
    }else{
        self.btnCompany.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self VersionButton];
//    [MTNotification addLogOutNotification:self action:@selector(logOutToLogin)];
    
    
 
    
    self.btnCity.layer.masksToBounds = YES;
    self.btnCity.layer.cornerRadius = 6.f;
    
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView" owner:self options:nil]firstObject];
    NSString *location = [UserDefaults readUserDefaultObjectValueForKey:location_city];
    //用户头像改为显示定位当前地址
    [self.btnCity setTitle:location forState:UIControlStateNormal];
    [self.btnCity setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    __weak typeof(self)weakSelf = self;
    [self.headerView setEndDeceleratingBlock:^{
        NSLog(@"");
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf.headerView selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }];
    [self.headerView setBeginDraggingBlock:^{
        NSLog(@"");
        [weakSelf.bannerTimer invalidate];
    }];
    
    self.itemArr = [[NSMutableArray alloc] init];
    self.bannerArr = [[NSMutableArray alloc] init];
//    NSDictionary *userinfo = [UserDefaults readUserDefaultObjectValueForKey:user_info];
//    if (userinfo) {
//        UserModel *userModel = [[UserModel alloc] initWithDict:userinfo];;
//        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseUrl,userModel.image]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"人员2"]];
//    }
//    self.headImageView.layer.masksToBounds = YES;
//    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width/2;
//
    [self.headerView initView];
    
    [self.headerView setItemBlcok:^(NSInteger tag) {
        switch (tag) {
            case 1:
            {
                RecruitViewController *vc = [[RecruitViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                TrainListViewController *vc = [[TrainListViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 3:
            {
                PolicyListViewController *vc = [[PolicyListViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 4:
            {
                weakSelf.navigationController.tabBarController.selectedIndex = 1;
//                ActivityViewController *vc = [[ActivityViewController alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 5:
//                [weakSelf showJGProgressWithMsg:@"二期开放"];
            {

                StartUpViewController *vc = [[StartUpViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 6:
            {
                NewsViewController *vc = [[NewsViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 7:
                [weakSelf showJGProgressWithMsg:@"二期开放"];

                break;
            case 8:
                [weakSelf showJGProgressWithMsg:@"二期开放"];
                break;
            case 9:
                [weakSelf showJGProgressWithMsg:@"二期开放"];
                break;
            default:
                break;
        }
    }];
    self.homeTableView.tableHeaderView = self.headerView;
    self.navigationController.navigationBarHidden = YES;
    
    [self.homeTableView registerNib:[UINib nibWithNibName:@"HomePageInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomePageInfoTableViewCell"];
    [self.homeTableView registerNib:[UINib nibWithNibName:@"HomePagePicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomePagePicTableViewCell"];
    [self.homeTableView registerNib:[UINib nibWithNibName:@"HomePageAboutUsTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomePageAboutUsTableViewCell"];
    [self.homeTableView registerNib:[UINib nibWithNibName:@"HomeBannerTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeBannerTableViewCell"];
    
    
//    MineViewModel *viewModel = [[MineViewModel alloc] init];
//    [viewModel setBlockWithReturnBlock:^(id returnValue) {
//        UserModel *userModel = returnValue;
////        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseUrl,userModel.image]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"人员2"]];
////        self.headImageView.layer.masksToBounds = YES;
////        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width/2;
//    } WithErrorBlock:^(id errorCode) {
//        [self showJGProgressWithMsg:errorCode];
//    }];
//    [viewModel fetchUserInfomation];

    self.viewModel = [[HomeViewModel alloc] init];
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf.headerView initBannerView:returnValue];
        [weakSelf.bannerArr removeAllObjects];
        [weakSelf.bannerArr addObjectsFromArray:returnValue];
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf.headerView selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [weakSelf.newsViewModel fetchHomeNews];
    } WithErrorBlock:^(id errorCode) {
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    
    self.newsViewModel = [[HomeViewModel alloc] init];
    [self.newsViewModel setBlockWithReturnBlock:^(id returnValue) {
        weakSelf.newsModel = returnValue;
        [weakSelf.homeTableView reloadData];
//        [weakSelf.viewModel fetchHomeBannerWithId:@(1)];
        [weakSelf.homeTableView.mj_header endRefreshing];
    } WithErrorBlock:^(id errorCode) {
        [weakSelf.homeTableView.mj_header endRefreshing];
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    self.hotViewModel = [[NewsViewModel alloc] init];
    [self.hotViewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf.itemArr removeAllObjects];
        [weakSelf.itemArr addObjectsFromArray:returnValue];
        [weakSelf.homeTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    
    [self setupRefresh];
    
    
    if (TOKEN) {
        NSNumber *number = [UserDefaults readUserDefaultObjectValueForKey:@"authStatus"];
        if ([number integerValue] != 2) {
            MineViewModel *authViewModel = [[MineViewModel alloc] init];
            [authViewModel setBlockWithReturnBlock:^(id returnValue) {
                NSNumber *status = returnValue;
                [UserDefaults writeUserDefaultObjectValue:status withKey:@"authStatus"];
            } WithErrorBlock:^(id errorCode) {
                
            }];
            [authViewModel fetchAuthStatus];
        }
    }
    // Do any additional setup after loading the view from its nib.
}

/**
 设置刷新
 */
-(void)setupRefresh{
    self.homeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    [self.homeTableView.mj_header beginRefreshing];
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
    
    [self.viewModel fetchHomeBannerWithId:@(1)];
//    [self.newsViewModel fetchHomeNews];
    [self.hotViewModel fetchHotNews];
}
- (IBAction)skipToCompanyArea:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    NSNumber * userType = [UserDefaults readUserDefaultObjectValueForKey:user_type];
    if ([userType integerValue] == 3) {
        CompanyMainAreaViewController *vc = [[CompanyMainAreaViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        CompanyAuthViewController *vc = [[CompanyAuthViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//当前页面不在导航控制器中，需重写preferredStatusBarStyle，如下：

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    
//    return UIStatusBarStyleLightContent; //白色
//    
//    //    return UIStatusBarStyleDefault; //黑色
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)skipToUserInfomation:(id)sender {
//    NSString *userType = [UserDefaults readUserDefaultObjectValueForKey:user_type];
//    if ([userType integerValue] == 3) {
//        CompanyDataViewController *vc = [[CompanyDataViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        UserInfomationViewController *vc = [[UserInfomationViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    if (kDevice_Is_iPhoneX) {
//        H_PCZ_PickerView *pickerView = [[H_PCZ_PickerView alloc]initWithFrame:CGRectMake(0, -30, ScreenWidth, ScreenHeight-34-24-64)];
//        pickerView.delegate = self;
//        [self.view addSubview:pickerView];
//    }else{
//        H_PCZ_PickerView *pickerView = [[H_PCZ_PickerView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, ScreenHeight-64)];
//        pickerView.delegate = self;
//        [self.view addSubview:pickerView];
//    }
//    for (UIView *subView in self.view.subviews) {
//        if (subView.tag == 999) {
//            [subView removeFromSuperview];
//        }
//    }
//    self.btnCity.selected = !self.btnCity.selected;
//    if (self.btnCity.selected == NO) {
//        return;
//    }
//    ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
//    chooseView.tag = 999;
//    chooseView.frame = CGRectMake(0, self.homeTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.homeTableView.frame.origin.y + 10);
//
////    chooseView.showAll = YES;
//    NSString *location = [UserDefaults readUserDefaultObjectValueForKey:location_city];
//    [chooseView initViewProvince:0 city:0 zone:0 location:location];
//    //    chooseView.curProvinceIndex = self.provinceIndex;
//    //    chooseView.curCityIndex = self.cityIndex;
//    //    chooseView.curZoneIndex = self.zoneIndex;
//    [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){
//            [self.btnCity setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
//        [self.btnCity setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
//
//    }];
//    [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
//        if (zone.length > 0) {
//
//            [self.btnCity setTitle:zone forState:UIControlStateNormal];
//
//        }else{
//            if (city.length > 0) {
//                [self.btnCity setTitle:city forState:UIControlStateNormal];
//
//            }else{
//                [self.btnCity setTitle:province forState:UIControlStateNormal];
//
//            }
//        }
//
//        [self.btnCity setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
//    }];
//    [chooseView setRemoveBlock:^{
////        self.headImageView.selected = NO;
//    }];
//    [self.view addSubview:chooseView];
    JFCityViewController *cityViewController = [[JFCityViewController alloc] init];
    //  设置代理
    cityViewController.delegate = self;
    cityViewController.title = @"城市";
    //  给JFCityViewController添加一个导航控制器
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cityViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}
-(void)cityName:(NSString *)name{
    [self.btnCity setTitle:name forState:UIControlStateNormal];
    [self.btnCity  setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    [UserDefaults writeUserDefaultObjectValue:name withKey:@"location_city"];
}
-(void)logOutToLogin{

}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return self.itemArr.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        NewsModel *model = self.itemArr[indexPath.row];
        if (model.thumb.count > 1) {
            HomePageInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageInfoTableViewCell"];
            [cell initCellWithModel:model type:0];
            return cell;
        }else{
            HomePagePicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePagePicTableViewCell"];
            [cell initCellWithModel:model type:0];
            return cell;
        }
        
    }
    
    if (indexPath.section == 0) {
//        HomePagePicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePagePicTableViewCell"];
//        [cell initCellWithModel:self.newsModel type:0];
        HomeBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeBannerTableViewCell"];
        [cell initBannerView:self.bannerArr];
        [cell setItemBlcok:^(NSInteger index) {
           self.navigationController.tabBarController.selectedIndex = 1;
        }];
        self.cellTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:cell selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [cell setEndDeceleratingBlock:^{
            NSLog(@"");
            self.cellTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:self.headerView selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        }];
        [cell setBeginDraggingBlock:^{
            NSLog(@"");
            [self.cellTimer invalidate];
        }];
        return cell;
        
    }
//    if (indexPath.section == 2) {
//        HomePageAboutUsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageAboutUsTableViewCell"];
//        [cell initCellWithString:@"“迷彩网”项目是成都迷彩汇科技有限公司自主研发的多用途退役军人服务网站，是立足将退役军人回归社会后的服务基础，切实的将产业培训、科技中介等线下功能体现，更能以大数据收集各地的退役军人就创业政策以便更好的为客户服务，在体现退役后的服务中植入了“迷彩帮帮帮”的M5模式，如：退役后就创业指导+各地政策+技能培训+科技咨询+咨询服务，在模式中会根据客户的不同个性及外在条件匹配适合的就创业渠道，并为此提供各环节的咨询服务。\n新迷彩、新生活\n-----迷彩网科技成都迷彩汇科技有限公司\n公司地址：成都市金牛区蜀汉路347号五单元902号"];
//        return cell;
//    }
    HomePagePicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePagePicTableViewCell"];
    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0001f;
    }
    return 40.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    if (section > 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 100, 16)];
        titleLabel.textColor = [UIColor colorWithHexString:@"222222"];
        titleLabel.font = [UIFont systemFontOfSize:18];
        [headView addSubview:titleLabel];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, ScreenWidth - 10, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"e0e0e0"];
        [headView addSubview:lineLabel];
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(ScreenWidth - 80, 10, 60, 20);
        [button setTitle:@"更多" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"箭头拷贝8"] forState:UIControlStateNormal];
        [button setImagePositionWithType:SSImagePositionTypeRight spacing:2.f];
        [button addTarget:self action:@selector(editingAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 999 + section;
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
        
        switch (section) {
//            case 1:
//                titleLabel.text = @"商城推荐";
//                [headView addSubview:button];
//                break;
            case 1:
                titleLabel.text = @"信息推荐";
                [headView addSubview:button];
                break;
//            case 2:
//                titleLabel.text = @"关于我们";
//                break;
            default:
                break;
        }
        
    }
    

    return headView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
//        NewsDetailViewController *vc = [[NewsDetailViewController alloc] init];
//        NewsModel *model = self.newsModel;
//        vc.newsId = model.news_id;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 1){
        NewsDetailViewController *vc = [[NewsDetailViewController alloc] init];
        NewsModel *model = self.itemArr[indexPath.row];
        vc.newsId = model.news_id;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)editingAction:(UIButton *)btn{
    if (btn.tag - 999 == 1) {
        NewsViewController *vc = [[NewsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self showJGProgressWithMsg:@"二期开放"];
    }
}
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    SearchNewsViewController *vc = [[SearchNewsViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
    
}
#pragma mark - H_PCZ_PickerViewDelegate
-(void)getChooseIndex:(H_PCZ_PickerView *)_myPickerView addressStr:(NSString *)addressStr areaCode:(NSString *)areaCode{
    [self.btnCity setTitle:addressStr forState:UIControlStateNormal];
    [self.btnCity setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
    //    self.btnArea.titleLabel.textAlignment = NSTextAlignmentRight;
    //    self.zone_code = [areaCode integerValue];
}

-(void)VersionButton{
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
    //3从网络获取appStore版本号
    NSError *error;
    //    NSData *response = [NSURLSession ]
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=1432335213"]]] returningResponse:nil error:nil];
    if (response == nil) {
        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    //    NSLog(@"%@",appInfoDic);
    NSArray *array = appInfoDic[@"results"];
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    //打印版本号
    NSLog(@"当前版本号:%@\n商店版本号:%@",currentVersion,appStoreVersion);
    //4当前版本号小于商店版本号,就更新
    if([currentVersion floatValue] < [appStoreVersion floatValue])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",appStoreVersion] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"更新" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id1432335213?ls=1&mt=8"]];
            [[UIApplication sharedApplication] openURL:url];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alertController addAction:action];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"检测版本" message:@"已是最新版本" preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
//
//        }];
//
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
//        [alertController addAction:action];
//        [alertController addAction:cancel];
//        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
-(void)checkAppUpdate:(NSString *)appInfo{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appInfo1 = [appInfo substringFromIndex:[appInfo rangeOfString:@"\"version\":"].location + 10];
    appInfo1 = [[appInfo1 substringToIndex:[appInfo1 rangeOfString:@","].location] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    if (![appInfo1 isEqualToString:version]) {
        NSLog(@"");
        
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
