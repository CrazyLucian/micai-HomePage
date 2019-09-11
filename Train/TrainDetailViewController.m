//
//  TrainDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "TrainDetailViewController.h"
#import "ConfirmOrderViewController.h"
#import "TrainViewModel.h"
#import "TrainModel.h"
#import <WebKit/WebKit.h>
#import "XLCycleScrollView.h"
#import "CollectViewModel.h"
#import "MSWeakTimer.h"
#define content_height (ScreenHeight - 64 - 44)
@interface TrainDetailViewController ()<UIWebViewDelegate,WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,XLCycleScrollViewDatasource,XLCycleScrollViewDelegate>{
    
    XLCycleScrollView           *csView;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *trainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCollect;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCar;
@property (weak, nonatomic) IBOutlet UIButton *btnPay;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageNum;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnSchool;
@property (weak, nonatomic) IBOutlet UIButton *btnClass;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) WKWebView *htmlWebView;
@property (nonatomic, retain) TrainViewModel *viewModel;
@property (nonatomic, retain) TrainModel *trainModel;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, retain) MSWeakTimer           *bannerTimer;
@end

@implementation TrainDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnCollect.layer.cornerRadius = 4.f;
    self.btnCollect.layer.masksToBounds = YES;
    self.btnCollect.layer.borderWidth = 1;
    self.btnCollect.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.btnAddCar.layer.cornerRadius = 4.f;
    self.btnAddCar.layer.masksToBounds = YES;
    self.btnAddCar.layer.borderWidth = 1;
    self.btnAddCar.layer.borderColor = [UIColor colorWithHexString:@"5d873b"].CGColor;
    self.btnPay.layer.cornerRadius = 4.f;
    self.btnPay.layer.masksToBounds = YES;
    
    if (self.type == 1) {
        self.bottomView.hidden = YES;
        self.bottomViewHeight.constant = 1;
    }
//    [self.orderPriceLabel setNumberCustomFontWithStart:0 length:3 fontSize:12 color:@"222222" fontStr:nil];
    
    NSString *jScript = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=%f'); document.getElementsByTagName('head')[0].appendChild(meta);",ScreenWidth - 20];
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 460, ScreenWidth-20, 200) configuration:wkWebConfig];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    self.htmlWebView = webView;
    self.htmlWebView.scrollView.scrollEnabled = NO;
    [self.mainScrollView addSubview:self.htmlWebView];
    self.viewModel = [[TrainViewModel alloc] init];
    __weak typeof(self)weakSelf = self;
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        
        [weakSelf.mainScrollView.mj_header endRefreshing];
        weakSelf.trainModel = returnValue;
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        [weakSelf reloadView];
        
    } WithErrorBlock:^(id errorCode) {
       
        [weakSelf.mainScrollView.mj_header endRefreshing];
     
        [weakSelf showJGProgressWithMsg:errorCode];
    }];
    [self setupRefresh];
    // Do any additional setup after loading the view from its nib.
}

/**
 设置刷新
 */
-(void)setupRefresh{
    self.mainScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    [self.mainScrollView.mj_header beginRefreshing];
}

/**
 下拉刷新
 */
-(void)headerRefreshing{
    [self footerRefreshing];
}

/**
 上拉加载
 */
-(void)footerRefreshing{
    [self.viewModel fetchTrainDetailWithId:self.cateId];
}
//当前页面不在导航控制器中，需重写preferredStatusBarStyle，如下：

-(UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent; //白色
    
    //    return UIStatusBarStyleDefault; //黑色
}
-(void)reloadView{
    self.titleLabel.text = self.trainModel.title;
    self.priceLabel.text = [NSString stringWithFormat:@"培训费：￥%@",self.trainModel.price];
    self.orderMoneyLabel.text = [NSString stringWithFormat:@"定金：￥%@",self.trainModel.subscription_price];
    [self.orderMoneyLabel setNumberCustomFontWithStart:0 length:3 fontSize:13 color:@"666666" fontStr:nil];
    if (self.trainModel.thumb.count) {
        self.pageIndex = 1;
    }
    if ([self.trainModel.is_collect integerValue] == 1) {
        self.btnCollect.selected = YES;
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
        [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
    }
    self.pageNum.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.pageIndex,self.trainModel.thumb.count];
    [self.btnSchool setTitle:self.trainModel.school forState:UIControlStateNormal];
    [self.btnClass setTitle:self.trainModel.Class forState:UIControlStateNormal];
    [self.btnTime setTitle:[NSString stringWithFormat:@"时间：%@-%@",self.trainModel.start_time,self.trainModel.end_time] forState:UIControlStateNormal];
    self.addressLabel.text = [NSString stringWithFormat:@"地址：%@",self.trainModel.address];
    [self.htmlWebView loadHTMLString:self.trainModel.content baseURL:[NSURL URLWithString:BaseUrl]];
    csView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 255)];
    csView.tag = 99;
    [csView addPageControlWithCount:self.trainModel.thumb.count];
    csView.delegate = self;
    csView.datasource = self;
    csView.scrollView.backgroundColor=[UIColor lightGrayColor];
    __weak typeof(self) weakSelf = self;
    [csView setEndDeceleratingBlock:^{
        weakSelf.bannerTimer = [MSWeakTimer scheduledTimerWithTimeInterval:3 target:weakSelf selector:@selector(timerStart) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        //            weakSelf.EndDeceleratingBlock();
    }];
    [csView setBeginDraggingBlock:^{
        //            weakSelf.BeginDraggingBlock();
        [weakSelf.bannerTimer invalidate];
    }];
    [self.trainScrollView addSubview:csView];
    [self.trainScrollView setContentSize:CGSizeMake(ScreenWidth, 255)];
    //    objc_setAssociatedObject(self, &arrchar, banner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [csView reloadData];
    
}
-(void)timerStart{
    if (self.trainModel.thumb.count) {
        [csView timerScrollView];
    }
}
- (NSInteger)numberOfPages
{
    return self.trainModel.thumb.count;
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    //    return arr.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    
    //    BannerModel *model = [arr objectAtIndex:index];
    UIImageView *bannerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 220)];
    bannerImgView.contentMode = UIViewContentModeScaleToFill;
    [bannerImgView setImageWithString:self.trainModel.thumb[index] placeHoldImageName:@"defaultImage"];
    self.pageNum.text = [NSString stringWithFormat:@"%ld/%ld",(long)csView.currentPage+1,self.trainModel.thumb.count];
    return bannerImgView;
}

- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index{
    id next = self.nextResponder;
    while (![next isKindOfClass:[UIViewController class]]) {
        next = [next nextResponder];
    }
    //    NSArray *arr = objc_getAssociatedObject(self, &arrchar);
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)skipToPay:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    TrainViewModel *viewModel = [[TrainViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self showJGProgressWithMsg:@"报名成功，请联系培训方联系培训事宜"];
//        ConfirmOrderViewController *vc = [[ConfirmOrderViewController alloc] init];
//        vc.trainModel = self.trainModel;
//        [self.navigationController pushViewController:vc animated:YES];
    } WithErrorBlock:^(id errorCode) {
        [self showJGProgressWithMsg:errorCode];
    }];
//    [viewModel confirmOrderWithCartId:nil invoiceId:nil];
    [viewModel trainPayWithTrainId:self.trainModel.train_id status:@(1)];
    
}
- (IBAction)addToCar:(id)sender {
    
}
- (IBAction)collectAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    if (self.btnCollect.selected == NO) {
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:@"收藏成功"];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"已收藏" forState:UIControlStateNormal];
            self.btnCollect.selected = YES;
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel collectWithId:self.cateId type:@(4)];
        [self showJGProgressLoadingWithTag:200];
    }else{
        CollectViewModel *viewModel = [[CollectViewModel alloc] init];
        [viewModel setBlockWithReturnBlock:^(id returnValue) {
            [self dissJGProgressLoadingWithTag:200];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateSelected];
            [self.btnCollect setTitle:@"收藏" forState:UIControlStateNormal];
            self.btnCollect.selected = NO;
            [self showJGProgressWithMsg:@"已取消收藏"];
        } WithErrorBlock:^(id errorCode) {
            [self dissJGProgressLoadingWithTag:200];
            [self showJGProgressWithMsg:errorCode];
        }];
        [viewModel cancelCollectWithId:self.cateId type:@(4)];
        [self showJGProgressLoadingWithTag:200];
    }
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
    js=[NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-15];
    
    [webView evaluateJavaScript:js completionHandler:nil];
    
    [webView evaluateJavaScript:@"ResizeImages();"completionHandler:nil];
    
    
    [ webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'" completionHandler:nil];
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result
                                                                                  ,NSError * _Nullable error) {
        CGRect rect = self.htmlWebView.frame;
        rect.size.height = [result doubleValue] + 20;
        self.htmlWebView.frame = rect;
        self.bgViewHeight.constant = 460 + rect.size.height;
    }];
    
    
    
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
