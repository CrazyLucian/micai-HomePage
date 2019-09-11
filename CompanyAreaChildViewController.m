//
//  CompanyAreaChildViewController.m
//  micai
//
//  Created by 苏晓凯 on 2019/4/10.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "CompanyAreaChildViewController.h"
#import "EditHelpInfoViewController.h"
#import "ActivityTableViewCell.h"
@interface CompanyAreaChildViewController ()
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@end

@implementation CompanyAreaChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"ActivityTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActivityTableViewCell"];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)publishAction:(id)sender {
//    EditHelpInfoViewController *vc = [[EditHelpInfoViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];
    
    return cell;
    
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
        NSString *str = @"说明：可敬的退役军人，如果您和家人在生活中遇到了一些棘手的问题和困难，您可以在这里把问题提供给我们，我们审核后会在平台发布\n提示：此版块在全网公开，爱心人士在看到后可以直接与您联系，但迷彩网不会强制要求献爱心。";
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
        return 60 + size.height + 50;
    
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    
        UILabel *introLabel = [[UILabel alloc] init];
        NSString *title = @"说明：可敬的退役军人，如果您和家人在生活中遇到了一些棘手的问题和困难，您可以在这里把问题提供给我们，我们审核后会在平台发布\n提示：此版块在全网公开，爱心人士在看到后可以直接与您联系，但迷彩网不会强制要求献爱心。";
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        //        // 对齐方式
        //        style.alignment = NSTextAlignmentJustified;
        //        // 首行缩进
        style.firstLineHeadIndent = 10.0f;
        // 头部缩进
        style.headIndent = 10.0f;
        // 尾部缩进
        style.tailIndent = -10.0f;
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:title attributes:@{ NSParagraphStyleAttributeName : style}];
        introLabel.attributedText = attrText;
        
        CGSize size = [introLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
        introLabel.frame = CGRectMake(10, 15, ScreenWidth - 20, size.height + 30);
        introLabel.numberOfLines = 0;
        introLabel.textColor = [UIColor colorWithHexString:@"333333"];
        introLabel.font = [UIFont systemFontOfSize:15];
        introLabel.layer.masksToBounds = YES;
        introLabel.layer.cornerRadius = 4;
        introLabel.layer.borderColor = [UIColor colorWithHexString:@"aaaaaa"].CGColor;
        introLabel.layer.borderWidth = 1;
        [view addSubview:introLabel];
    
    UIButton *launchBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth / 4, size.height + 15 + 50, ScreenWidth / 2, 40)];
    [launchBtn setTitle:@"寻求帮助" forState:UIControlStateNormal];
    launchBtn.layer.masksToBounds = YES;
    launchBtn.layer.cornerRadius = 4.f;
    launchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [launchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    launchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    launchBtn.backgroundColor = [UIColor colorWithHexString:@"5d873b"];
    [launchBtn addTarget:self action:@selector(AskForHelp) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:launchBtn];
    view.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    return view;

}
-(void)AskForHelp{
    EditHelpInfoViewController *vc = [[EditHelpInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
