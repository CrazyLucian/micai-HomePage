//
//  InfomationCollectViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/9.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "InfomationCollectViewController.h"
#import "CollectImageTableViewCell.h"
#import "FetchVideoViewController.h"
#import "UploadModel.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#define VIDEOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCache"]
enum {
    DirectPlayBtnTag = 10,
    FullScreenPlayBtnTag
};
@interface InfomationCollectViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UITextViewDelegate>
{
    NSMutableArray *sectionOneArray;
    NSMutableArray *sectionTwoArray;
    NSMutableArray *sectionThreeArray;
    NSMutableArray *sectionFourArray;
}
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, retain) UIImage *videoImage;
@property (nonatomic, retain) UIImage *headImage;
@property (nonatomic, retain) NSData *videoData;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, retain) NSURL *videoPath;
@end

@implementation InfomationCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageArray = [[NSMutableArray alloc] init];
    sectionOneArray = [[NSMutableArray alloc] init];
    sectionTwoArray = [[NSMutableArray alloc] init];
    sectionThreeArray = [[NSMutableArray alloc] init];
    sectionFourArray = [[NSMutableArray alloc] init];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"CollectImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"CollectImageTableViewCell"];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)confirmAction:(id)sender {
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectImageTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 1:
            [cell initCellFromArray:sectionOneArray];
            break;
        case 2:
            [cell initCellFromArray:sectionTwoArray];
            break;
        case 3:
            [cell initCellFromArray:sectionThreeArray];
            break;
        case 5:
            [cell initCellFromArray:sectionFourArray];
            break;
        default:
            break;
    }
    return cell;
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section == 4) {
        return 0.0001f;
    }
    return 120.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 50.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (section == 0) {
        UITextField *txtInput = [[UITextField alloc] initWithFrame:CGRectMake(45, 5, ScreenWidth - 55, 35)];
        txtInput.placeholder = @"请输入姓名";
        txtInput.textColor = [UIColor colorWithHexString:@"333333"];
        txtInput.font = [UIFont systemFontOfSize:15];
        
        [view addSubview:txtInput];
    }else if (section == 4){
        UITextField *txtInput = [[UITextField alloc] initWithFrame:CGRectMake(45, 5, ScreenWidth - 55, 35)];
        txtInput.placeholder = @"请输入身份证号";
        txtInput.textColor = [UIColor colorWithHexString:@"333333"];
        txtInput.font = [UIFont systemFontOfSize:15];
        
        [view addSubview:txtInput];
    }else{
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, ScreenWidth - 20, 35)];
        introLabel.textColor = [UIColor colorWithHexString:@"333333"];
        introLabel.font = [UIFont systemFontOfSize:15];
        
        
        UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 0, 50, 50)];
        
        photoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [photoBtn setTitleColor:[UIColor colorWithHexString:@"5d873b"] forState:UIControlStateNormal];
        photoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        photoBtn.tag = section + 999;
        [photoBtn addTarget:self action:@selector(takeCamera:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (section) {
            case 1:
                introLabel.text = @"人像采集";
                [photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
                [photoBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                break;
            case 2:
                introLabel.text = @"退役证、荣誉证采集";
                [photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
                [photoBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                break;
            case 3:
                introLabel.text = @"身份证采集";
                [photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
                [photoBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                break;
            case 5:
                introLabel.text = @"个人视频采集";
                [photoBtn setTitle:@"录像" forState:UIControlStateNormal];
                [photoBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        [photoBtn setImagePositionWithType:SSImagePositionTypeLeft spacing:5.f];
        
        [view addSubview:photoBtn];
        [view addSubview:introLabel];
    }
    
        
    UIImageView *headImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
//    headImg.image = [UIImage imageNamed:self.imageArray[section]];
    [view addSubview:headImg];
    view.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    return view;
}

-(void)takeCamera:(UIButton *)button{
    if (button.tag - 999 == 5) {
        FetchVideoViewController *vc = [[FetchVideoViewController alloc] init];
        vc.showLabel = NO;
        [vc setReturnPathBlock:^(NSString *path) {
            [self uploadWithPath:path];
        }];
        //        [self.navigationController presentViewController:vc animated:YES completion:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
    [self uploadImg:UIImagePickerControllerSourceTypeCamera];
    self.currentSection = button.tag - 997;
    }
}
- (void)uploadImg:(UIImagePickerControllerSourceType)xtype{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = xtype;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}
#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //获取用户选择或拍摄的是照片还是视频
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    //            self.activityImage = image;
    //            self.activityImageView.image = image;
    switch (self.currentSection) {
        case 1:
            [sectionOneArray removeAllObjects];
            [sectionOneArray addObject:image];
            break;
        case 2:
            [sectionTwoArray removeAllObjects];
            [sectionTwoArray addObject:image];
            break;
        case 3:
            [sectionThreeArray removeAllObjects];
            [sectionThreeArray addObject:image];
            break;
        default:
            break;
    }
//    self.hasFile = 0;
    //一个section刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:self.currentSection];
    [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        [picker dismissViewControllerAnimated:YES completion:^{
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeVideoAtPathToSavedPhotosAlbum:info[UIImagePickerControllerMediaURL] completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    if (!error) {
                        
                        NSLog(@"视频保存成功");
                    } else {
                        
                        NSLog(@"视频保存失败");
                    }
                }];
                
            }
            //生成视频名称
            NSString *mediaName = [self getVideoNameBaseCurrentTime];
            NSLog(@"mediaName: %@", mediaName);
            
            //将视频存入缓存
            NSLog(@"将视频存入缓存");
            [self saveVideoFromPath:info[UIImagePickerControllerMediaURL] toCachePath:[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]];
            
            
            //创建uploadmodel
            UploadModel *model = [[UploadModel alloc] init];
            
            
            model.path       =        [VIDEOCACHEPATH stringByAppendingPathComponent:mediaName];
            model.name       = mediaName;
            model.type       = @"moive";
            model.isUploaded = NO;
            
            //将model存入待上传数组
            NSURL *videoURL=[info objectForKey:UIImagePickerControllerMediaURL];
            [self convertMovSourceURL:videoURL uploadModel:model];
            [self getVideoPreViewImageWithPath:videoURL];
            [self uploadImageAndMovieBaseModel:model];
            //            [self.uploadArray addObject:model];
            
        }];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)uploadWithPath:(NSString *)path{
    //生成视频名称
    NSString *mediaName = [self getVideoNameBaseCurrentTime];
    NSLog(@"mediaName: %@", mediaName);
    
    //将视频存入缓存
    NSLog(@"将视频存入缓存");
    
    //    [self saveVideoFromPath:path toCachePath:[VIDEOCACHEPATH stringByAppendingPathComponent:mediaName]];
    
    
    //创建uploadmodel
    UploadModel *model = [[UploadModel alloc] init];
    
    
    //    model.path       =        [VIDEOCACHEPATH stringByAppendingPathComponent:mediaName];
    model.path = path;
    model.name       = mediaName;
    model.type       = @"moive";
    model.isUploaded = NO;
    
    //将model存入待上传数组
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    //    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    [self convertMovSourceURL:nil uploadModel:model];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:5];
    [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [self getVideoPreViewImageWithPath:videoURL];
    [self uploadImageAndMovieBaseModel:model];
    //    如果是拍摄的视频, 则把视频保存在系统多媒体库中
    //    NSLog(@"video path: %@", info[UIImagePickerControllerMediaURL]);
    //                    NSURL *videoURL=[info objectForKey:@"UIImagePickerControllerMediaURL"];
    //    [ProgressHUD show:@"转换中..."];
    //                    [self convertMovSourceURL:videoURL uploadModel:<#(UploadModel *)#>];
    //                    [picker dismissViewControllerAnimated:YES completion:nil];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (!error) {
            
            NSLog(@"视频保存成功");
        } else {
            
            NSLog(@"视频保存失败");
        }
    }];
    
}
/**mov转mp4格式*/
-(void)convertMovSourceURL:(NSURL *)sourceUrl uploadModel:(UploadModel *)model
{
    sourceUrl = [NSURL fileURLWithPath:model.path];
    //保存至沙盒路径
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoPath = [NSString stringWithFormat:@"%@/Video", pathDocuments];
    NSString *outPath  = [videoPath stringByAppendingPathComponent:model.name];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复
        
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        NSString * resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        
        NSLog(@"resultPath = %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     NSLog(@"视频转码成功");
                     model.path = resultPath;
                     NSData *data = [NSData dataWithContentsOfFile:model.path];
                     //                                     [self getVideoPreViewImageWithPath:sourceUrl];
                     [self uploadImageAndMovieBaseModel:model];
                     //                model.fileData = data;
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     break;
             }
             
         }];
        
    }
    
}

//将视频保存到缓存路径中
- (void)saveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {
        
        NSLog(@"路径不存在, 创建路径");
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    } else {
        
        NSLog(@"路径存在");
    }
    
    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    if (error) {
        
        NSLog(@"文件保存到缓存失败");
    }
    
}
//以当前时间合成视频名称
- (NSString *)getVideoNameBaseCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
    //stringByAppendingString:@".MOV"];
}
//获取视频的第一帧截图, 返回UIImage
//需要导入AVFoundation.h
- (UIImage*) getVideoPreViewImageWithPath:(NSURL *)videoPath
{
    //    NSURL *paghUrl = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    
    AVAssetImageGenerator *gen         = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time      = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error   = nil;
    
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img     = [[UIImage alloc] initWithCGImage:image];
    self.videoImage = img;
    [sectionFourArray removeAllObjects];
    [sectionFourArray addObject:img];
    self.videoPath = videoPath;
    //一个section刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:5];
    [self.itemTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    return img;
}

//上传视频
- (void)uploadImageAndMovieBaseModel:(UploadModel *)model {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteAction" object:nil userInfo:nil];
    NSData *videoData = [NSData dataWithContentsOfFile:model.path];
    self.videoData = videoData;
    
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
