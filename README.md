
# KKQuickDraw

[![Build Status](https://img.shields.io/badge/Github-KKQuickDraw-brightgreen.svg)](https://github.com/HansenCCC/KKQuickDraw)
[![Build Status](https://img.shields.io/badge/platform-ios-orange.svg)](https://github.com/HansenCCC/KKQuickDraw)
[![Build Status](https://img.shields.io/badge/HansenCCC-Github-blue.svg)](https://github.com/HansenCCC)
[![Build Status](https://img.shields.io/badge/HansenCCC-知乎-lightgrey.svg)](https://www.zhihu.com/people/EngCCC)

## iOS通过WKWebView、WKURLSchemeHandler协议实现HTML H5秒开，优化HTML加载速度。（拦截请求替换资源）

<img src="https://pic1.zhimg.com/80/v2-f74308903ee858dbded344567f598e88.jpg" width="300" alt="demo页面"/><br/>

### 一、需求
##### HTML页面渲染出来的时间过长，影响用户体验。实现秒开H5功能。

### 二、网页加载过程
##### 1、首先我们要了解网页加载过程：初始化webview -> 请求页面 -> 下载数据 -> 解析HTML -> 请求 js/css 资源 -> dom 渲染 -> 解析 JS 执行 -> JS 请求数据 -> 解析渲染 -> 下载渲染图片。

### 三、秒开原理：
> 1、APP启动时预存HTML到本地 。
> 
> 2、启动时下载新的HTML文件去替换。
> 
> 3、用户点击页面准备加载HTML文件时。
> 
> 4、拦截请求资源，判断资源是否和本地资源一致。（一致则返回本地资源文件，不一致则请求网络资源）。

### 四、更新疑问
##### 每次请求都会下载最新HTML文件，是会实时更新的。

### 五、如何使用
##### demo只供参考，demo里面本地只缓存了HTML，还可以缓存js、css、img等资源进行资源替换，从而实现秒开，测试的话，可以在断网的情况下打开网页。代码如用于项目时，开发过程中碰到问题可以和H5工程师协调。

<img src="https://pic1.zhimg.com/80/v2-bb521652bdb14b0bc7c3751dd25cef40.jpg" width="300" alt="可以缓存html、css、img、js等文件"/><br/>

### 六、我碰到的问题

> **问题一**
我最开始尝试使用的是NSURLProtocol协议，去拦截所有的http+https请求。在WKWebView中确实可以实现资源拦截和替换，但是个别HTML文件，在使用POST请求时，发现body参数丢失，获取不到。尝试过把body缓存到求请求头header里面，效果没有那么好。而且使用NSURLProtocol，涉及到私有API，项目是需要提审上架的，所以放弃这种方式。

------------------

## 推荐参考
[WKWebview秒开的实践及踩坑之路][1]

[iOS app秒开H5优化探索][2]

------------------

## 我
#### Created by 程恒盛 on 2021/05/19.
#### Copyright © 2019 力王. All rights reserved.
#### QQ:2534550460@qq.com  GitHub:https://github.com/HansenCCC  tel:13767141841
#### copy请标明出处，感谢，谢谢观看


------------------

## 你还对这些感兴趣吗


1、[iOS实现HTML H5秒开、拦截请求替换资源、优化HTML加载速度][5]

2、[超级签名中最重要的一步：跳过双重认证，自动化脚本添加udid并下载描述文件（证书和bundleid不存在时，会自动创建）][6]

3、[脚本自动化批量修改ipa的icon、启动图、APP名称等(demo只修改icon，其他原理一样)、重签ipa][7]

4、[QMKKXProduct iOS技术分享][8]


  [1]: https://juejin.cn/post/6861778055178747911
  [2]: https://juejin.cn/post/6844903809521549320
  [3]: http://i2.tiimg.com/737869/5b55723ab7172298.png
  [4]: http://i2.tiimg.com/737869/ec381b1edbfe6de3.png
  [5]: https://github.com/HansenCCC/KKQuickDraw
  [6]: https://github.com/HansenCCC/HSAddUdids
  [7]: https://github.com/HansenCCC/HSIPAReplaceIcon
  [8]: https://github.com/HansenCCC/QMKKXProduct
