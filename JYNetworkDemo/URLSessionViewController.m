//
//  UploadViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/8.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "URLSessionViewController.h"

#define kURL @""

@interface URLSessionViewController () {
    NSURLSessionDownloadTask *_downloadTask;
}

@end

@implementation URLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark P1:发送请求
- (void)sendURLRequest {
    // 1. 创建url
    NSString *urlStr = [NSString stringWithFormat:@"%@", kURL];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self loadData:data];
        } else {
            NSLog(@"error :%@", error.localizedDescription);
        }
    }];
    
    [dataTask resume];
}
#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    // 请求完成，成功或者失败的处理
}
#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 设置允许处理响应才会执行后面两个操作
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%s", __func__);
}
#pragma mark P2: 上传数据
- (NSString *)getMIMETypes:(NSString *)fileName {
    return @"image/jpeg";
}
- (NSData *)getHttpBody:(NSString *)fileName {
    NSString *boundary=@"JolieYang";
    NSMutableData *dataM = [NSMutableData data];
    NSString *strTop = [NSString stringWithFormat:@"--%@\nContent-Disposition: form-data; name=\"field1\"; filename=\"%@\"\nContent-Type:%@\n\n", boundary, fileName, [self getMIMETypes:fileName]];
    NSString *strBottom = [NSString stringWithFormat:@"\n--%@--", boundary];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    [dataM appendData: [strTop dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData: fileData];
    [dataM appendData: [strBottom dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM;
}
- (void)uploadFile: (NSString *)fileName {
    NSString *boundary = @"JolieYang";
    // 1. 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@""] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0f];
    request.HTTPMethod = @"POST";
    
    
    // 2. 构建数据
    NSData *bodyData = [self getHttpBody:fileName];
    [request setValue:[NSString stringWithFormat:@"%lu", bodyData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = bodyData;
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"error:%@", error.localizedDescription);
        }
    }];
    
    [uploadTask resume];
}

#pragma mark P3:下载数据
- (void)downloadFileBySession {
    NSString *urlStr = @"";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 1. 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 2. 创建会话配置
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 5.0f;
    sessionConfig.allowsCellularAccess = YES;
    
    // 3. 创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    _downloadTask = [session downloadTaskWithRequest:request];
    
    [_downloadTask resume];
}
#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 更新进度条
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSError *error;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:@"a.text"];
    NSURL *saveURL = [NSURL fileURLWithPath:savePath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&error];
    if (error) {
        NSLog(@"Error :%@", error.localizedDescription);
    }
}
//#pragma mark NSURLSessionTaskDelegate
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didCompleteWithError:(nullable NSError *)error {
//    if (error) {
//        NSLog(@"Error:%@", error.localizedDescription);
//    }
//}

- (void)cancelDownload {
    [_downloadTask cancel];
}
- (void)suspendDownload {
    [_downloadTask suspend];
}
- (void)resumeDownload {
    [_downloadTask resume];
}


#pragma mark P4:NSURLSession backgroundSessionConfiguration
- (void)downloadFileByBackgroundSession {
    NSString *urlStr = @"";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 1. 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    _downloadTask = [[self backgroundSession] downloadTaskWithRequest:request];
    
    [_downloadTask resume];
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.jy.URLSession"];
        sessionConfig.timeoutIntervalForRequest = 5.0f;
        sessionConfig.discretionary = YES; // 系统自行决定，用于节省蜂窝流量，并会把WiFi和电源可用性考虑在内
        sessionConfig.HTTPMaximumConnectionsPerHost = 5; // 限制每次连接到特定主机的数量
        
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
    });
    
    return session;
}
#pragma mark NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

#pragma mark Util
- (void)loadData:(NSData *)data {
    
}
@end
