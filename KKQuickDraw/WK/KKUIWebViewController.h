//
//  KKUIWebViewController.h
//  lwui
//  封装webview
//  Created by Herson on 2018/1/5.
//  Copyright © 2018年 力王. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
/*
 js交互
 //关闭当前页面：closePage()
 ios：window.webkit.messageHandlers.toLogin.postMessage()
 android：verify.toLogin()
 web -> js 例如
    增加监听
    WKWebViewConfiguration *configuration = self.webView.configuration;
    [configuration.userContentController addScriptMessageHandler:self name:@"goBack"];
    接收监听
    - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
 js -> web 例如
    [self.webView evaluateJavaScript:@"window.loadComment()" completionHandler:nil];
 
 */
@interface KKUIWebViewController : UIViewController
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *requestURL;


@end
