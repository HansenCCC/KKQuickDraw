//
//  KKWKURLSchemeHandler.h
//  KKQuickDraw
//
//  Created by Hansen on 5/17/21.
//  Copyright © 2021 力王工作室. All rights reserved.
//

/*
 需求：HTML页面渲染出来的时间过长，影响用户体验。实现秒开H5功能。
 网页加载过程：初始化webview -> 请求页面 -> 下载数据 -> 解析HTML -> 请求 js/css 资源 -> dom 渲染 -> 解析 JS 执行 -> JS 请求数据 -> 解析渲染 -> 下载渲染图片。
 秒开原理：APP启动时预存HTML到本地 -> 启动时下载新的HTML文件去替换 -> 用户点击页面准备加载HTML文件时 -> 拦截请求资源，判断资源是否和本地资源一致。（一致则返回本地资源文件，不一致则请求网络资源）。
 更新疑问：每次请求都会下载最新HTML文件，是会实时更新的。
 */

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
extern NSString *KKWKURLSchemeHandlerJoyFishScheme;//设置拦截schema
@interface KKWKURLSchemeHandler : NSObject<WKURLSchemeHandler>

/// APP首次启动调用，启动缓存模式。把项目html资源转移到都NSDocumentDirectory下面。（文件存在的情况下，不做拷贝）
+ (void)setupHTMLCache;

/// 轮询缓存目录下，是否存在匹配的HTML。(存在：url改为本地url文件路径地址。不存在：url不变)
/// @param url 资源url
+ (NSURL *)htmlFileExistsAtPath:(NSURL *)url;


/// 异步下载HTML文件，预先缓存。
/// @param items 资源数组
+ (void)downloadHTMLCache:(NSArray *)items;

/// 缓存的文件路径
+ (NSString *)fileName;

/// 缓存的路径名字
+ (NSString *)filePath;

/// 清空本地缓存
+ (void)cleanHTMLCache;

@end

