//
//  ViewController.m
//  KKQuickDraw
//
//  Created by Hansen on 5/17/21.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "KKWKURLSchemeHandler.h"
#import "KKUIWebViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UIView *contentView;

@end

@implementation ViewController{
    UIButton *_tmpButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实现HTML网页秒开";
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:self.contentView];
    //系统
    [self buttonWithTitle:@"加载未缓存网页（系统）"];
    [self buttonWithTitle:@"清除WKWeb缓存（系统）"];
    //秒开
    [self buttonWithTitle:@"开始缓存HTML文件（https://github.com/HansenCCC/HSAddUdids）"];
    [self buttonWithTitle:@"加载已缓存网页（秒开）"];
    [self buttonWithTitle:@"清除已缓存HMTL文件（秒开）"];
}
- (void)whenButtonClick:(UIButton *)sender{
    NSURL *requestURL = [NSURL URLWithString:@"https://github.com/HansenCCC/HSAddUdids"];
    if (sender.tag == 1) {
        KKUIWebViewController *vc = [[KKUIWebViewController alloc] init];
        vc.requestURL = requestURL;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 2) {
        //清空缓存
        [self deleteWebCache];
    }else if (sender.tag == 3) {
        [KKWKURLSchemeHandler downloadHTMLCache:@[
            requestURL.absoluteString,
        ]];
    }else if (sender.tag == 4) {
        KKUIWebViewController *vc = [[KKUIWebViewController alloc] init];
        //启用缓存，监管scheme
        requestURL = [KKWKURLSchemeHandler htmlFileExistsAtPath:requestURL];
        vc.requestURL = requestURL;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 5) {
        [KKWKURLSchemeHandler cleanHTMLCache];
    }
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGRect f1 = bounds;
    NSInteger count = self.contentView.subviews.count;
    f1.size.height = count * 50 + (count + 1) * 10;
    f1.origin.y = self.view.safeAreaInsets.top;
    self.contentView.frame = f1;
}
- (UIButton *)buttonWithTitle:(NSString *)title{
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(whenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:rand()%255/255.f green:rand()%255/255.f blue:rand()%255/255.f alpha:1];
    button.layer.cornerRadius = 10.f;
    [self.contentView addSubview:button];
    CGRect bounds = self.view.bounds;
    CGRect f1 = bounds;
    f1.size.width -= 50.f;
    f1.size.height = 50.f;
    f1.origin.x = (bounds.size.width - f1.size.width)/2.0;
    f1.origin.y = CGRectGetMaxY(_tmpButton.frame) + 10.f;
    button.frame = f1;
    button.tag += _tmpButton.tag + 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    _tmpButton = button;
    return button;
}
#pragma mark - 清空wkweb缓存
- (void)deleteWebCache{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            //to do
        }];
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray * __nonnull records) {
            for (WKWebsiteDataRecord *record in records){
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                    NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                }];
            }
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}
@end
