//
//  PolicyListViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PolicyListViewController.h"
#import "QueryPolicyViewController.h"
#import "PolicyDetailViewController.h"
#import "InfomationCollectViewController.h"
#import "PolicyListTableViewCell.h"
#import "PolicyRevealTableViewCell.h"
#import "PolicyViewModel.h"
#import "DepartmentAlertView.h"
#import "ProvinceCityZoneView.h"
#import "DepartmentScreenView.h"


#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MapKit/MKPointAnnotation.h>
@interface PolicyListViewController ()<AMapSearchDelegate,MAMapViewDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnLocalDepartment;
@property (weak, nonatomic) IBOutlet UIButton *btnPolicyLibrary;
@property (weak, nonatomic) IBOutlet UILabel *orangeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *departmentScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnInfomation;
@property (weak, nonatomic) IBOutlet UIButton *btnMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnPolicyApply;
@property (weak, nonatomic) IBOutlet UITableView *policyTableView;
@property (weak, nonatomic) IBOutlet UIView *departmentInfoView;


@property (nonatomic, retain) PolicyViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger times;
@property (nonatomic, assign) NSInteger catId;
@property (nonatomic, assign) NSInteger areaTimes;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, assign) NSInteger provinceIndex;
@property (nonatomic, assign) NSInteger cityIndex;
@property (nonatomic, assign) NSInteger zoneIndex;

@property (nonatomic, retain) MAMapView *mapView;
@property (nonatomic, retain) AMapLocationManager *locationManager;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat policyHeight;
@end

@implementation PolicyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.catId = 1;
    
    self.provinceIndex = 0;
    self.cityIndex = 0;
    self.zoneIndex = 0;
    self.times = 1;
    
    
    self.itemArr = [[NSMutableArray alloc] init];
    
    
    [self.itemTableView registerNib:[UINib nibWithNibName:@"PolicyListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PolicyListTableViewCell"];
    
    self.itemTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewModel = [[PolicyViewModel alloc] init];
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
        [weakSelf.itemTableView reloadData];
        [weakSelf.policyTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        if (self.pageIndex == 1) {
            [weakSelf.itemTableView.mj_header endRefreshing];
        }else{
            [weakSelf.itemTableView.mj_footer endRefreshing];
        }
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self setupRefresh];
    self.itemTableView.estimatedRowHeight = 300.f;
    self.itemTableView.rowHeight = UITableViewAutomaticDimension;
    self.policyTableView.estimatedRowHeight = 300.f;
    self.policyTableView.rowHeight = UITableViewAutomaticDimension;
    [self loadDepartmentView];
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
    if (self.btnPolicyLibrary.selected == YES){
        [self.viewModel policySearchWithKeywords:nil department:nil cat_id:nil location:self.region type:@(1) page:@(self.pageIndex)];
    }else{
        [self.viewModel fetchPolicyListWithId:@(self.catId) page:@(self.pageIndex)];
        
    }
    
}

-(void)loadDepartmentView{
    CLLocation *loc = [UserDefaults readUserDefaultObjectValueForKey:@"mtlocation"];
    self.longitude = loc.coordinate.longitude;
    self.latitude = loc.coordinate.latitude;
    //    [AMapServices sharedServices].apiKey = @"12e7ad1902170cc305ca89dcfaeb5d66";
    //
    //    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    //    [AMapServices sharedServices].enableHTTPS = YES;
    //
    //    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 296)];
    //
    
    _mapView.zoomLevel = 13;
    
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
//    if (arr.count > 1) {
//        self.longitude = [arr[0] doubleValue];
//        self.latitude = [arr[1] doubleValue];
        //        104.08244,30.658792
        //        _mapView.centerCoordinate = CLLocationCoordinate2DMake(30.658792, 104.08244);
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
//    }
    
    //    ///把地图添加至view
    [self.headerView addSubview:_mapView];
    
    self.departmentInfoView.layer.shadowColor = [UIColor colorWithHexString:@"a4c1f1"].CGColor;
    self.departmentInfoView.layer.shadowOpacity = 0.5f;
    self.departmentInfoView.layer.shadowRadius = 4.f;
    self.departmentInfoView.layer.shadowOffset = CGSizeMake(0,4);
    
    [self.btnPhone setImagePositionWithType:SSImagePositionTypeLeft spacing:10.f];
    
    [self.policyTableView registerNib:[UINib nibWithNibName:@"PolicyListTableViewCell" bundle:nil] forCellReuseIdentifier:@"PolicyListTableViewCell"];
    [self.policyTableView registerNib:[UINib nibWithNibName:@"PolicyRevealTableViewCell" bundle:nil] forCellReuseIdentifier:@"PolicyRevealTableViewCell"];
    
    [self.policyTableView reloadData];
    
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)checkAction:(id)sender {
    QueryPolicyViewController *vc = [[QueryPolicyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)chooseCountryPolicy:(id)sender {
    for (UIView *view in self.view.subviews) {
        if (view.tag > 800) {
            [view removeFromSuperview];
        }
    }
    
    CGRect rect = self.orangeLabel.frame;
    rect.origin.x = 0;
    self.orangeLabel.frame = rect;
    self.catId = 1;
    self.areaTimes = 0;
    self.departmentScrollView.hidden = NO;
    if (self.btnLocalDepartment.selected == YES) {
        DepartmentScreenView *view = [[[NSBundle mainBundle] loadNibNamed:@"DepartmentScreenView" owner:self options:nil] firstObject];
        view.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, self.itemTableView.frame.size.height);
        [view initViewWithData];
        view.tag = 888;
        [view setReChooseAddress:^(NSString *str){
            if ([str integerValue] == 1) {
                [self showAddressScreenView];
            }else{
                [self.btnLocalDepartment setTitle:str forState:UIControlStateNormal];
            }
        }];
        [self.view addSubview:view];
    }
    self.btnLocalDepartment.selected = YES;
    self.btnPolicyLibrary.selected = NO;
//    [self headerRefreshing];
}
-(void)showAddressScreenView{
        for (UIView *view in self.view.subviews) {
            if (view.tag > 800) {
                [view removeFromSuperview];
            }
        }
    //    self.btnPlace.selected = !self.btnPlace.selected;
            ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
            chooseView.tag = 999;
            chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    
            chooseView.showAll = YES;
            [chooseView initViewProvince:self.provinceIndex city:self.cityIndex zone:self.zoneIndex location:self.region];
            //    chooseView.curProvinceIndex = self.provinceIndex;
            //    chooseView.curCityIndex = self.cityIndex;
            //    chooseView.curZoneIndex = self.zoneIndex;
            [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){
    
                //        self.btnPlace.selected = NO;
                if (provinceIndex == -1) {
                    [self.btnLocalDepartment setTitle:@"选择地区" forState:UIControlStateNormal];
                    self.region = @"";
                    [self chooseCountryPolicy:nil];
                }else{
                    self.provinceIndex = provinceIndex;
                    self.cityIndex = CityIndex;
                    self.zoneIndex = ZoneIndex;
                    [self.btnLocalDepartment setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
                    self.region = zoneArr[ZoneIndex][@"Name"];
                    [self headerRefreshing];
                }
                //        self.type = 1;
                [self.btnLocalDepartment setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    
            }];
            [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
                if (zone.length > 0) {
                    [self.btnLocalDepartment setTitle:zone forState:UIControlStateNormal];
                    self.region = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
                }else{
                    if (city.length > 0) {
                        [self.btnLocalDepartment setTitle:city forState:UIControlStateNormal];
    
                        if (province.length > 0) {
                            self.region = [NSString stringWithFormat:@"%@%@",province,city];
                        }else{
                            self.region = [NSString stringWithFormat:@"%@",city];
                        }
                    }else{
                        [self.btnLocalDepartment setTitle:province forState:UIControlStateNormal];
                        self.region = [NSString stringWithFormat:@"%@",province];
                    }
    
                }
    
                //        self.region = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
                //        self.type = 1;
    
//                [self headerRefreshing];
                //        [self.btnPlace setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
            }];
            [chooseView setRemoveBlock:^{
//                [self chooseCountryPolicy:nil];
                
                self.btnLocalDepartment.selected = NO;
            }];
            [self.view addSubview:chooseView];

}
- (IBAction)chooseOtherPolicy:(id)sender {
    self.btnLocalDepartment.selected = NO;
    self.btnPolicyLibrary.selected = YES;
    CGRect rect = self.orangeLabel.frame;
    rect.origin.x = ScreenWidth / 2;
    self.orangeLabel.frame = rect;
    self.departmentScrollView.hidden = YES;
//    self.catId = 2;
//    [self headerRefreshing];
//    for (UIView *view in self.view.subviews) {
//        if (view.tag > 800) {
//            [view removeFromSuperview];
//        }
//    }
////    self.btnPlace.selected = !self.btnPlace.selected;
//    if (self.areaTimes == 0) {
//        self.areaTimes = 1;
////        [self headerRefreshing];
//
//    }else{
//        ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
//        chooseView.tag = 999;
//        chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
//
//        chooseView.showAll = YES;
//        [chooseView initViewProvince:self.provinceIndex city:self.cityIndex zone:self.zoneIndex location:self.region];
//        //    chooseView.curProvinceIndex = self.provinceIndex;
//        //    chooseView.curCityIndex = self.cityIndex;
//        //    chooseView.curZoneIndex = self.zoneIndex;
//        [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){
//
//            //        self.btnPlace.selected = NO;
//            if (provinceIndex == -1) {
//                [self.btnPolicyLibrary setTitle:@"选择地区" forState:UIControlStateNormal];
//                self.region = @"";
//                [self chooseCountryPolicy:nil];
//            }else{
//                self.provinceIndex = provinceIndex;
//                self.cityIndex = CityIndex;
//                self.zoneIndex = ZoneIndex;
//                [self.btnPolicyLibrary setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
//                self.region = zoneArr[ZoneIndex][@"Name"];
//                [self headerRefreshing];
//            }
//            //        self.type = 1;
//            [self.btnPolicyLibrary setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
//
//        }];
//        [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
//            if (zone.length > 0) {
//                [self.btnPolicyLibrary setTitle:zone forState:UIControlStateNormal];
//                self.region = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
//            }else{
//                if (city.length > 0) {
//                    [self.btnPolicyLibrary setTitle:city forState:UIControlStateNormal];
//
//                    if (province.length > 0) {
//                        self.region = [NSString stringWithFormat:@"%@%@",province,city];
//                    }else{
//                        self.region = [NSString stringWithFormat:@"%@",city];
//                    }
//                }else{
//                    [self.btnPolicyLibrary setTitle:province forState:UIControlStateNormal];
//                    self.region = [NSString stringWithFormat:@"%@",province];
//                }
//
//            }
//
//            //        self.region = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
//            //        self.type = 1;
    
//            [self headerRefreshing];
//            //        [self.btnPlace setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
//        }];
//        [chooseView setRemoveBlock:^{
//            [self chooseCountryPolicy:nil];
//            self.btnPolicyLibrary.selected = NO;
//        }];
//        [self.view addSubview:chooseView];
//    }
    
    
}

- (IBAction)callAction:(id)sender {
    NSString *phone = @"8008208820";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:[NSString stringWithFormat:@"%@",phone]
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)collectInfomation:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
//    InfomationCollectViewController *vc = [[InfomationCollectViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)showAlert:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    NSInteger userType = [[UserDefaults readUserDefaultObjectValueForKey:user_type] integerValue];
    if (userType < 2) {
        [self showJGProgressWithMsg:@"您不是退役军人和企业用户哦！"];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"选择申请类型"
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *soliderAction = [UIAlertAction actionWithTitle:@"企业会员申请" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (userType == 2) {
            [self showJGProgressWithMsg:@"请选择对应身份的申请"];
        }else{
            DepartmentAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"DepartmentAlertView" owner:self options:nil] firstObject];
            alertView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            [alertView setSubmitMessageBlock:^(NSString * message) {
                [self showJGProgressWithMsg:@"已提交"];
            }];
            [self.view addSubview:alertView];
        }
    }];
    UIAlertAction *companyAction = [UIAlertAction actionWithTitle:@"退役军人申请" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (userType == 3) {
            [self showJGProgressWithMsg:@"请选择对应身份的申请"];
        }else{
            DepartmentAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"DepartmentAlertView" owner:self options:nil] firstObject];
            alertView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            [alertView setSubmitMessageBlock:^(NSString * message) {
                [self showJGProgressWithMsg:@"已提交"];
            }];
            [self.view addSubview:alertView];
        }
    }];
    
    [alertController addAction:soliderAction];
    [alertController addAction:companyAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (IBAction)applyPolicy:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    NSInteger userType = [[UserDefaults readUserDefaultObjectValueForKey:user_type] integerValue];
    if (userType < 2) {
        [self showJGProgressWithMsg:@"您不是退役军人和企业用户哦！"];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"选择申请类型"
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *soliderAction = [UIAlertAction actionWithTitle:@"企业会员申请" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (userType == 2) {
            [self showJGProgressWithMsg:@"请选择对应身份的申请"];
        }else{
        [self showJGProgressWithMsg:@"申请已提交"];
        }
    }];
    UIAlertAction *companyAction = [UIAlertAction actionWithTitle:@"退役军人申请" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (userType == 3) {
            [self showJGProgressWithMsg:@"请选择对应身份的申请"];
        }else{
            [self showJGProgressWithMsg:@"申请已提交"];
        }
    }];
    
    [alertController addAction:soliderAction];
    [alertController addAction:companyAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}




#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.policyTableView){
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.policyTableView){
        return 3;
    }
    return self.itemArr.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == self.itemTableView) {
        PolicyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PolicyListTableViewCell"];
        [cell initCellWithModel:self.itemArr[indexPath.row]];
        return cell;
    }
    if (indexPath.section == 0) {
        PolicyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PolicyListTableViewCell"];
        if (self.itemArr.count > 3) {
            [cell initCellWithModel:self.itemArr[indexPath.row]];
        }
        return cell;
    }
    
    PolicyRevealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PolicyRevealTableViewCell"];
    return cell;
    
}
#pragma mark - UITableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 110.f;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.policyTableView) {
        return 45.f;
    }
    return 0.00001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.00001f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (tableView == self.policyTableView) {
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, ScreenWidth - 20, 35)];
        if (section == 0) {
            introLabel.text = @"推荐最新政策";
        }else{
            introLabel.text = @"政务展示";
        }
        introLabel.textColor = [UIColor colorWithHexString:@"000000"];
        introLabel.font = [UIFont systemFontOfSize:18];
    
        [view addSubview:introLabel];
        
    }
    view.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    return view;
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PolicyDetailViewController *vc = [[PolicyDetailViewController alloc]init];
    PolicyModel *model = self.itemArr[indexPath.row];
    vc.policyId = model.article_id;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.policyTableView) {
        if (indexPath.section == 0) {
            if (self.times > 3) {
                self.policyHeight = 0;
                self.times = 1;
            }
            NSLog(@"time = %ld\n height = %f",(long)self.times,self.policyHeight);
            
            CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
            self.policyHeight += rect.size.height;
            self.times += 1;
            self.bgViewHeight.constant = 450 + self.policyHeight + 90 + 270;
            CGRect rectPolicy = self.policyTableView.frame;
            rectPolicy.size.height = self.policyHeight + 360;
            self.policyTableView.frame = rectPolicy;
            NSLog(@"constant = %f\n tableH = %f",self.bgViewHeight.constant,self.policyHeight);
        }
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
