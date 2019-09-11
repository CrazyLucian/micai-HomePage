//
//  InvoiceUpdateViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "InvoiceUpdateViewController.h"
#import "TrainViewModel.h"
@interface InvoiceUpdateViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCompany;
@property (weak, nonatomic) IBOutlet UIButton *btnPersonal;
@property (weak, nonatomic) IBOutlet UIButton *btnIsDefault;
@property (weak, nonatomic) IBOutlet UIView *personalView;
@property (weak, nonatomic) IBOutlet UIView *companyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtBank;
@property (weak, nonatomic) IBOutlet UITextField *txtAccount;
@property (weak, nonatomic) IBOutlet UITextField *txtTitleName;

@end

@implementation InvoiceUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.invoiceModel.is_default integerValue] == 1) {
        self.btnIsDefault.selected = YES;
        
    }
    if ([self.invoiceModel.invoice_type integerValue] == 2) {
        self.btnCompany.selected = YES;
        self.txtTitle.text = self.invoiceModel.invoice_title;
        self.txtNumber.text = self.invoiceModel.invoice_num;
        self.txtPhone.text = self.invoiceModel.invoice_mobile;
        self.txtAddress.text = self.invoiceModel.invoice_address;
        self.txtAccount.text = self.invoiceModel.invoice_account;
        self.txtBank.text = self.invoiceModel.invoice_bank;
    }else{
        self.btnPersonal.selected = YES;
        self.txtTitleName.text = self.invoiceModel.invoice_title;
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)deleteAction:(id)sender {
    
}
- (IBAction)chooseIsDefault:(id)sender {
    self.btnIsDefault.selected = !self.btnIsDefault.selected;
}
- (IBAction)choosePersonal:(id)sender {
    self.btnPersonal.selected = YES;
    self.btnCompany.selected = NO;
    self.bgViewHeight.constant = 144 - 49;
    self.personalView.hidden = NO;
    self.companyView.hidden = YES;
}
- (IBAction)chooseCompany:(id)sender {
    self.btnPersonal.selected = NO;
    self.btnCompany.selected = YES;
    self.bgViewHeight.constant = 336;
    self.personalView.hidden = YES;
    self.companyView.hidden = NO;
}
- (IBAction)saveAction:(id)sender {
    int type = 1;
    NSString *title = self.txtTitleName.text;
    if (self.btnCompany.selected == YES) {
        type = 2;
        title = self.txtTitle.text;
    }
    TrainViewModel *viewModel = [[TrainViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        self.returnReloadBlock();
        [self backAction:nil];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel editAddInvoiceWithInvoice_type:@(type) invoice_title:title invoice_num:self.txtNumber.text invoice_address:self.txtAddress.text invoice_mobile:self.txtPhone.text invoice_bank:self.txtBank.text invoice_account:self.txtAccount.text is_default:@(self.btnIsDefault.selected) invoiceId:self.invoiceModel.invoice_id];
    [self showJGProgressLoadingWithTag:200];
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
