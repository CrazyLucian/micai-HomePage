//
//  StartStarDetailViewController.m
//  micai
//
//  Created by 苏晓凯 on 2018/7/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "StartStarDetailViewController.h"
#import "StartUpViewModel.h"
#import "StartStarModel.h"
#import <WebKit/WebKit.h>
#import "ActivityRemarkTableViewCell.h"
@interface StartStarDetailViewController ()<UIWebViewDelegate,WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *itemScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnClick;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UITextView *txtComment;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (nonatomic, retain) StartUpViewModel *viewModel;
@property (strong, nonatomic) WKWebView *htmlWebView;
@property (nonatomic, retain) UITableView *newsTableView;
@property (nonatomic, retain) NSMutableArray *itemArr;
@property (nonatomic, assign) NSInteger reloadIndex;
@end

@implementation StartStarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.type integerValue] == 1) {
        self.bottomView.hidden = YES;
        self.bottomViewHeight.constant = 1;
    }else{
        self.bottomView.hidden = NO;
        self.bottomViewHeight.constant = 60;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.txtComment];
    
    self.itemArr = [[NSMutableArray alloc] init];
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, ScreenWidth, 100);
    topView.backgroundColor = [UIColor whiteColor];
    [self.itemScrollView addSubview:topView];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.frame = CGRectMake(20, 10, ScreenWidth - 40, 50);
    UIButton *btnClick = [[UIButton alloc] init];
    btnClick.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnClick setTitleColor:[UIColor colorWithHexString:@"787878"] forState:UIControlStateNormal];
    [btnClick setImage:[UIImage imageNamed:@"浏览图标拷贝"] forState:UIControlStateNormal];
    btnClick.frame = CGRectMake(10, 70, 50, 20);
    UIButton *btnTime = [[UIButton alloc] init];
    btnTime.frame = CGRectMake(70, 70, 150, 20);
    btnTime.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnTime setTitleColor:[UIColor colorWithHexString:@"787878"] forState:UIControlStateNormal];
    [btnTime setImage:[UIImage imageNamed:@"时间图标拷贝"] forState:UIControlStateNormal];
    
    [topView addSubview:label];
    [topView addSubview:btnClick];
    [topView addSubview:btnTime];
    
    NSString *jScript = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=%f'); document.getElementsByTagName('head')[0].appendChild(meta);",ScreenWidth - 20];
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 100, ScreenWidth - 20, 0) configuration:wkWebConfig];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    self.htmlWebView = webView;
        self.htmlWebView.scrollView.scrollEnabled = NO;
    [self.itemScrollView addSubview:self.htmlWebView];
    
    self.newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.htmlWebView.frame.size.height + 50, ScreenWidth, ScreenHeight - 64 - 50 - 60) style:UITableViewStylePlain];
    //可以直接添加如下代码即可
    self.newsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//    self.newsTableView = [[UITableView alloc] init];
//    self.newsTableView.frame = ;
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    self.newsTableView.backgroundColor = [UIColor clearColor];
    self.newsTableView.estimatedRowHeight = 80.f;
    self.newsTableView.rowHeight = UITableViewAutomaticDimension;
    [self.newsTableView registerNib:[UINib nibWithNibName:@"ActivityRemarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"ActivityRemarkTableViewCell"];
    [self.itemScrollView addSubview:self.newsTableView];
    
    self.itemScrollView.contentSize = CGSizeMake(ScreenWidth, 0);
    self.viewModel = [[StartUpViewModel alloc] init];
        __weak typeof(self)weakSelf = self;
        [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
            [weakSelf.itemScrollView.mj_header endRefreshing];
            StartStarModel *model = returnValue;
            if (self.reloadIndex == 0) {
                [weakSelf.itemArr addObjectsFromArray:model.comments];
                [weakSelf.htmlWebView loadHTMLString:model.content baseURL:[NSURL URLWithString:BaseUrl]];
                [weakSelf.newsTableView reloadData];
                label.text = model.title;
                [btnClick setTitle:[NSString stringWithFormat:@"%@",model.click] forState:UIControlStateNormal];
                [btnClick setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
                [btnTime setTitle:[NSString stringWithFormat:@"%@",model.add_time] forState:UIControlStateNormal];
                [btnTime setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
            }else{
                [weakSelf.itemArr removeAllObjects];
                [weakSelf.itemArr addObjectsFromArray:model.comments];
                [weakSelf.newsTableView reloadData];
            }
        } WithErrorBlock:^(id errorCode) {
            
            [weakSelf.itemScrollView.mj_header endRefreshing];
            
            [weakSelf showJGProgressWithMsg:errorCode];
        }];
        [self setupRefresh];
    
//    NSString *jScript = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=%f'); document.getElementsByTagName('head')[0].appendChild(meta);",ScreenWidth - 20];
//
//    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
//    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
//    [wkUController addUserScript:wkUScript];
//
//    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
//    wkWebConfig.userContentController = wkUController;
//
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, self.infoView.frame.size.height + self.infoView.frame.origin.y, ScreenWidth - 20, 200) configuration:wkWebConfig];
//    webView.UIDelegate = self;
//    webView.navigationDelegate = self;
//    self.htmlWebView = webView;
//    self.htmlWebView.scrollView.scrollEnabled = NO;
//    [self.itemScrollView addSubview:self.htmlWebView];
//
//    self.viewModel = [[StartUpViewModel alloc] init];
    
//    __weak typeof(self)weakSelf = self;
//    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
//        [weakSelf.itemScrollView.mj_header endRefreshing];
//        StartStarModel *model = returnValue;
//        [weakSelf.starImageView setImageWithString:model.thumb placeHoldImageName:@"defaultImage"];
//        [weakSelf.htmlWebView loadHTMLString:model.content baseURL:[NSURL URLWithString:BaseUrl]];
//        [weakSelf.btnClick setTitle:[NSString stringWithFormat:@"%@",model.click] forState:UIControlStateNormal];
//        [weakSelf.btnClick setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
//        [weakSelf.btnTime setTitle:[NSString stringWithFormat:@"%@",model.add_time] forState:UIControlStateNormal];
//        [weakSelf.btnTime setImagePositionWithType:SSImagePositionTypeLeft spacing:3.f];
//    } WithErrorBlock:^(id errorCode) {
//
//        [weakSelf.itemScrollView.mj_header endRefreshing];
//
//        [weakSelf showJGProgressWithMsg:errorCode];
//    }];
//    [self setupRefresh];
    // Do any additional setup after loading the view from its nib.
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
    if (self.type == 0) {
        [self.viewModel fetchStartStarDetailWithId:self.Id];
    }else{
        [self.viewModel fetchStartHelpDetailWithId:self.Id];
    }
    
    
}
- (IBAction)backAction:(id)sender {
    [self backBtnAction:sender];
}
- (IBAction)publishAction:(id)sender {
    if (!TOKEN) {
        [self skipToLogin];
        return;
    }
    [self.txtComment resignFirstResponder];
    if (self.txtComment.text.length == 0) {
        return;
    }
    StartUpViewModel *viewModel = [[StartUpViewModel alloc] init];
    [viewModel setBlockWithReturnBlock:^(id returnValue) {
        [self dissJGProgressLoadingWithTag:200];
        self.txtComment.text = @"";
        self.placeHolderLabel.hidden = NO;
        self.reloadIndex = 1;
        [self headerRefreshing];
    } WithErrorBlock:^(id errorCode) {
        [self dissJGProgressLoadingWithTag:200];
        [self showJGProgressWithMsg:errorCode];
    }];
    [viewModel commentWithContent:self.txtComment.text Id:self.Id];
    [self showJGProgressLoadingWithTag:200];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.itemArr.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        ActivityRemarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityRemarkTableViewCell"];
        [cell initCellWithModel:self.itemArr[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
    
}
#pragma mark - UITableViewDelegate
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 128.f;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.0001f;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        return 0.0001f;
//    }
//    return 30.f;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
//    view.backgroundColor = [UIColor whiteColor];
//    return view;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
//tableview 加载完成可以调用的方法--因为tableview的cell高度不定，所以在加载完成以后重新计算高度
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == ((NSIndexPath*)[[tableView indexPathsForVisibleRows]lastObject]).row){
        //end of loading
        dispatch_async(dispatch_get_main_queue(), ^{


            self.newsTableView.frame = CGRectMake(self.newsTableView.frame.origin.x,self.htmlWebView.frame.size.height + 50,ScreenWidth, tableView.contentSize.height);
            CGRect rect1 = self.newsTableView.frame;
            self.itemScrollView.contentSize = CGSizeMake(ScreenWidth, rect1.size.height + rect1.origin.y);
        });
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
    
    NSString *js= [NSString stringWithFormat:@"var script = document.createElement('script');"
                   "script.type = 'text/javascript';"
                   "script.text = \"function ResizeImages() { "
                   "var myimg,oldwidth;"
                   "var maxwidth = %f;"
                   "for(i=0;i <document.images.length;i++){"
                   "myimg = document.images[i];"
                   "if(myimg.width > maxwidth){"
                   "oldwidth = myimg.width;"
                   "var w=document.body.offsetWidth;"
                   "myimg.width = w;"
                   "}"
                   "}"
                   "}\";"
                   "document.getElementsByTagName('head')[0].appendChild(script);", ScreenWidth - 20];
    js=[NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-15];
    
    [self.htmlWebView evaluateJavaScript:js completionHandler:nil];
    [self.htmlWebView evaluateJavaScript:@"ResizeImages();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result
                                                                                  ,NSError * _Nullable error) {
        CGRect rect = self.htmlWebView.frame;
        rect.size.height = [result doubleValue] + 20;
        self.htmlWebView.frame = rect;
        
        if (self.itemArr.count == 0) {
           
            self.itemScrollView.contentSize = CGSizeMake(ScreenWidth, rect.size.height + rect.origin.y);
        }else{
            CGRect rect1 = self.newsTableView.frame;
            rect1.origin.y = rect.size.height + 50;
            self.newsTableView.frame = rect1;
            self.itemScrollView.contentSize = CGSizeMake(ScreenWidth, rect1.size.height + rect1.origin.y);
        }
        //        self.webViewHeight.constant = [result doubleValue];
        //        NSLog(@"%f",self.webViewHeight.constant);
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

#pragma mark - WKUIDelegate

// 创建一个新的WebView
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
//    return [[WKWebView alloc]init];
//}

// 输入框
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//    completionHandler(@"");
//}

// 确认框
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
//    completionHandler(YES);
//}

// 警告框
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
//    completionHandler();
//}

#pragma mark - WKScriptMessageHandler

// js调用oc方法  js代码格式：window.webkit.messageHandlers.方法名.postMessage({body: 'hello world!'});
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"方法名"]) {
        // 调用方法
    }
}

- (void)textFiledEditChanged:(NSNotification *)obj
{
    UITextView *inputTextView = (UITextView *)obj.object;
    NSString *toBeString = inputTextView.text;
    if (toBeString.length > 0) {
        self.placeHolderLabel.hidden = YES;
    }else{
        self.placeHolderLabel.hidden = NO;
    }
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [inputTextView markedTextRange];       //获取高亮部分
        UITextPosition *position = [inputTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 500) {
                [self showJGProgressWithMsg:@"最多输入500字"];
                inputTextView.text = [toBeString substringToIndex:500];
                //                self.labelCount.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)inputTextView.text.length];
            }
        }       // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length >= 500) {
            [self showJGProgressWithMsg:@"最多输入500字"];
            inputTextView.text = [toBeString substringToIndex:500];
        }
    }
}/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
