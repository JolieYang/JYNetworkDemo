//
//  UploadViewController.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/8.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLSessionViewController : UIViewController

@end

// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i

// URL Loading System:
// ftp:// 文件传输协议
// http:// 超文本运输协议
// https://
// file:// 本地文件
// data:// data格式

// 获取数据到内存中

// NSURLSession 提供了丰富的代理方法，进行身份认证与提供后台下载功能
// NSURLSession API像大多数的网络API一样，高度异步(highly asynchronous) ，如果使用默认（系统提供的）代理方法，必须提供completionHandler Block（完成处理块）将数据返回给应用，不论是成功获取还是获取失败。
// 完成回调的主要用途是替代代理，如果创建了completion callback（完成回调）,那么代理方法就不会调用。
// 会话中的任务行为主要取决于三个因素：1) session(会话)类型; 2) task（任务）类型; 3)任务创建时应用是否在前台

