//
//  CompanyMainAreaViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/10.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "CompanyMainAreaViewController.h"
#import "CompanyAreaChildViewController.h"
#import "CompanyAreaListViewController.h"
#import <MJCSegmentInterface/MJCSegmentInterface.h>

#define menu_max   999
@interface CompanyMainAreaViewController ()<MJCSegmentDelegate>

@end

@implementation CompanyMainAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *titlesArr = @[@"资源发布",@"资源需求",@"项目发起",@"政府对接"];
    CompanyAreaChildViewController *vc1 = [[CompanyAreaChildViewController alloc]init];
    
    CompanyAreaChildViewController *vc2 = [[CompanyAreaChildViewController alloc]init];
    
    CompanyAreaChildViewController *vc3 = [[CompanyAreaChildViewController alloc]init];
    
    CompanyAreaListViewController *vc4 = [[CompanyAreaListViewController alloc]init];
    
    
    
    NSArray *vcarrr = @[vc1,vc2,vc3,vc4];
    for (int i = 0 ; i < vcarrr.count; i++) {//赋值标题
        UIViewController *vc = vcarrr[i];
        vc.title = titlesArr[i];
    }
    CGFloat Y = 64;
    if (kDevice_Is_iPhoneX) {
        Y = 88;
    }
    MJCSegmentInterface *interFace =  [MJCSegmentInterface jc_initWithFrame:CGRectMake(0,Y,ScreenWidth, ScreenHeight - Y) interFaceStyleToolsBlock:^(MJCSegmentStylesTools *jc_tools) {
        jc_tools.jc_titleBarStyles(MJCTitlesScrollStyle).
        jc_indicatorStyles(MJCIndicatorItemTextStyle).
        jc_indicatorColor([UIColor colorWithHexString:@"e67716"]).
        jc_indicatorFollowEnabled(YES).
        jc_childScollAnimalEnabled(YES).
        jc_childScollEnabled(YES).
        jc_childsContainerBackColor([UIColor whiteColor]).
        jc_titlesViewBackColor([UIColor whiteColor]).
        jc_itemTextNormalColor([UIColor colorWithHexString:@"555555"]).
        jc_itemTextSelectedColor([UIColor colorWithHexString:@"e67716"]).
        jc_itemTextFontSize(15).
        jc_itemTextBoldFontSize(15).
        jc_ItemDefaultShowCount(4);
    }];
    interFace.delegate= self;
    [self.view addSubview:interFace];
    [interFace intoTitlesArray:titlesArr hostController:self];
    [interFace intoChildControllerArray:vcarrr];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}

-(void)mjc_ClickEventWithItem:(UIButton *)tabItem childsController:(UIViewController *)childsController segmentInterface:(MJCSegmentInterface *)segmentInterface{
    //    NSLog(@"");
    //    NSArray *titlesArr = @[@"资源发布",@"资源需求",@"项目发起",@"政府对接"];
    //    for (int i = 0; i < titlesArr.count; i ++) {
    //        if ([tabItem.titleLabel.text isEqualToString:titlesArr[i]]) {
    //
    //            CompanyAreaViewController *third = (CompanyAreaViewController *)childsController;
    //            third.flag = i + 1;
    //        }
    //    }
    
    
}
-(void)mjc_scrollDidEndDeceleratingWithItem:(UIButton *)tabItem childsController:(UIViewController *)childsController indexPage:(NSInteger)indexPage segmentInterface:(MJCSegmentInterface *)segmentInterface{
    //    CompanyAreaViewController *third = (CompanyAreaViewController *)childsController;
    //    third.flag = indexPage + 1;
    
    //    NSLog(@"%ld",(long)indexPage);
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
