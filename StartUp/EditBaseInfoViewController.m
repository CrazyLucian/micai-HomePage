//
//  EditBaseInfoViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/4.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "EditBaseInfoViewController.h"
#import "H_Single_PickerView.h"
@interface EditBaseInfoViewController ()<H_Single_PickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtPower;
@property (weak, nonatomic) IBOutlet UIButton *btnHealthy;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@end

@implementation EditBaseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)chooseHealthy:(id)sender {
    H_Single_PickerView *pickerView = [[H_Single_PickerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) arr:@[@{@"name":@"良好"},@{@"name":@"健康"},@{@"name":@"很好"}]];
    //    ,@{@"name":@"博士"}
    pickerView.delegate = self;
    [self.view endEditing:YES];
    [self.view addSubview:pickerView];
}
- (IBAction)saveAction:(id)sender {
    self.model.power = self.txtPower.text;
    self.model.healthy = self.btnHealthy.titleLabel.text;
    self.returnApplyModel(self.model);
    [self backAction:sender];
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
#pragma mark - H_Single_PickerViewDelegate
-(void)SinglePickergetObjectWithArr:(H_Single_PickerView *)_h_Single_PickerView arr:(NSArray *)_arr index:(NSInteger)_index chooseStr:(NSString *)chooseStr chooseId:(NSNumber *)chooseId{
    
    [self.btnHealthy setTitle:chooseStr forState:UIControlStateNormal];
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
