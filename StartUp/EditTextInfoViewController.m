//
//  EditTextInfoViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/4.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "EditTextInfoViewController.h"

@interface EditTextInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UITextView *txtInfo;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@end

@implementation EditTextInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.titleStr;
    self.placeholderLabel.text = [NSString stringWithFormat:@"请输入%@",self.titleStr];
    self.btnSave.layer.masksToBounds = YES;
    self.btnSave.layer.cornerRadius = 4.f;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)saveAction:(id)sender {
    self.returnTextBlock(self.txtInfo.text);
    [self backAction:nil];
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = YES;
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
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
