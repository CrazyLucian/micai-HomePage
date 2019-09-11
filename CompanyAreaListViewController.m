//
//  CompanyAreaListViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/10.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "CompanyAreaListViewController.h"

@interface CompanyAreaListViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *txtContent;

@end

@implementation CompanyAreaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.txtContent];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)submitAction:(id)sender {
    [self showJGProgressWithMsg:@"已提交"];
}
- (void)textFiledEditChanged:(NSNotification *)obj
{
    UITextView *inputTextView = (UITextView *)obj.object;
    NSString *toBeString = inputTextView.text;
    if (toBeString.length > 0) {
        self.placeHolderLabel.hidden = YES;
    }else{
        
        self.placeHolderLabel.hidden = NO;
    }
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [inputTextView markedTextRange];       //获取高亮部分
        UITextPosition *position = [inputTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 500) {
                inputTextView.text = [toBeString substringToIndex:500];
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)inputTextView.text.length];
            }
        }       // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length >= 500) {
            inputTextView.text = [toBeString substringToIndex:500];
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
