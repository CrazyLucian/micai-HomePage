//
//  TrainListViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "TrainListViewController.h"
#import "TrainDetailViewController.h"
#import "ChooseCityViewController.h"
#import "SearchTrainViewController.h"
#import "TrainListTableViewCell.h"
#import "PayViewController.h"
#import "TrainViewModel.h"
#import "SingleChooseListView.h"
#import "AreaScreenView.h"
#import "ProvinceCityZoneView.h"

@interface TrainListViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnArea;
@property (weak, nonatomic) IBOutlet UIButton *btnTrade;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) TrainViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *cateArr;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger catId;
@property (nonatomic, assign) NSInteger currentTypeIndex;
@property (nonatomic, copy) NSString *cityStr;
@property (nonatomic, copy) NSString *choosedStr;
@property (nonatomic, assign) NSInteger provinceIndex;
@property (nonatomic, assign) NSInteger cityIndex;
@property (nonatomic, assign) NSInteger zoneIndex;
@end

@implementation TrainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    self.cateArr = [[NSMutableArray alloc] init];
    
    NSString *str = [UserDefaults readUserDefaultObjectValueForKey:location_city];
    if (str) {
        self.cityStr = str;
        [self.btnArea setTitle:self.cityStr forState:UIControlStateNormal];
    }else{
        self.cityStr = @"";
        [self.btnArea setTitle:@"全部" forState:UIControlStateNormal];
    }
    self.provinceIndex = 0;
    self.cityIndex = 0;
    self.zoneIndex = 0;
    
    [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:10.f];
    [self.btnTrade setImagePositionWithType:SSImagePositionTypeRight spacing:10.f];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"TrainListTableViewCell" bundle:nil] forCellReuseIdentifier:@"TrainListTableViewCell"];
    self.itemTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewModel = [[TrainViewModel alloc] init];
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
    if (self.cateArr.count == 0) {
        TrainViewModel *navViewModel = [[TrainViewModel alloc] init];
        [navViewModel setBlockWithReturnBlock:^(id returnValue) {
            [self.cateArr removeAllObjects];
            [self.cateArr addObject:@{@"cat_id":@"-1",@"cat_name":@"全部"}];
            [self.cateArr addObjectsFromArray:returnValue];
        } WithErrorBlock:^(id errorCode) {
            [self showJGProgressWithMsg:errorCode];
        }];
        [navViewModel fetchCategory];
    }
    if ([self.cityStr isEqualToString:@"全国"]) {
        [self.viewModel fetchTrainListWithId:@(self.catId) address:nil page:@(self.pageIndex) keywords:nil];
    }else{
        [self.viewModel fetchTrainListWithId:@(self.catId) address:self.cityStr page:@(self.pageIndex) keywords:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchAction:(id)sender {
    SearchTrainViewController *vc = [[SearchTrainViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}

- (IBAction)chooseTradeAction:(id)sender {
//    self.btnMore.selected = YES;
//    self.btnMoney.selected = NO;
//    self.btnAddress.selected = NO;
    
    for (UIView *view in self.view.subviews) {
        if (view.tag > 800) {
            [view removeFromSuperview];
        }
    }
    if (self.btnTrade.selected == YES) {
        self.btnTrade.selected = !self.btnTrade.selected;
        return;
    }
    self.btnTrade.selected = !self.btnTrade.selected;
    
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
    SingleChooseListView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"SingleChooseListView" owner:self options:nil] firstObject];
    chooseView.tag = 997;
    chooseView.currentSelectIndex = self.currentTypeIndex;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    chooseView.selectedBtnImgStr = @"icon_tick";
    chooseView.colorStr = @"f26f05";
    [chooseView initView:self.cateArr];
    [chooseView setReturnBlock:^(NSInteger index,NSArray *itemArr){
        if (index == 0) {
            self.catId = 0;
            [self.btnTrade setTitle:@"培训类别" forState:UIControlStateNormal];
        }else{
            self.catId = [self.cateArr[index][@"cat_id"] integerValue];
            [self.btnTrade setTitle:self.cateArr[index][@"cat_name"] forState:UIControlStateNormal];
        }
        self.currentTypeIndex = index;
        [self.btnTrade setImagePositionWithType:SSImagePositionTypeRight spacing:3.f];
        [self headerRefreshing];
        self.btnTrade.selected = NO;
    }];
    [chooseView setRemoveBlock:^{
        self.btnTrade.selected = NO;
        //        self.priceBtn.selected = NO;
    }];
    [self.view addSubview:chooseView];
}
- (IBAction)chooseAreaAction:(id)sender {
//    self.btnArea.selected = NO;
//    self.btnTrade.selected = YES;
//
//    for (UIView *view in self.view.subviews) {
//        if (view.tag > 800) {
//            [view removeFromSuperview];
//        }
//    }
//
//    if (self.cityStr.length == 0) {
//        ChooseCityViewController *vc = [[ChooseCityViewController alloc] init];
//        [vc setReloadViewBlock:^(NSString *cityStr) {
//            self.cityStr = cityStr;
//            [self showScreenCity];
//        }];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        [self showScreenCity];
//    }
    for (UIView *view in self.view.subviews) {
        if (view.tag > 800) {
            [view removeFromSuperview];
        }
    }
    self.btnArea.selected = !self.btnArea.selected;
    if (self.btnArea.selected == NO) {
        return;
    }
    
    ProvinceCityZoneView *chooseView = [[[NSBundle mainBundle] loadNibNamed:@"ProvinceCityZoneView" owner:self options:nil] firstObject];
    chooseView.tag = 999;
    chooseView.frame = CGRectMake(0, self.itemTableView.frame.origin.y, ScreenWidth, ScreenHeight - self.itemTableView.frame.origin.y + 10);
    
    chooseView.showAll = YES;
    [chooseView initViewProvince:self.provinceIndex city:self.cityIndex zone:self.zoneIndex location:self.cityStr];
    //    chooseView.curProvinceIndex = self.provinceIndex;
    //    chooseView.curCityIndex = self.cityIndex;
    //    chooseView.curZoneIndex = self.zoneIndex;
    [chooseView setReturnBlock:^(NSInteger provinceIndex,NSInteger CityIndex,NSInteger ZoneIndex,NSArray *zoneArr){
        
        self.btnArea.selected = NO;
        if (provinceIndex == -1) {
            [self.btnArea setTitle:@"全部" forState:UIControlStateNormal];
                        self.cityStr = @"";
        }else{
            self.provinceIndex = provinceIndex;
            self.cityIndex = CityIndex;
            self.zoneIndex = ZoneIndex;
            self.cityStr = zoneArr[ZoneIndex][@"Name"];
            [self.btnArea setTitle:zoneArr[ZoneIndex][@"Name"] forState:UIControlStateNormal];
            //            self.region = zoneArr[ZoneIndex][@"Name"];
        }
        //        self.type = 1;
        self.btnArea.selected = NO;
        [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        [self headerRefreshing];
    }];
    [chooseView setReturnAreaBlock:^(NSString *province, NSString *city, NSString *zone) {
        if (zone.length > 0) {
            [self.btnArea setTitle:zone forState:UIControlStateNormal];
            self.cityStr = [NSString stringWithFormat:@"%@%@%@",province,city,zone];
        }else{
            if (city.length > 0) {
                [self.btnArea setTitle:city forState:UIControlStateNormal];
                
                if (province.length > 0) {
                    self.cityStr = [NSString stringWithFormat:@"%@%@",province,city];
                }else{
                    self.cityStr = [NSString stringWithFormat:@"%@",city];
                }
            }else{
                [self.btnArea setTitle:province forState:UIControlStateNormal];
                self.cityStr = [NSString stringWithFormat:@"%@",province];
            }
        }
        self.btnArea.selected = NO;
        [self headerRefreshing];
        [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
    }];
    [chooseView setRemoveBlock:^{
        self.btnArea.selected = NO;
    }];
    [self.view addSubview:chooseView];
}
-(void)showScreenCity{
    AreaScreenView *screenView = [[[NSBundle mainBundle] loadNibNamed:@"AreaScreenView" owner:self options:nil] firstObject];
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
//                self.type = 0;
                [self headerRefreshing];
                [self.btnArea setTitle:@"全部" forState:UIControlStateNormal];
            }else{
                //                [self.btnAddress setTitle:self.cityStr forState:UIControlStateSelected];
//                self.searchKey = self.cityStr;
//                self.type = 2;
                [self headerRefreshing];
                [self.btnArea setTitle:self.cityStr forState:UIControlStateNormal];
            }
            
            
        }else{
//            self.searchKey = choosedStr;
//            self.type = 2;
            [self headerRefreshing];
            self.choosedStr = choosedStr;
            [self.btnArea setTitle:choosedStr forState:UIControlStateNormal];
            //        [self.btnAddress setTitle:choosedStr forState:UIControlStateSelected];
            [self.btnArea setImagePositionWithType:SSImagePositionTypeRight spacing:5.f];
        }
        
        [backView removeFromSuperview];
    }];
    [screenView setCancelBlock:^{
        [backView removeFromSuperview];
    }];
}
//当前页面不在导航控制器中，需重写preferredStatusBarStyle，如下：

-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent; //白色
    
    //    return UIStatusBarStyleDefault; //黑色
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TrainListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrainListTableViewCell"];
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
    TrainDetailViewController *vc = [[TrainDetailViewController alloc]init];
    TrainModel *model = self.itemArr[indexPath.row];
    vc.cateId = model.train_id;
    [self.navigationController pushViewController:vc animated:YES];
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
