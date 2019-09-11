//
//  LabelSearchViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/8/8.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "LabelSearchViewController.h"
#import "SearchStartUpViewController.h"
#import "StartUpViewModel.h"
#import "LabelModel.h"
@interface LabelSearchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIView *labelBgView;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *selectArr;
@end

@implementation LabelSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemArr = [[NSMutableArray alloc] init];
    self.selectArr = [[NSMutableArray alloc] init];
    StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self.itemArr addObjectsFromArray:returnValue];
        [self reloadLabelView];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchDefaultLabel];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
-(void)reloadLabelView{
    CGFloat W = (ScreenWidth - 50) / 4;
    CGFloat H = W / 2;
    CGFloat margin = 10;
    for (int i = 0; i < self.itemArr.count; i ++) {
        LabelModel *model = self.itemArr[i];
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake((W + margin) * (i % 4) + margin, 40 + (H + margin) * (i / 4) , W, H);
        button.tag = 999 + i;
        button.layer.borderColor = [UIColor colorWithHexString:@"e8e8e8"].CGColor;
        button.layer.borderWidth = 1.f;
        [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"f26f05"] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:model.name forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.labelBgView addSubview:button];
    }
}
-(void)buttonClickAction:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected == YES) {
        btn.layer.borderColor = [UIColor colorWithHexString:@"f26f05"].CGColor;
        NSInteger index = btn.tag - 999;
        LabelModel *model = self.itemArr[index];
        [self.selectArr addObject:model.name];
    }else{
        btn.layer.borderColor = [UIColor colorWithHexString:@"e8e8e8"].CGColor;
        NSInteger index = btn.tag - 999;
        LabelModel *model = self.itemArr[index];
        [self.selectArr removeObject:model.name];
    }
    
    
}
- (IBAction)searchAction:(id)sender {
    
    NSString *str = @"";
    for (int i = 0; i < self.selectArr.count; i ++) {
        
        str = [str stringByAppendingString:self.selectArr[i]];
    }
//    self.returnSearchBlock(str);
//    [self backAction:nil];
    SearchStartUpViewController *vc = [[SearchStartUpViewController alloc] init];
    vc.searchKey = str;
    vc.titleIndex = self.titleIndex;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)txtSearchAction:(id)sender {
    SearchStartUpViewController *vc = [[SearchStartUpViewController alloc] init];
    vc.titleIndex = self.titleIndex;
    vc.searchKey = self.txtSearch.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
