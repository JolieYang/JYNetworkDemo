//
//  UploadViewController.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/8.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLSessionViewController : UIViewController<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

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
// NSURLSession 提供会话的取消，重启(恢复),暂停并且当离开时还具备恢复属于暂停、取消、失败的下载任务的能力
// 会话中的任务行为主要取决于三个因素：1) session(会话)类型; 2) task（任务）类型; 3)任务创建时应用是否在前台
// Sessions的类型[通过NSURLSessionConfiguration设置类型]： 1) DefaultSessions.基于磁盘的缓存,存储认证信息(credential)到用户的keychain中; 2)EphemeralSessions.不会存储任何数据到磁盘中，所有的缓存，认证信息(credential)等都是临时保存在内存中，一旦会话失效，自动清除数据。 3) BackgorundSessions。存储这一块跟DefaultSession一样，也是基于磁盘存储，除此之外，应用会开启一个线程进行网络数据处理
// +(NSURLSession *)sessionWithConfiguration:delegate:delegateQueue; 
// Task类型： 1) Data Tasks: 获取NSData对象， 常用于应用向服务器发起的数据请求。数据格式常为JSON或XML 2) Download Tasks: 获取文件形式的数据，并提供后台模式下载。 3) Upload tasks: 发送文件形式的数据，同样提供后台上传



// 磁盘是通过磁性进行读写功能的设备, 分为两类，硬盘与软盘

