//
//  ChooseInvoiceViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "ChooseInvoiceViewController.h"
#import "InvoiceManageViewController.h"
#import "PayInvoiceTableViewCell.h"
#import "TrainViewModel.h"
@interface ChooseInvoiceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UIView *personalView;
@property (weak, nonatomic) IBOutlet UIView *companyView;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnCompany;
@property (weak, nonatomic) IBOutlet UIButton *btnPersonal;
@property (weak, nonatomic) IBOutlet UIButton *btnIsDefault;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtBank;
@property (weak, nonatomic) IBOutlet UITextField *txtAccount;
@property (weak, nonatomic) IBOutlet UITextField *txtTitleName;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, retain) TrainViewModel *viewModel;
@property (nonatomic, retain) NSMutableArray *itemArr;
@end

@implementation ChooseInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"PayInvoiceTableViewCell" bundle:nil] forCellReuseIdentifier:@"PayInvoiceTableViewCell"];
    self.viewModel = [[TrainViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        [weakSelf.itemTableView.mj_header endRefreshing];
        [weakSelf.itemArr removeAllObjects];
        [weakSelf.itemArr addObjectsFromArray:returnValue];
        if (weakSelf.itemArr.count > 0) {
//            self.messageLabel
        }
        [weakSelf.itemTableView reloadData];
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

    [self.viewModel fetchUserInvoiceWithInvoiceId:nil];
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)skipToManage:(id)sender {
    InvoiceManageViewController *vc = [[InvoiceManageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)addAction:(id)sender {
    int type = 1;
    NSString *title = self.txtTitleName.text;
    if (self.btnCompany.selected == YES) {
        type = 2;
        title = self.txtTitle.text;
    }
    TrainViewModel *viewModel = [[TrainViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        [self headerRefreshing];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel editAddInvoiceWithInvoice_type:@(type) invoice_title:title invoice_num:self.txtNumber.text invoice_address:self.txtAddress.text invoice_mobile:self.txtPhone.text invoice_bank:self.txtBank.text invoice_account:self.txtAccount.text is_default:@(self.btnIsDefault.selected) invoiceId:nil];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)chooseIsDefault:(id)sender {
    self.btnIsDefault.selected = !self.btnIsDefault.selected;
}
- (IBAction)choosePersonal:(id)sender {
    self.btnPersonal.selected = YES;
    self.btnCompany.selected = NO;
    self.bgViewHeight.constant = 144;
    self.personalView.hidden = NO;
    self.companyView.hidden = YES;
}
- (IBAction)chooseCompany:(id)sender {
    self.btnPersonal.selected = NO;
    self.btnCompany.selected = YES;
    self.bgViewHeight.constant = 385;
    self.personalView.hidden = YES;
    self.companyView.hidden = NO;
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
    
    PayInvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayInvoiceTableViewCell"];
    [cell initCellWithModel:self.itemArr[indexPath.row]];
    return cell;
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.f;
}


//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    TrainDetailViewController *vc = [[TrainDetailViewController alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
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
