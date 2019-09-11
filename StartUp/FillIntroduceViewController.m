//
//  FillIntroduceViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/25.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "FillIntroduceViewController.h"

@interface FillIntroduceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation FillIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == 1) {
        self.titleLabel.text = @"加盟优势";
        self.placeHolderLabel.text = @"请输入加盟优势";
    }
    self.txtContent.text = self.defaultStr;

    if (self.txtContent.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
    }else{
        self.placeHolderLabel.hidden = NO;
    }
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 4.f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.txtContent];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be  recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)doneAction:(id)sender {
    self.returnStrBlock(self.txtContent.text);
    [self backAction:nil];
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
            if (toBeString.length >= 1000) {
                inputTextView.text = [toBeString substringToIndex:1000];
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
            }else{
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
            }
            
        }       // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length >= 1000) {
            inputTextView.text = [toBeString substringToIndex:1000];
            //            self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
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
