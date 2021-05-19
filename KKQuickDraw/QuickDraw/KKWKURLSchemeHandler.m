//
//  KKWKURLSchemeHandler.m
//  KKQuickDraw
//
//  Created by Hansen on 5/17/21.
//  Copyright © 2021 力王工作室. All rights reserved.
//

#import "KKWKURLSchemeHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>


NSString *KKWKURLSchemeHandlerJoyFishScheme = @"iosqmkkx";//设置拦截schema
@interface KKWKURLSchemeHandler ()
@property (strong, nonatomic) NSMutableDictionary *holdUrlSchemeTasks;

@end

@implementation KKWKURLSchemeHandler
- (instancetype)init{
    if (self = [super init]) {
        self.holdUrlSchemeTasks = [[NSMutableDictionary alloc] init];
    }
    return self;
}
#pragma mark - WKURLSchemeHandler
//当 WKWebView 开始加载自定义scheme的资源时，会调用
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask{
    self.holdUrlSchemeTasks[urlSchemeTask.description] = @(YES);
    //逻辑：每次启动，下载网络html，优先加载本地资源，本地没有加载网络资源化
    NSString *urlString = urlSchemeTask.request.URL.absoluteString;
    NSString *fileName = [urlString lastPathComponent];
    NSString *markStrig = [NSString stringWithFormat:@"%@/",[self.class fileName]];
    NSRange range = [urlString rangeOfString:markStrig];
    if (range.location != NSNotFound) {
        fileName = [urlString substringFromIndex:range.location];
    }
    //资源路径
    NSString *mainBundlePath = [self.class filePath];
    NSString *htmlPath = [mainBundlePath stringByAppendingFormat:@"/"];
    NSString *filePath = [htmlPath stringByAppendingFormat:@"%@",fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断文件是否存在
    if ([fileManager fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *type = [self getMimeTypeWithFilePath:filePath];
        if (type.length == 0) {
            type = @"text/html";
        }
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:type expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    }else{
        NSString *schemeUrl = urlSchemeTask.request.URL.absoluteString;
        if ([schemeUrl hasPrefix:KKWKURLSchemeHandlerJoyFishScheme]) {
            schemeUrl = [schemeUrl stringByReplacingOccurrencesOfString:KKWKURLSchemeHandlerJoyFishScheme withString:@"http"];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:schemeUrl]];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *number = self.holdUrlSchemeTasks[urlSchemeTask.description];
                BOOL flag = number.boolValue;
                if (flag == NO) {
                    return;
                }
                if (response) {
                    [urlSchemeTask didReceiveResponse:response];
                }else{
                    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"空类型" expectedContentLength:data.length textEncodingName:nil];
                    [urlSchemeTask didReceiveResponse:response];
                }
                [urlSchemeTask didReceiveData:data];
                if (error) {
                    [urlSchemeTask didFailWithError:error];
                } else {
                    [urlSchemeTask didFinish];
                }
            });
        }];
        [dataTask resume];
    }
}
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.holdUrlSchemeTasks[urlSchemeTask.description] = @(NO);
    });
}
#pragma mark - Public
//APP首次启动调用，启动缓存模式。
//把项目html资源转移到都NSDocumentDirectory下面。（文件存在的情况下，不做拷贝）
+ (void)setupHTMLCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *markStrig = [NSString stringWithFormat:@"%@",[self fileName]];;
    NSString *fromPath = [NSString stringWithFormat:@"%@/%@",resourcePath,markStrig];
    NSString *toPath = [NSString stringWithFormat:@"%@/%@",[self filePath],markStrig];
    //清空缓存
    [self cleanHTMLCache];
    NSError *error;
    //copy缓存
    [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
    if (!error) {
    }else{
        [NSException raise:@"copy文件错误" format:@"%@",error];
    }
}
//异步下载HTML文件，预先缓存。
+ (void)downloadHTMLCache:(NSArray *)items{
    NSString *markStrig = [NSString stringWithFormat:@"%@/",[self fileName]];;
    //设置html存储路径
    NSString *mainBundlePath = [self filePath];
    NSString *htmlPath = [mainBundlePath stringByAppendingFormat:@"/%@",markStrig];
    //资源路径
    for (NSString *htmlURL in items) {
        //此方法相当于发送一个GET请求，直接将服务器的数据一次性下载下来
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *url = [NSURL URLWithString:htmlURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSString *fileName = [url lastPathComponent];
            NSString *filePath = [htmlPath stringByAppendingFormat:@"%@",fileName];
            if (![fileManager fileExistsAtPath:htmlPath]) {
                [fileManager createDirectoryAtPath:htmlPath withIntermediateDirectories:YES attributes:nil error:nil];
            };
            //数据存在
            if (data) {
                //判断文件是否存在
                if ([fileManager fileExistsAtPath:filePath]) {
                    //文件存在，存在对比差异，存在差异直接覆盖
                    NSData *oldData = [fileManager contentsAtPath:filePath];
                    if ([oldData isEqualToData:data]) {
                        //文件没有差异，不替换
                    }else{
                        //文件存在差异，先删除旧的文件再保存
                        NSError *error;
                        BOOL flag = [fileManager removeItemAtPath:filePath error:&error];
                        if (flag) {
                            //写入文件
                            [data writeToFile:filePath atomically:YES];
                        }else{
                            //失败
                            [NSException raise:@"删除文件错误，请注意" format:@"%@",error];
                        }
                    }
                }else{
                    //文件不存在，直接写入文件
                    [data writeToFile:filePath atomically:YES];
                }
            }else{
                //数据加载失败，不做处理
            }
        });
    }
}
//轮询缓存目录下，是否存在匹配的HTML。
//存在：url改为本地url文件路径地址。不存在：url不变
+ (NSURL *)htmlFileExistsAtPath:(NSURL *)requestURL{
    NSString *urlString = requestURL.absoluteString;
    NSString *fileName = [urlString lastPathComponent];
    NSString *markStrig = [NSString stringWithFormat:@"%@/",[self fileName]];;
    NSRange range = [urlString rangeOfString:markStrig];
    if (range.location != NSNotFound) {
        fileName = [urlString substringFromIndex:range.location];
    }
    //资源路径
    NSString *mainBundlePath = [self filePath];
    NSString *htmlPath = [mainBundlePath stringByAppendingFormat:@"/"];
    NSString *filePath = [htmlPath stringByAppendingFormat:@"%@",fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = [fileManager fileExistsAtPath:filePath];
    if (flag) {
        NSString *string = [requestURL.absoluteString stringByReplacingOccurrencesOfString:@"http" withString:KKWKURLSchemeHandlerJoyFishScheme];
        requestURL = [NSURL URLWithString:string];
    }
    return requestURL;
}
//清空本地缓存
+ (void)cleanHTMLCache{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *markStrig = [NSString stringWithFormat:@"%@",[self fileName]];;
    NSString *toPath = [NSString stringWithFormat:@"%@/%@",[self filePath],markStrig];
    BOOL flag = [fileManager fileExistsAtPath:toPath];
    if (flag) {
        //清空缓存
        NSError *flagError;
        [fileManager removeItemAtPath:toPath error:&flagError];
    }
}
//缓存的文件路径
+ (NSString *)fileName{
    return @"HansenCCC";
}
//缓存的文件路径
+ (NSString *)filePath{
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return filePath;
}
#pragma mark - .m
//根据Data文件路径获取文件类型MIMEType
- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath{
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    //The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    return mimeType;
}
@end
