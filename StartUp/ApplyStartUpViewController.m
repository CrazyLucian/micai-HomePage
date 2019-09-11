//
//  ApplyStartUpViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/3.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "ApplyStartUpViewController.h"
#import "ApplyHeaderTableViewCell.h"
#import "ApplyBaseInfoTableViewCell.h"
#import "ApplyTextTableViewCell.h"
#import "EditTextInfoViewController.h"
#import "EditBaseInfoViewController.h"
#import "ApplyModel.h"
@interface ApplyStartUpViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) ApplyModel *applyModel;
@property (nonatomic, retain) UIImage *headImg;
@end

@implementation ApplyStartUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.applyModel = [[ApplyModel alloc] init];
    self.applyModel.experience =  @"请填写个人经历";
    self.applyModel.advantage =  @"请填写个人优势";
    self.applyModel.trainOfThought =  @"请填写创业思路";
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ApplyHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApplyHeaderTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ApplyBaseInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApplyBaseInfoTableViewCell"];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ApplyTextTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApplyTextTableViewCell"];
    self.itemTableView.estimatedRowHeight = 88.f;
    self.itemTableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
//


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 3){
//        return self.resumeModel.work.count;
//    }
//    if( section == 4) {
//        return self.resumeModel.educations.count;
//    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ApplyHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplyHeaderTableViewCell"];
        [cell initCellWithImg:self.headImg];
//        [cell initCellWithModexl:self.resumeModel];
        return cell;
    }else if (indexPath.section == 1){
        ApplyBaseInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplyBaseInfoTableViewCell"];
        [cell initCellWithModel:self.applyModel];
//        [cell initCellWithModel:self.resumeModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
        ApplyTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplyTextTableViewCell"];
    if (indexPath.section == 2) {
        [cell initCellWithString:self.applyModel.experience];
    }else if (indexPath.section == 3){
        [cell initCellWithString:self.applyModel.advantage];
    }else{
        [cell initCellWithString:self.applyModel.trainOfThought];
    }
//        [cell initCellWithModel:self.resumeModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
        UILabel *orangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 2, 16)];
        orangeLabel.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
        [headView addSubview:orangeLabel];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 70, 16)];
        switch (section) {
            case 0:
                titleLabel.text = @"添加头像";
                break;
            case 1:
                titleLabel.text = @"基本信息";
                break;
            case 2:
                titleLabel.text = @"个人经历";
                break;
            case 3:
                titleLabel.text = @"个人优势";
                break;
            case 4:
                titleLabel.text = @"创业思路";
                break;
            default:
                break;
        }
        titleLabel.textColor = [UIColor colorWithHexString:@"f26f05"];
        titleLabel.font = [UIFont systemFontOfSize:14];
        [headView addSubview:titleLabel];
//        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, ScreenWidth - 10, 1)];
//        lineLabel.backgroundColor = [UIColor colorWithHexString:@"e0e0e0"];
//        [headView addSubview:lineLabel];
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(ScreenWidth - 70, 5, 60, 20);
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"编辑笔记事手写"] forState:UIControlStateNormal];
        [button setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
        [button addTarget:self action:@selector(editingAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 999 + section;
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitleColor:[UIColor colorWithHexString:@"5d873b"] forState:UIControlStateNormal];
        [headView addSubview:button];
    
    return headView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self chooseHeadImage];
    }
}
-(void)chooseHeadImage{
    UIAlertControllerStyle style = UIAlertControllerStyleAlert;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        style = UIAlertControllerStyleAlert;
    }else{
        style = UIAlertControllerStyleActionSheet;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:style];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadImg:UIImagePickerControllerSourceTypeCamera];
        
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"相册" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadImg:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }]];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    
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
-(void)editingAction:(UIButton *)btn{
    if (btn.tag - 999 == 0) {
        [self chooseHeadImage];
    }
    if (btn.tag - 999 == 1) {
        EditBaseInfoViewController *vc = [[EditBaseInfoViewController alloc] init];
        vc.model = self.applyModel;
        [vc setReturnApplyModel:^(ApplyModel *model) {
            self.applyModel.healthy = model.healthy;
            self.applyModel.power = model.power;
            [self.itemTableView reloadData];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag - 999];
            [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (btn.tag - 999 == 2) {
        EditTextInfoViewController *vc = [[EditTextInfoViewController alloc] init];
        vc.titleStr = @"个人经历";
        vc.text = self.applyModel.experience;
        [vc setReturnTextBlock:^(NSString * text) {
            self.applyModel.experience = text;
            [self.itemTableView reloadData];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag - 999];
            [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (btn.tag - 999 == 3) {
        EditTextInfoViewController *vc = [[EditTextInfoViewController alloc] init];
        vc.titleStr = @"个人优势";
        vc.text = self.applyModel.advantage;
        [vc setReturnTextBlock:^(NSString * text) {
            self.applyModel.advantage = text;
            [self.itemTableView reloadData];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag - 999];
            [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (btn.tag - 999 == 4) {
        EditTextInfoViewController *vc = [[EditTextInfoViewController alloc] init];
        vc.titleStr = @"创业思路";
        vc.text = self.applyModel.trainOfThought;
        [vc setReturnTextBlock:^(NSString * text) {
            self.applyModel.trainOfThought = text;
            [self.itemTableView reloadData];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:btn.tag - 999];
            [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }

}
-(void)updateResume{
//    NSString *movie = self.resumeModel.movie;
//    if (movie.length < 10) {
//        if (!self.videoData) {
//            [self showJGProgressWithMsg:@"请上传视频"];
//            return;
//        }
//    }
//    ResumeViewModel *viewModel = [[ResumeViewModel alloc] init];
//    [viewModel setBlockWithReturnBlock:^(id returnValue) {
//        [self dissJGProgressLoadingWithTag:200];
//        if ([returnValue integerValue] == 1) {
//            [self showJGProgressWithMsg:@"编辑成功"];
//            [self backAction:nil];
//        }else{
//            [self showJGProgressWithMsg:@"编辑成功"];
//            [self backAction:nil];
//        }
//
//    } WithErrorBlock:^(id errorCode) {
//        [self dissJGProgressLoadingWithTag:200];
//        [self showJGProgressWithMsg:errorCode];
//    }];
//    [viewModel updateResumeWithId:self.resumeModel.Id head:self.headImage image:nil name:self.resumeModel.name sex:self.resumeModel.sex education:self.resumeModel.education working_year:self.resumeModel.working_year city:self.resumeModel.city phone:self.resumeModel.phone email:self.resumeModel.email position:self.resumeModel.position region:self.resumeModel.region salary:self.resumeModel.salary content:self.resumeModel.content movie:self.videoData];
//    [self showJGProgressLoadingWithTag:200];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    //
    //获取用户选择或拍摄的是照片还是视频
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        //    __weak typeof(self) weakSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            //        self.iconImageView.image = image;
            
            self.headImg = image;
//            self.resumeModel.head = @[image];
//            ResumeViewModel *viewModel = [[ResumeViewModel alloc] init];
//            [viewModel setBlockWithReturnBlock:^(id returnValue) {
//                [self dissJGProgressLoadingWithTag:200];
//                if ([returnValue integerValue] == 1) {
//                    [self showJGProgressWithMsg:@"编辑成功"];
//                    [self backAction:nil];
//                }else{
//                    [self showJGProgressWithMsg:@"编辑成功"];
//                    [self backAction:nil];
//                }
//
//            } WithErrorBlock:^(id errorCode) {
//                [self dissJGProgressLoadingWithTag:200];
//                [self showJGProgressWithMsg:errorCode];
//            }];
//            [viewModel updateResumeWithId:self.resumeModel.Id head:image image:nil name:nil sex:nil education:nil working_year:nil city:nil phone:nil email:nil position:nil region:nil salary:nil content:nil movie:nil];
//            [self showJGProgressLoadingWithTag:200];
            //            [self.resumeTableView reloadData];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.itemTableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
//                        [self.btnUploadImg setBackgroundImage:image forState:UIControlStateNormal];
//                    [weakSelf.imageArray addObject:image];
//                    [weakSelf initScrollView];
            
        }];
    }
    
   
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)submitAction:(id)sender {
    [self showJGProgressWithMsg:@"提交成功"];
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
