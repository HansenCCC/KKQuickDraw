//
//  KKUIWebViewController.m
//  lwui
//
//  Created by Herson on 2018/1/5.
//  Copyright © 2018年 力王. All rights reserved.
//

#import "KKUIWebViewController.h"
#import "KKWKURLSchemeHandler.h"

@interface KKUIWebViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic, strong) UIProgressView *progressView;

@end
@implementation KKUIWebViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(backItemClick)];
    //web配置
    [self webViewConfig];
    [self addObserverNotification];
}
//web配置
- (void)webViewConfig{
    //监听进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self addScriptMessageHandler];
}
- (void)backItemClick{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self removeScriptMessageHandlerForName];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)setRequestURL:(NSURL *)requestURL{
    _requestURL = requestURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [self.webView loadRequest:request];
}
- (void)loadRequest:(NSURLRequest *)request{
    [self.webView loadRequest:request];
}
- (void)loadHTMLString:(NSString *)string{
    [self.webView loadHTMLString:string baseURL:nil];
}
//添加通知
- (void)addObserverNotification{
    //to do
}
//添加js交互
- (void)addScriptMessageHandler{
//    WKWebViewConfiguration *configuration = self.webView.configuration;
//    [configuration.userContentController addScriptMessageHandler:self name:@"Share"];
}
//移除js交互
- (void)removeScriptMessageHandlerForName{
//    WKWebViewConfiguration *configuration = self.webView.configuration;
//    [configuration.userContentController removeScriptMessageHandlerForName:@"Share"];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGRect f1 = bounds;
    self.webView.frame = f1;
    //
    CGRect f2 = bounds;
    f2.size = [self.progressView sizeThatFits:CGSizeZero];
    f2.size.width = bounds.size.width;
    f2.origin.y = self.view.safeAreaInsets.top;
    self.progressView.frame = f2;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }else if (object == self.webView && [keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title?:@"";
    }
}
-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    NSLog(@"释放了%@",[self class]);
}
#pragma mark - lazy load
-(UIProgressView *)progressView{
    if(!_progressView){
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.trackTintColor = [UIColor clearColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}
-(WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        [configuration setValue:@YES forKey:@"_allowUniversalAccessFromFileURLs"];
        //设置URLSchemeHandler来处理特定URLScheme的请求，URLSchemeHandler需要实现WKURLSchemeHandler协议
        //本例中WKWebView将把URLScheme为customScheme的请求交由CustomURLSchemeHandler类的实例处理
        KKWKURLSchemeHandler *handler = [[KKWKURLSchemeHandler alloc] init];
        NSString *scheme = KKWKURLSchemeHandlerJoyFishScheme;
        NSString *schemes = [NSString stringWithFormat:@"%@s",scheme];
        //http + https
        [configuration setURLSchemeHandler:handler forURLScheme:scheme];
        [configuration setURLSchemeHandler:handler forURLScheme:schemes];
        //
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures=YES;
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //'UIAlertView' is deprecated: first deprecated in iOS 9.0 - UIAlertView is deprecated. Use UIAlertController with a preferredStyle of UIAlertControllerStyleAlert instead
    [[[UIAlertView alloc] initWithTitle:@"请求失败" message:@"请检查您的网络" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
    #pragma clang diagnostic pop
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //WKNavigationActionPolicyCancel 不是我们拦截的 || WKNavigationActionPolicyAllow 使我们拦截的
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}
#pragma mark - WKScriptMessageHandler
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    //to do
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"%@ - %@",message.name,message.body);
    dispatch_async(dispatch_get_main_queue(), ^{
        //to do
    });
}
@end
