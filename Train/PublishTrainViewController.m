//
//  PublishTrainViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/6/26.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PublishTrainViewController.h"
#import "TrainViewModel.h"
#import "ActivityViewModel.h"
#import "WSDatePickerView.h"
#import "H_Single_PickerView.h"
#import "H_PCZ_PickerView.h"
#import "NewsNavModel.h"
#import "CheckImageViewController.h"
@interface PublishTrainViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,H_Single_PickerViewDelegate,H_PCZ_PickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UITextField *txtSchool;
@property (weak, nonatomic) IBOutlet UITextField *txtTime;
@property (weak, nonatomic) IBOutlet UITextField *txtStartTime;
@property (weak, nonatomic) IBOutlet UITextField *txtEndTime;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtType;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtEarnest;
@property (weak, nonatomic) IBOutlet UITextView *txtDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnProtocol;
@property (weak, nonatomic) IBOutlet UIButton *btnPublish;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray *imageArray;
@property (nonatomic, retain) NSNumber *trainCatId;
@end

@implementation PublishTrainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.txtDetail];
    self.imageArray = [[NSMutableArray alloc] init];
    [self.imageArray addObject:@"1"];
    [self initScrollView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)chooseImageViewAction:(id)sender {
    UIAlertControllerStyle style = UIAlertControllerStyleAlert;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        style = UIAlertControllerStyleAlert;
    }else{
        style = UIAlertControllerStyleActionSheet;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:style];
    //添加Button
    //拍照
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadImg:UIImagePickerControllerSourceTypeCamera];
        
    }];
    [alertController addAction:photoAction];
    [photoAction setValue:[UIColor colorWithHexString:@"5d873b"] forKey:@"titleTextColor"];
    
    
    //相册
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle: @"我的相册" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadImg:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }];
    [alertController addAction: pictureAction];
    [pictureAction setValue:[UIColor colorWithHexString:@"5d873b"] forKey:@"titleTextColor"];
    
    //取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil];
    [alertController addAction: cancelAction];
    [cancelAction setValue:[UIColor colorWithHexString:@"5d873b"] forKey:@"titleTextColor"];
    
    
    [self presentViewController: alertController animated: YES completion: nil];
}
- (void)uploadImg:(UIImagePickerControllerSourceType)xtype{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = xtype;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}

- (UIImage *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    while (dataKBytes > size && maxQuality > 0.01f) {
        maxQuality = maxQuality - 0.01f;
        data = UIImageJPEGRepresentation(image, maxQuality);
        dataKBytes = data.length / 1000.0;
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    return [UIImage imageWithData:data];
}

- (IBAction)publishAction:(id)sender {
    NSMutableArray *muImgArr = [[NSMutableArray alloc] init];
    if (self.imageArray.count < 2) {
        [self showJGProgressWithMsg:@"请选择图片"];
        return;
    }else{
        [muImgArr addObjectsFromArray:self.imageArray];
    }
    if (self.txtTitle.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入培训标题"];
        return;
    }
    if (self.txtSchool.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入培训学校"];
        return;
    }
    if (self.txtTime.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入培训课时"];
        return;
    }
    if (self.txtStartTime.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择开始时间"];
        return;
    }
    
    if (self.txtEndTime.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择结束时间"];
        return;
    }
    if (self.btnProtocol.selected == NO) {
        [self showJGProgressWithMsg:@"请同意迷彩服务协议"];
        return;
    }
    if (self.txtLocation.text.length > 0) {
        if (self.txtAddress.text.length == 0) {
            [self showJGProgressWithMsg:@"请选择区域"];
            return;
        }
    }
    if (self.txtAddress.text.length > 0) {
        if (self.txtLocation.text.length == 0) {
            [self showJGProgressWithMsg:@"请填写详细地址"];
            return;
        }
    }
    if (self.txtType.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择行业"];
        return;
    }
    if (self.txtPrice.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入培训费用"];
        return;
    }
    if (self.txtEarnest.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入定金"];
        return;
    }
    if (self.txtDetail.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入课程详情"];
        return;
    }
    if (muImgArr.count > 0) {
        if(![muImgArr[0] isKindOfClass:[UIImage class]]){
            [muImgArr removeObjectAtIndex:0];
        }
    }
    TrainViewModel *viewModel = [[TrainViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self showJGProgressWithMsg:@"发布成功"];
        [self dissJGProgressLoadingWithTag:200];
//        self.reloadBlock();
        [self backAction:nil];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel publishTrainWithImage:muImgArr title:self.txtTitle.text cat_id:self.trainCatId content:self.txtDetail.text price:self.txtPrice.text start_time:self.txtStartTime.text end_time:self.txtEndTime.text address:self.txtAddress.text school:self.txtSchool.text class:self.txtTime.text subscription_price:self.txtEarnest.text];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)protocolClickAction:(id)sender {
    self.btnProtocol.selected = !self.btnProtocol.selected;
}
- (IBAction)chooseClass:(id)sender {
    
}
- (IBAction)chooseTime:(id)sender {
    NSString *str = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:[NSDate date]]];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay dateStr:str CompleteBlock:^(NSDate *startDate)  {
        NSString *date = [startDate stringWithFormat:@"yyyy-MM-dd"];
        self.txtStartTime.text = date;
    }];
    [self.view endEditing:YES];
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"5d873b"];//确定按钮的颜色
    [datepicker show];
}
- (IBAction)chooeEndTime:(id)sender {
    NSString *str = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:[NSDate date]]];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay dateStr:str CompleteBlock:^(NSDate *startDate)  {
        NSString *date = [startDate stringWithFormat:@"yyyy-MM-dd"];
        self.txtEndTime.text = date;
    }];
    [self.view endEditing:YES];
    //    datepicker.maxLimitDate = [self getNowDateFromatAnDate:[NSDate date]];
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"5d873b"];//确定按钮的颜色
    [datepicker show];
}
- (IBAction)chooseIndustry:(id)sender {
    TrainViewModel *navViewModel = [[TrainViewModel alloc] init];
    [navViewModel setBlockWithReturnBlock:^(id returnValue) {
        NSArray *cate = returnValue;
        NSMutableArray *muarr = [[NSMutableArray alloc] init];
        for (int i = 0; i < cate.count; i ++) {
            NSDictionary *dic = @{@"name":cate[i][@"cat_name"],@"cat_id":cate[i][@"cat_id"]};
            [muarr addObject:dic];
        }
        H_Single_PickerView *pickerView = [[H_Single_PickerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) arr:muarr];
        pickerView.delegate = self;
        
        [self.view endEditing:YES];
        [self.view addSubview:pickerView];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [navViewModel fetchCategory];
}
- (IBAction)chooseAreaAction:(id)sender {
    H_PCZ_PickerView *pickerView = [[H_PCZ_PickerView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.image = image;
    self.topImageView.image = image;
    [self.imageArray addObject:image];
    [self initScrollView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
            }else{
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
            }
            
        }       // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length >= 500) {
            inputTextView.text = [toBeString substringToIndex:500];
            //            self.labelCount.text = [NSString stringWithFormat:@"%lu/1600",(unsigned long)inputTextView.text.length];
        }
    }
}

#pragma mark - H_Single_PickerViewDelegate
-(void)SinglePickergetObjectWithArr:(H_Single_PickerView *)_h_Single_PickerView arr:(NSArray *)_arr index:(NSInteger)_index chooseStr:(NSString *)chooseStr chooseId:(NSNumber *)chooseId{
    
    self.txtType.text = chooseStr;
    self.trainCatId = chooseId;
//    self.catId = chooseId;
    NSLog(@"%@",chooseId);
}
#pragma mark - H_PCZ_PickerViewDelegate
-(void)getChooseIndex:(H_PCZ_PickerView *)_myPickerView addressStr:(NSString *)addressStr areaCode:(NSString *)areaCode{
    self.txtAddress.text = addressStr;
    [self.txtLocation becomeFirstResponder];
    //    self.btnArea.titleLabel.textAlignment = NSTextAlignmentRight;
    //    self.zone_code = [areaCode integerValue];
}
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.txtLocation) {
        if (self.txtAddress.text.length == 0) {
            [self chooseAreaAction:nil];
            return NO;
        }
    }
    return YES;
}
-(void)initScrollView{
    
    for (UIView *subview in self.imageScrollView.subviews) {
        if (subview.tag > 800) {
            [subview removeFromSuperview];
        }
    }
    
    CGFloat w = (ScreenWidth - 100) / 4;
    CGFloat maigin = 20;
    
    for (int i = 0; i < self.imageArray.count; i ++) {
        if (i == 4) {
            return;
        }
        
        if (i == (self.imageArray.count - 1)) {
            UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(maigin*(i%4+1)+i % 4 * w, 10*(i/4+1)+i / 4 * w + 20, w, w)];
            backview.tag = 801 + i;
            
            
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(0, 0, w, w);
            [addBtn setImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
            [addBtn setBackgroundColor:[UIColor colorWithHexString:@"f5f5f5"]];
            //            [addBtn setBackgroundImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(chooseImageViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [backview addSubview:addBtn];
            
            
            [self.imageScrollView addSubview:backview];
            
        }
        else{
            
            UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(maigin*(i%4+1)+i % 4 * w, 10*(i/4+1)+i / 4 * w + 20, w, w)];
            backview.tag = 801 + i;
            backview.backgroundColor = [UIColor whiteColor];
            UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 0, w, w )];
            imgview.image = self.imageArray[i+1];
            
            //            [imgview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseUrl,self.imageUrlArray[i]]] placeholderImage:[UIImage imageNamed:@"bg_no_pictures"]];
            [backview addSubview:imgview];
            //            if ([self.imageUrlArray[i] isEqualToString:self.showImgUrl]) {
            //
            //
            //                UILabel *label = [[UILabel alloc] init];
            //                label.frame = CGRectMake(5, 5, 30, 12);
            //                label.text = @"封面";
            //                label.font = [UIFont systemFontOfSize:10];
            //                label.textAlignment = NSTextAlignmentCenter;
            //                label.layer.masksToBounds = YES;
            //                label.layer.cornerRadius = 6.f;
            //
            //                label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            //                [backview addSubview:label];
            //
            //            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgAction:)];
            [backview addGestureRecognizer:tap];
            
            //            CGRect backRect = backview.frame;
            //            UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            //            [delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 44 - 20, 44 - 27, 0)];
            //            delBtn.frame = CGRectMake(backRect.origin.x + backRect.size.width - 34.f, backRect.origin.y - 15, 44, 44);
            //
            //            delBtn.tag = 801 + i;
            //            [delBtn setImage:[UIImage imageNamed:@"icon_cancel1"] forState:UIControlStateNormal];
            //            [delBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.imageScrollView addSubview:backview];
            //            [self.imageScrollView addSubview:delBtn];
        }
    }
}
-(void)tapImgAction:(UITapGestureRecognizer *)button{
    CheckImageViewController *vc = [[CheckImageViewController alloc] init];
    
    vc.image = self.imageArray[button.view.tag - 800];
    
    [vc setReturnDeleteBlcok:^{
        if (self.imageArray.count > 1) {
            [self.imageArray removeObjectAtIndex:button.view.tag - 800];
        }else{
            //            [self.imageUrlArray removeObjectAtIndex:button.view.tag - 801];
            [self chooseImageViewAction:nil];
        }
        [self initScrollView];
    }];
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
