//
//  PolicyDepartmentViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "PolicyDepartmentViewController.h"
#import "QueryResultViewController.h"
@interface PolicyDepartmentViewController ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation PolicyDepartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = @[@"财政",@"教育",@"国防",@"公安",@"交通",@"外交",@"司法",@"民政",@"退役军人事务部"];
    
    CGFloat W = (ScreenWidth - 50) / 4;
    CGFloat H = W / 2;
    CGFloat margin = 10;
    for (int i = 0; i < array.count; i ++) {
        UIButton *button = [[UIButton alloc] init];
        CGSize size = [array[i] sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(150, 20)];
        if (size.width > W) {
            button.frame = CGRectMake((W + margin) * (i % 4) + margin, 50 + (H + margin) * (i / 4) , size.width + 20, H);
        }else{
            button.frame = CGRectMake((W + margin) * (i % 4) + margin, 50 + (H + margin) * (i / 4) , W, H);
        }
        
        button.tag = 999 + i;
        button.layer.borderColor = [UIColor colorWithHexString:@"e8e8e8"].CGColor;
        button.layer.borderWidth = 1.f;
        [button setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:button];
    }
    // Do any additional setup after loading the view from its nib.
}
-(void)buttonClickAction:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected == YES) {
        btn.layer.borderColor = [UIColor colorWithHexString:@"f26f05"].CGColor;
    }else{
        btn.layer.borderColor = [UIColor colorWithHexString:@"e8e8e8"].CGColor;
    }
    NSArray *array = @[@"财政",@"教育",@"国防",@"公安",@"交通",@"外交",@"司法",@"民政",@"退役军人事务部"];
    self.returnBlock(array[btn.tag - 999]);
    [self backAction:nil];
//    QueryResultViewController *vc = [[QueryResultViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//    NSArray *array = @[@"住宅",@"商铺",@"汽车",@"企业",@"其他"];
//    NSInteger index = btn.tag - 999;
//    self.type = array[index];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//当前页面不在导航控制器中，需重写preferredStatusBarStyle，如下：

-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent; //白色
    
    //    return UIStatusBarStyleDefault; //黑色
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
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
