//
//  PublishStartUpViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/25.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PublishStartUpViewController.h"
#import "FillIntroduceViewController.h"
#import "JobWelfareViewController.h"
#import "H_Single_PickerView.h"
#import "H_PCZ_PickerView.h"
#import "StartUpViewModel.h"
#import "CheckImageViewController.h"
@interface PublishStartUpViewController ()<H_Single_PickerViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UITextFieldDelegate,H_PCZ_PickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtRemark;
@property (weak, nonatomic) IBOutlet UITextField *txtIndustry;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
@property (weak, nonatomic) IBOutlet UITextField *txtArea;
@property (weak, nonatomic) IBOutlet UITextField *txtIntroduce;
@property (weak, nonatomic) IBOutlet UITextField *txtAdvantage;
@property (weak, nonatomic) IBOutlet UIButton *btnPublish;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtKeywords;
@property (weak, nonatomic) IBOutlet UITextField *txtLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) UIImage *startImage;
@property (nonatomic, copy) NSString *introduceStr;
@property (nonatomic, copy) NSString *advantageStr;
@property (nonatomic, retain) NSMutableArray *imageArray;
@property (nonatomic, assign) NSInteger singleType;//0行业  1额度
@end

@implementation PublishStartUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.btnImage setImagePositionWithType:SSImagePositionTypeTop spacing:5.f];
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
- (IBAction)chooseImage:(id)sender {
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

- (IBAction)chooseIndustry:(id)sender {

    StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        H_Single_PickerView *pickerView = [[H_Single_PickerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) arr:returnValue];
        [self.view endEditing:YES];
        pickerView.delegate = self;
        [self.view addSubview:pickerView];
        self.singleType = 0;
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchStartUpIndustry];

}
- (IBAction)chooseAmount:(id)sender {

    H_Single_PickerView *pickerView = [[H_Single_PickerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) arr:@[@{@"name":@"3万以下"},@{@"name":@"3-5万"},@{@"name":@"5-10万"},@{@"name":@"10-20万"},@{@"name":@"20-50万"},@{@"name":@"50万以上"}]];
    [self.view endEditing:YES];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
    self.singleType = 1;
}
- (IBAction)chooseArea:(id)sender {
    H_PCZ_PickerView *pickerView = [[H_PCZ_PickerView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
}
- (IBAction)skipToIntroduce:(id)sender {
    FillIntroduceViewController *vc = [[FillIntroduceViewController alloc] init];
    
    [vc setReturnStrBlock:^(NSString *str) {
        self.txtIntroduce.text = str;
        self.introduceStr = str;
    }];
    vc.defaultStr = self.introduceStr;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)skipToAdVantage:(id)sender {
    FillIntroduceViewController *vc = [[FillIntroduceViewController alloc] init];
    vc.type = 1;
    vc.defaultStr = self.advantageStr;
    [vc setReturnStrBlock:^(NSString *str) {
        self.txtAdvantage.text = str;
        self.advantageStr = str;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)publishAction:(id)sender {

    NSMutableArray *muImgArr = [[NSMutableArray alloc] init];
    if (self.imageArray.count < 2) {
        [self showJGProgressWithMsg:@"请选择图片"];
        return;
    }else{
        [muImgArr addObjectsFromArray:self.imageArray];
    }
    if (self.txtName.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入项目名称"];
        return;
    }
    if (self.txtRemark.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入项目宣传语句"];
        return;
    }
    
    if (![CustomTool isValidtePhone:self.txtPhone.text]) {
        [self showJGProgressWithMsg:@"请输入正确的手机号"];
        return;
    }
    if (self.txtIndustry.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择行业"];
        return;
    }
    if (self.txtAmount.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择额度"];
        return;
    }
    if (self.txtIntroduce.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入项目介绍"];
        return;
    }
    if (self.txtAdvantage.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入加盟优势"];
        return;
    }
    if (self.txtArea.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择区域"];
        return;
    }
    if (self.txtKeywords.text.length == 0) {
        [self showJGProgressWithMsg:@"请输入搜索关键字"];
        return;
    }
    if (self.txtLabel.text.length == 0) {
        [self showJGProgressWithMsg:@"请选择标签"];
        return;
    }
    
    if (muImgArr.count > 0) {
        if(![muImgArr[0] isKindOfClass:[UIImage class]]){
            [muImgArr removeObjectAtIndex:0];
        }
    }
    
    NSArray *strArr = [self.txtKeywords.text componentsSeparatedByString:@" "];
    NSString *key = @"";
    for (int i = 0; i < strArr.count; i ++) {
        key = [key stringByAppendingString:[NSString stringWithFormat:@"%@;",strArr[i]]];
    }
    key = [key stringByAppendingString:[NSString stringWithFormat:@"%@",self.txtLabel.text]];
    NSLog(@"%@",key);
    StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:@"发布成功"];
        [self backAction:nil];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel publishWithImage:muImgArr phone:self.txtPhone.text name:self.txtName.text mark:self.txtRemark.text industry:self.txtIndustry.text money:self.txtAmount.text region:self.txtArea.text description:self.introduceStr advantage:self.advantageStr keywords:key];
    [self showJGProgressLoadingWithTag:200];
}
- (IBAction)chooseLabel:(id)sender {
    JobWelfareViewController *vc = [[JobWelfareViewController alloc] init];
    vc.index = 1;
    [vc setReturnChooseBlock:^(NSString *label) {
        self.txtLabel.text = label;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)SinglePickergetObjectWithArr:(H_Single_PickerView *)_h_Single_PickerView arr:(NSArray *)_arr index:(NSInteger)_index chooseStr:(NSString *)chooseStr chooseId:(NSNumber *)chooseId{
    if (self.singleType == 0) {
        self.txtIndustry.text = chooseStr;
    }else{
        self.txtAmount.text = chooseStr;
    }
}
#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
//    self.startImage = image;
//    self.customImageView.image = image;
        [self.imageArray addObject:image];
        [self initScrollView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - H_PCZ_PickerViewDelegate
-(void)getChooseIndex:(H_PCZ_PickerView *)_myPickerView addressStr:(NSString *)addressStr areaCode:(NSString *)areaCode{
    self.txtArea.text = addressStr;
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
            UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(maigin*(i%4+1)+i % 4 * w, 10*(i/4+1)+i / 4 * w + 10, w, w)];
            backview.tag = 801 + i;
            
            
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(0, 0, w, w);
            [addBtn setImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
            [addBtn setBackgroundColor:[UIColor colorWithHexString:@"f5f5f5"]];
            //            [addBtn setBackgroundImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
            [backview addSubview:addBtn];
            
            
            [self.imageScrollView addSubview:backview];
            
        }
        else{
            
            UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(maigin*(i%4+1)+i % 4 * w, 10*(i/4+1)+i / 4 * w + 10, w, w)];
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
            [self chooseImage:nil];
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
