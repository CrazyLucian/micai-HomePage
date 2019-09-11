//
//  QueryFileViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "QueryFileViewController.h"
#import "QueryResultViewController.h"
#import "PolicyViewModel.h"
@interface QueryFileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@end

@implementation QueryFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)queryAction:(id)sender {
    self.returnBlock(self.txtSearch.text);
    [self backAction:nil];
//        QueryResultViewController *vc = [[QueryResultViewController alloc] init];
//
//        [self.navigationController pushViewController:vc animated:YES];

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
