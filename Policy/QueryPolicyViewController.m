//
//  QueryPolicyViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "QueryPolicyViewController.h"
#import "PolicyFileNumberViewController.h"
#import "PolicyDepartmentViewController.h"
#import "QueryFileViewController.h"
#import "QueryPolicyTableViewCell.h"
#import "QueryResultViewController.h"
#import "H_Single_PickerView.h"
#import "H_PCZ_PickerView.h"
#import "PolicyViewModel.h"
#import "NewsNavModel.h"
@interface QueryPolicyViewController ()<H_Single_PickerViewDelegate,H_PCZ_PickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnQuery;
@property (weak, nonatomic) IBOutlet UIButton *btnPart;
@property (weak, nonatomic) IBOutlet UIButton *btnFull;

@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, retain) NSMutableArray *subtitleArr;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, retain) NSNumber *catid;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *keys;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) NSInteger isPart;
@end

@implementation QueryPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPart = 2;
    self.itemArr = [[NSMutableArray alloc] init];
    self.subtitleArr = [[NSMutableArray alloc] init];
//    NSArray *array = @[@[@"政策类型",@"搜索3"],@[@"发布部门",@"择律-付费咨询列表页分割箭头"],@[@"政策名称/文号",@"择律-付费咨询列表页分割箭头"],@[@"文字/符号",@"搜索3"]];
    NSArray *array = @[@[@"政策类型",@"择律-付费咨询列表页分割箭头"],@[@"发布部门",@"择律-付费咨询列表页分割箭头"],@[@"文字/符号",@"择律-付费咨询列表页分割箭头"],@[@"地区",@"择律-付费咨询列表页分割箭头"]];
    NSArray *sbarray = @[@"",@"",@"",@""];
    [self.subtitleArr addObjectsFromArray:sbarray];
    [self.itemArr addObjectsFromArray:array];
    [self.itemTableView registerNib:[UINib nibWithNibName:@"QueryPolicyTableViewCell" bundle:nil] forCellReuseIdentifier:@"QueryPolicyTableViewCell"];
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
    QueryResultViewController  *vc = [[QueryResultViewController alloc] init];
    NSString *keywords = @"";
    if (self.type.length > 0) {
//        keywords = [keywords stringByAppendingString:self.type];
        vc.catId = self.catid;
    }
    if (self.department.length > 0) {
//        if (keywords.length > 0) {
//            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@";%@",self.department]];
//        }else{
//            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@"%@",self.department]];
//        }
        vc.department = self.department;
    }
//    if (self.number.length > 0) {
//        if (keywords.length > 0) {
//            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@";%@",self.number]];
//        }else{
//            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@"%@",self.number]];
//        }
//        
//    }
    if (self.keys.length > 0) {
        
        if (keywords.length > 0) {
            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@";%@",self.keys]];
        }else{
            keywords = [keywords stringByAppendingString:[NSString stringWithFormat:@"%@",self.keys]];
        }
        vc.keywords = keywords;
    }
    
    vc.type = @(self.isPart);
    vc.location = self.location;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)choosePartAction:(id)sender {
    self.btnPart.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    self.btnFull.backgroundColor = [UIColor colorWithHexString:@"b4b4b4"];
    self.isPart = 2;
}
- (IBAction)chooseFullAction:(id)sender {
    self.btnPart.backgroundColor = [UIColor colorWithHexString:@"b4b4b4"];
    self.btnFull.backgroundColor = [UIColor colorWithHexString:@"f26f05"];
    self.isPart = 0;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QueryPolicyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueryPolicyTableViewCell"];
    [cell initCellWithArray:self.itemArr[indexPath.row] sbArr:self.subtitleArr index:indexPath.row];
    [cell setReturnDeleteBlock:^{
       [self.subtitleArr setObject:@"" atIndexedSubscript:indexPath.row];
        switch (indexPath.row) {
            case 0:
                self.type = @"";
                break;
            case 1:
                self.department = @"";
                break;
            case 2:
                self.keys = @"";
                break;
            case 3:
                self.location = @"";
                break;
            default:
                break;
        }
    }];
    return cell;
}
#pragma mark - UITableViewDelegate

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 110.f;
//}


//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            PolicyViewModel *navViewModel = [[PolicyViewModel alloc] init];
            [navViewModel setBlockWithReturnBlock:^(id returnValue) {
                NSArray *cate = returnValue;
                NSMutableArray *muarr = [[NSMutableArray alloc] init];
                for (int i = 0; i < cate.count; i ++) {
                    NewsNavModel *model = cate[i];
                    NSDictionary *dic = @{@"name":model.cat_name,@"cat_id":model.cat_id};
                    [muarr addObject:dic];
                }
                H_Single_PickerView *pickerView = [[H_Single_PickerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) arr:muarr];
                pickerView.delegate = self;
                
                [self.view endEditing:YES];
                [self.view addSubview:pickerView];
            } WithErrorBlock:^(id errorCode) {
                [self showJGProgressWithMsg:errorCode];
            }];
            [navViewModel fetchPolicyNav];
//            QueryFileViewController *vc = [[QueryFileViewController alloc] init];
//            [vc setReturnBlock:^(NSString *type) {
//                self.type = type;
//                [self.subtitleArr setObject:type atIndexedSubscript:indexPath.row];
//                [self.itemTableView reloadData];
//
//            }];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            PolicyDepartmentViewController *vc = [[PolicyDepartmentViewController alloc] init];
            [vc setReturnBlock:^(NSString *depart) {
                self.department = depart;
                [self.subtitleArr setObject:depart atIndexedSubscript:indexPath.row];
                [self.itemTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        
//        case 2:
//        {
//            PolicyFileNumberViewController *vc = [[PolicyFileNumberViewController alloc] init];
//            [vc setReturnBlock:^(NSString *number) {
//                self.number = number;
//                [self.subtitleArr setObject:number atIndexedSubscript:indexPath.row];
//                [self.itemTableView reloadData];
//            }];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
        case 2:
        {
            QueryFileViewController *vc = [[QueryFileViewController alloc] init];
            [vc setReturnBlock:^(NSString *keys) {
                self.keys = keys;
                [self.subtitleArr setObject:keys atIndexedSubscript:indexPath.row];
                [self.itemTableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:{
            H_PCZ_PickerView *pickerView = [[H_PCZ_PickerView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
            pickerView.delegate = self;
            [self.view addSubview:pickerView];
        }
            
        default:
            break;
            
    }
    
}
#pragma mark - H_PCZ_PickerViewDelegate
-(void)getChooseIndex:(H_PCZ_PickerView *)_myPickerView addressStr:(NSString *)addressStr areaCode:(NSString *)areaCode{
    [self.subtitleArr setObject:addressStr atIndexedSubscript:3];
    self.location = addressStr;
    [self.itemTableView reloadData];
}
-(void)SinglePickergetObjectWithArr:(H_Single_PickerView *)_h_Single_PickerView arr:(NSArray *)_arr index:(NSInteger)_index chooseStr:(NSString *)chooseStr chooseId:(NSNumber *)chooseId{
    self.catid = chooseId;
    self.type = chooseStr;
    [self.subtitleArr setObject:chooseStr atIndexedSubscript:0];
    [self.itemTableView reloadData];
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
