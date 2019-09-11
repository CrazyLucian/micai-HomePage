//
//  ConfirmOrderViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "PayViewController.h"
#import "ChooseInvoiceViewController.h"
#import "TrainViewModel.h"
@interface ConfirmOrderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnPay;
@property (weak, nonatomic) IBOutlet UIImageView *trainImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@end

@implementation ConfirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnPay.layer.cornerRadius = 4.f;
    self.btnPay.layer.masksToBounds = YES;
    
    if (self.trainModel.thumb.count > 0) {
        [self.trainImage setImageWithString:self.trainModel.thumb[0] placeHoldImageName:@"defaultImage"];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"时间：%@-%@",self.trainModel.start_time,self.trainModel.end_time];
    self.classLabel.text = [NSString stringWithFormat:@"课时：%@",self.trainModel.Class];
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%@",self.trainModel.subscription_price];
    self.priceLabel.text = [NSString stringWithFormat:@"共一件：   小计￥%@",self.trainModel.subscription_price];
    self.allPriceLabel.text = [NSString stringWithFormat:@"合计：￥%@",self.trainModel.subscription_price];
    [self.priceLabel setNumberCustomFontWithStart:0 length:8 fontSize:18 color:@"222222" fontStr:nil];
    [self.allPriceLabel setNumberCustomFontWithStart:0 length:3 fontSize:12 color:@"222222" fontStr:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)chooseBill:(id)sender {
    ChooseInvoiceViewController *vc = [[ChooseInvoiceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)payAction:(id)sender {
    
        PayViewController *vc = [[PayViewController alloc] init];
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
