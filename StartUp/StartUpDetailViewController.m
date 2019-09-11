//
//  StartUpDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/23.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "StartUpDetailViewController.h"
#import "ApplyStartUpViewController.h"
#import "CompanyProductViewController.h"
#import "PositionDetailViewController.h"
#import "ActivityDetailViewController.h"
#import "SupportProductViewController.h"
#import "StartUpDetailViewController.h"
#import "CompanyInfoModel.h"
#import "CompanyViewModel.h"
#import "StartUpViewModel.h"
#import "CollectViewModel.h"
#import "StartUpModel.h"
#import "XLCycleScrollView.h"
#import <WebKit/WebKit.h>
#import "MSWeakTimer.h"
#import "RecruitTableViewCell.h"
#import "StartUpTableViewCell.h"
#import "ArmyProductTableViewCell.h"
#import "ActivityTableViewCell.h"
#import "CompanyIntroduceTableViewCell.h"

@interface StartUpDetailViewController ()<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,UIWebViewDelegate,WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,UITableViewDelegate,UITableViewDataSource>{
    
    XLCycleScrollView           *csView;
}
@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *dutyView;
@property (weak, nonatomic) IBOutlet UIView *skillView;
@property (weak, nonatomic) IBOutlet UILabel *dutyLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *advantageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseInfoViewHeight;
@property (weak, nonatomic) IBOutlet UIView *labelBgView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollBgView;
@property (weak, nonatomic) IBOutlet UITableView *companyTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;


@property (nonatomic, assign) CGFloat staticHeight;
@property (nonatomic, assign) CGFloat dutyHeight;
@property (nonatomic, assign) CGFloat skillHeight;
@property (nonatomic, assign) CGFloat baseHeight;
@property (nonatomic, retain) StartUpViewModel *viewModel;
@property (nonatomic, retain) StartUpModel *startModel;
@property (nonatomic, retain) CompanyInfoModel *infoModel;
@property (nonatomic, strong) UITableView *itemTableView;
@property (strong, nonatomic) WKWebView *htmlWebView;
@property (strong, nonatomic) WKWebView *htmlWebView1;
@property (nonatomic, retain) MSWeakTimer           *bannerTimer;
@end

@implementation StartUpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.staticHeight = self.bgViewHeight.constant;
    
    self.dutyHeight = self.introHeight.constant;
    ;
    self.skillHeight = self.advantageHeight.constant;
    
    self.baseHeight = self.baseInfoViewHeight.constant;
    
    self.viewModel = [[StartUpViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        weakSelf.startModel = returnValue;
        [weakSelf.itemScrollView.mj_header endRefreshing];
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [weakSelf reloadView];
        //        [weakSelf.itemScrollView reloadData];
    } WithErrorBlock:^(id errorCode) {
        
        [weakSelf.itemScrollView.mj_header endRefreshing];
        
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self setupRefresh];
    
    CompanyViewModel *viewModel = [[CompanyViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        self.infoModel = returnValue;
        [self.itemTableView reloadData];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel fetchCompanyRelateInfomationWithId:@(15)];
    
    
    [self setUpWebView];
//    [self.itemScrollView addSubview:self.itemTableView];
    [self.companyTableView registerNib:[UINib nibWithNibName:@"CompanyIntroduceTableViewCell" bundle:nil] forCellReuseIdentifier:@"CompanyIntroduceTableViewCell"];
    [self.companyTableView registerNib:[UINib nibWithNibName:@"RecruitTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecruitTableViewCell"];
    [self.companyTableView registerNib:[UINib nibWithNibName:@"StartUpTableViewCell" bundle:nil] forCellReuseIdentifier:@"StartUpTableViewCell"];
    [self.companyTableView registerNib:[UINib nibWithNibName:@"ArmyProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArmyProductTableViewCell"];
    [self.companyTableView registerNib:[UINib nibWithNibName:@"ActivityTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActivityTableViewCell"];
    [self.companyTableView reloadData];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)setUpWebView{
    NSString *jScript = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=%f'); document.getElementsByTagName('head')[0].appendChild(meta);",ScreenWidth - 20];
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    CGRect skillrect = self.skillLabel.frame;
    CGRect dutyrect = self.dutyLabel.frame;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(dutyrect.origin.x, dutyrect.origin.y, dutyrect.size.width, dutyrect.size.height) configuration:wkWebConfig];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    WKWebView *webView1 = [[WKWebView alloc] initWithFrame:CGRectMake(skillrect.origin.x, skillrect.origin.y, skillrect.size.width, skillrect.size.height) configuration:wkWebConfig];
    webView1.UIDelegate = self;
    webView1.navigationDelegate = self;
    self.htmlWebView = webView;
    self.htmlWebView1 = webView1;
    [self.dutyView addSubview:self.htmlWebView];
    [self.skillView addSubview:self.htmlWebView1];
    self.htmlWebView.scrollView.scrollEnabled = NO;
    self.htmlWebView1.scrollView.scrollEnabled = NO;
}
-(UITableView *)itemTableView{
    if (_itemTableView == nil) {
        _itemTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1000, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
        _itemTableView.delegate = self;
        _itemTableView.dataSource = self;
        
    }
    return _itemTableView;
}
/**
 设置刷新
 */
-(void)setupRefresh{
    self.itemScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    [self.itemScrollView.mj_header beginRefreshing];
}

/**
 下拉刷新
 */
-(void)headerRefreshing{
    //    self.pageIndex = 0;
    [self footerRefreshing];
}

/**
 上拉加载
 */
-(void)footerRefreshing{
    //    ++ self.pageIndex;
    [self.viewModel fetchStartUpDetailWithId:self.Id];
    
}
-(void)reloadView{
    self.nameLabel.text = self.startModel.name;
    
    if ([self.startModel.is_collect integerValue] == 1) {
        self.btnCollect.selected = YES;
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
    }
    self.typeLabel.text = self.startModel.industry;
    self.amountLabel.text = [NSString stringWithFormat:@"投资额度：%@",self.startModel.money];
    [self.amountLabel setNumberCustomFontWithStart:0 length:5 fontSize:15 color:@"000000" fontStr:nil];
//    [self.itemImageView setImageWithString:self.startModel.image placeHoldImageName:@"defaultImage"];
    
    if (self.startModel.desc.length > 0) {
        [self.htmlWebView loadHTMLString:self.startModel.desc baseURL:[NSURL URLWithString:BaseUrl]];
    }
    if (self.startModel.advantage.length > 0) {
        [self.htmlWebView1 loadHTMLString:self.startModel.advantage baseURL:[NSURL URLWithString:BaseUrl]];
    }
//    self.dutyLabel.text = self.startModel.desc;
    NSArray *array = [self.startModel.keywords componentsSeparatedByString:@";"];
    NSMutableArray *muArr = [[NSMutableArray alloc] initWithArray:array];
    for (int i = 0; i < muArr.count; i ++) {
        NSString *labelStr = muArr[i];
        if (labelStr.length == 0) {
            [muArr removeObjectAtIndex:i];
        }
    }
    CGFloat W = (ScreenWidth - 50) / 4;
    CGFloat H = W / 2;
    CGFloat margin = 10;
    for (int i = 0; i < muArr.count; i ++) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake((W + margin) * (i % 4) + margin, (H + margin) * (i / 4) , W, H);
        button.tag = 999 + i;
        button.layer.borderColor = [UIColor colorWithHexString:@"b4b4b4"].CGColor;
        button.layer.borderWidth = 1.f;
        [button setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitle:muArr[i] forState:UIControlStateNormal];
        if (i == muArr.count - 1) {
            self.baseInfoViewHeight.constant = button.frame.origin.y + button.frame.size.height + 20 + 318;
            self.baseHeight = self.baseInfoViewHeight.constant;
            CGRect rectlabel = self.labelBgView.frame;
            rectlabel.size.height = button.frame.origin.y + button.frame.size.height;
            self.labelBgView.frame = rectlabel;
            
        }
        //        [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.labelBgView addSubview:button];
        
    }
    
    //    self.dutyLabel.numberOfLines = 0;
    //    CGSize size = [self.dutyLabel.text sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    //    CGRect rect = self.dutyLabel.frame;
    //    rect.size.height = size.height;
    //    self.dutyLabel.frame = rect;
    //    CGRect rectduty = self.dutyView.frame;
    //    rectduty.size.height = self.dutyHeight + size.height;
    //    self.dutyView.frame = rectduty;
    //    self.introHeight.constant = self.dutyHeight + size.height;
    //    self.skillLabel.text = self.startModel.advantage;
    //
    //    self.skillLabel.numberOfLines = 0;
    //    CGSize skillSize = [self.skillLabel.text sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(ScreenWidth - 20, 3000)];
    //    CGRect rect1 = self.skillLabel.frame;
    //    rect1.size.height = skillSize.height;
    //    self.skillLabel.frame = rect1;
    //    CGRect rectSkill = self.skillView.frame;
    //    rectSkill.origin.y = rectduty.size.height + rectduty.origin.y + 10;
    //    rectSkill.size.height = self.skillHeight + skillSize.height;
    //    self.skillView.frame = rectSkill;
    //    self.advantageHeight.constant = self.skillHeight + skillSize.height;
    //
    //    CGRect rectlabel = self.labelBgView.frame;
    //    self.bgViewHeight.constant = self.staticHeight + size.height + skillSize.height + rectlabel.size.height;
    
    //banner
    csView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 219)];
    csView.tag = 99;
    if (self.startModel.thumb.count == 0) {
        self.startModel.thumb = self.startModel.image;
    }
    [csView addPageControlWithCount:self.startModel.thumb.count];
    csView.delegate = self;
    csView.datasource = self;
    csView.scrollView.backgroundColor=[UIColor lightGrayColor];
    __weak typeof(self) weakSelf = self;
    [csView setEndDeceleratingBlock:^{
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        //            weakSelf.EndDeceleratingBlock();
    }];
    [csView setBeginDraggingBlock:^{
        [weakSelf.bannerTimer invalidate];
    }];
    [self.imageScrollView addSubview:csView];
    [self.imageScrollView setContentSize:CGSizeMake(ScreenWidth, 219)];
    //    objc_setAssociatedObject(self, &arrchar, banner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [csView reloadData];
    
}
-(void)timerStart{
    if (self.startModel.thumb.count) {
        [csView timerScrollView];
    }
}
- (NSInteger)numberOfPages
{
    return self.startModel.thumb.count;
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    //    return arr.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    
    //    BannerModel *model = [arr objectAtIndex:index];
    UIImageView *bannerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 220)];
    bannerImgView.contentMode = UIViewContentModeScaleToFill;
    [bannerImgView setImageWithString:self.startModel.thumb[index] placeHoldImageName:@"defaultImage"];
    //    self.pageNum.text = [NSString stringWithFormat:@"%ld/%ld",(long)csView.currentPage+1,self.trainModel.thumb.count];
    return bannerImgView;
}

- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index{
    id next = self.nextResponder;
    while (![next isKindOfClass:[UIViewController class]]) {
        next = [next nextResponder];
    }
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    
    
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)consultAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:[NSString stringWithFormat:@"%@",self.startModel.phone]
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",self.startModel.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)collectAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    self.btnCollect.highlighted = NO;
    if (self.btnCollect.selected == NO) {
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:@"收藏成功"];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            [self.btnCollect setSelected:YES];
            //            self.btnCollect.selected = YES;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel collectWithId:self.Id type:@(6)];
        [self showJGProgressLoadingWithTag:200];
    }else{
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self showJGProgressWithMsg:@"已取消收藏"];
            [self dissJGProgressLoadingWithTag:200];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
            [self.btnCollect setSelected:NO];
            //            self.btnCollect.selected = NO;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel cancelCollectWithId:self.Id type:@(6)];
        [self showJGProgressLoadingWithTag:200];
    }
}
- (IBAction)applyAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    ApplyStartUpViewController *vc = [[ApplyStartUpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - WKNavigationDelegate  // （按触发顺序排列）

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //    NSLog(@"发送请求前决定是否跳转======%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //    NSLog(@"开始加载======%@",self.webView.URL.absoluteString);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    //    NSLog(@"收到响应，决定是否跳转======%@",navigationResponse.response.URL.absoluteString);
    
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //    NSLog(@"内容开始返回======%@",self.webView.URL.absoluteString);
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.tableViewHeight.constant = ScreenHeight;
    
    
    if (webView == self.htmlWebView) {
        
        NSString *js=@"var script = document.createElement('script');"
        "script.type = 'text/javascript';"
        "script.text = \"function ResizeImages() { "
        "var myimg,oldwidth;"
        "var maxwidth = %f;"
        "for(i=0;i <document.images.length;i++){"
        "myimg = document.images[i];"
        "if(myimg.width > maxwidth){"
        "oldwidth = myimg.width;"
        "myimg.width = %f;"
        "}"
        "}"
        "}\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        js=[NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-20];
        
        [webView evaluateJavaScript:js completionHandler:nil];
        
        [webView evaluateJavaScript:@"ResizeImages();"completionHandler:nil];
        
        [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result
                                                                                      ,NSError * _Nullable error) {
            CGRect dutyrect = self.dutyLabel.frame;
            CGRect rect = self.htmlWebView.frame;
            rect.size.height = [result doubleValue] + 10;
            rect.size.width = dutyrect.size.width;
            self.htmlWebView.frame = rect;
            
            self.introHeight.constant = self.dutyHeight + [result doubleValue] + 10;
            self.bgViewHeight.constant = self.baseHeight + self.introHeight.constant + self.advantageHeight.constant;
        
        }];
    }
    if (webView == self.htmlWebView1) {
        
        NSString *js=@"var script = document.createElement('script');"
        "script.type = 'text/javascript';"
        "script.text = \"function ResizeImages() { "
        "var myimg,oldwidth;"
        "var maxwidth = %f;"
        "for(i=0;i <document.images.length;i++){"
        "myimg = document.images[i];"
        "if(myimg.width > maxwidth){"
        "oldwidth = myimg.width;"
        "myimg.width = %f;"
        "}"
        "}"
        "}\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        js=[NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-20];
        
        [webView evaluateJavaScript:js completionHandler:nil];
        
        [webView evaluateJavaScript:@"ResizeImages();"completionHandler:nil];
        
        [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result
                                                                                      ,NSError * _Nullable error) {
            CGRect rect = self.htmlWebView1.frame;
            CGRect skillrect = self.skillLabel.frame;
            
            rect.size.height = [result doubleValue] + 10;
            rect.size.width = skillrect.size.width;
            self.htmlWebView1.frame = rect;
            
            self.advantageHeight.constant = self.skillHeight + [result doubleValue] + 10;
            self.bgViewHeight.constant = self.baseHeight + self.introHeight.constant + self.advantageHeight.constant + ScreenHeight;
//            self.bgViewHeight.constant = self.staticHeight + self.introHeight.constant + self.introHeight.constant;
        }];
    }
//    CGRect rectTab = self.scrollBgView.frame;
    
//    self.bgViewHeight.constant = self.staticHeight + self.introHeight.constant + self.introHeight.constant;
    
    
    
    //    NSLog(@"页面加载完成======%@",self.webView.URL.absoluteString);
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    //    NSLog(@"接收到服务器跳转请求======%@",webView.URL.absoluteString);
}
#pragma mark - WKScriptMessageHandler

// js调用oc方法  js代码格式：window.webkit.messageHandlers.方法名.postMessage({body: 'hello world!'});
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"方法名"]) {
        // 调用方法
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
        if (section == 0) {
            
        return 1;
        }
    if (section == 1) {
        return self.infoModel.recruitment_list.count > 3 ? 3 : self.infoModel.recruitment_list.count;
    }
    if (section == 2) {
        return self.infoModel.investment_list.count > 3 ? 3 : self.infoModel.investment_list.count;
    }
    if (section == 3) {
        return self.infoModel.goods_list.count > 3 ? 3 : self.infoModel.goods_list.count;
    }
    
        return self.infoModel.activity_list.count > 3 ? 3 : self.infoModel.activity_list.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        CompanyIntroduceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanyIntroduceTableViewCell"];
//        [cell initCellWithModel:self.jobModel];
        return cell;
    }else if (indexPath.section == 1){
        RecruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecruitTableViewCell"];
        [cell initCellWithModel:self.infoModel.recruitment_list[indexPath.row] isHide:1];
        return cell;
    }else if (indexPath.section == 2){
        StartUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StartUpTableViewCell"];
        [cell initCellWithModel:self.infoModel.investment_list[indexPath.row]];
        return cell;
    }else if (indexPath.section == 3){
        ArmyProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArmyProductTableViewCell"];
        [cell initCellWithModel:self.infoModel.goods_list[indexPath.row]];
        return cell;
    }
    
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];
    [cell initCellWithModel:self.infoModel.activity_list[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
//        return [CompanyIntroduceTableViewCell getCellWithModel:self.jobModel];
        return 100.f;
    }else if (indexPath.section == 1){
        return 84.f;
    }else if (indexPath.section == 2){
        return 110.f;
    }else if (indexPath.section == 3){
        return 128.f;
    }
    return 128.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section < 1) {
        return 10.f;
    }
    return 40.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section < 1) {
        return 0.0001f;
    }
    return 40.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];

    if (section > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
        switch (section) {
            case 1:
                label.text = @"热门职位";
                break;
            case 2:
                label.text = @"创业项目";
                break;
            case 3:
                label.text = @"拥军产品";
                break;
            case 4:
                label.text = @"拥军活动";
                break;
                
            default:
                break;
        }
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor colorWithHexString:@"f26f05"];
        [view addSubview:label];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, ScreenWidth - 20, 1)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"e9e9e9"];
        [view addSubview:lineLabel];
    }
    
    view.backgroundColor = [UIColor whiteColor];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    if (section > 0) {
        UIButton *bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        [bottomBtn setTitle:@"点击查看更多 >" forState:UIControlStateNormal];
        bottomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        bottomBtn.tag = section + 999;
        [bottomBtn addTarget:self action:@selector(skipToProduct:)
            forControlEvents:UIControlEventTouchUpInside];
        
        bottomBtn.backgroundColor = [UIColor colorWithHexString:@"5d873b"];
        [bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [view addSubview:bottomBtn];
        view.backgroundColor = [UIColor whiteColor];
    }
    view.backgroundColor = [UIColor whiteColor];
    if (section < 1) {
        view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    }
    return view;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
                case 1:
                {
                    PositionDetailViewController *vc = [[PositionDetailViewController alloc] init];
                    RecruitModel *model = self.infoModel.recruitment_list[indexPath.row];
                    vc.jobId = model.Id;
                    vc.isFull = @(1);
                    vc.hidesBottomBarWhenPushed = YES;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
                    break;
                case 2:
                {
                    
                    StartUpDetailViewController *vc = [[StartUpDetailViewController alloc] init];
                    StartUpModel *model = self.infoModel.investment_list[indexPath.row];
                    vc.Id = model.Id;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:
                {
                    SupportProductViewController *vc = [[SupportProductViewController alloc] init];
                    GoodsModel *model = self.infoModel.goods_list[indexPath.row];
                    vc.goodsId = model.goods_id;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 4:
                {
                    ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] init];
                    ActivityModel *model = self.infoModel.activity_list[indexPath.row];
                    vc.acticityId = model.activity_id;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
            
                    
                default:
                    break;
            }
}
-(void)skipToProduct:(UIButton *)button{
    CompanyProductViewController *vc = [[CompanyProductViewController alloc] init];
    vc.type = button.tag - 999 - 2;
    switch (button.tag - 999 - 2) {
        case 0:
            vc.dataArr = self.infoModel.recruitment_list;
            break;
        case 1:
            vc.dataArr = self.infoModel.investment_list;
            break;
        case 2:
            vc.dataArr = self.infoModel.goods_list;
            break;
        case 3:
            vc.dataArr = self.infoModel.activity_list;
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
