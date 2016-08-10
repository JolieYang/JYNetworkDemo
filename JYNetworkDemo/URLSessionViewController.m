//
//  UploadViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/8.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "URLSessionViewController.h"

#define kURL @"http://dl.download.csdn.net/down10/20140604/8e7db27fb09bf1dfc59cc7b2b0939e58.docx?response-content-disposition=attachment%3Bfilename%3D%22Apple%20Swift%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B.docx%22&OSSAccessKeyId=9q6nvzoJGowBj4q1&Expires=1470385444&Signature=kAM1C1UFk6yi25EzzIdpg6FG8UI%3D"

@interface URLSessionViewController () {
    NSURLSessionDownloadTask *_downloadTask;
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet UIProgressView *progressView;
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UIButton *button;
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

- (IBAction)downloadAction:(id)sender {
    [self sendURLRequest];
//    [self downloadFileByBackgroundSession];
//    [self downloadFileBySession];
//    [self downloadFileByBackgroundSession];
}


- (void)cancelDownload {
    [_downloadTask cancel];
}
- (void)suspendDownload {
    [_downloadTask suspend];
}
- (void)resumeDownload {
    [_downloadTask resume];
}

// 通过代理检测下载进度
#pragma mark P1:发送请求
- (void)sendURLRequest {
    // 1. 创建url
    NSString *urlStr = [NSString stringWithFormat:@"%@", kURL];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3. 创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self loadData:data];
        } else {
            NSLog(@"error :%@", error.localizedDescription);
        }
    }];
    // 可实时监测请求进展
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    
    [dataTask resume];
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 设置允许处理响应才会执行后面两个操作
    NSLog(@"%s", __func__);
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

#pragma mark P3:下载数据 ok
- (void)downloadFileBySession {
    NSString *urlStr = kURL;
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
//    NSURLSession *session = [NSURLSession sharedSession]; // 使用系统共享实例，则没有进入代理
    _downloadTask = [session downloadTaskWithRequest:request];
    
    [_downloadTask resume];
}
#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 更新进度条
    NSLog(@"%s", __func__);
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%s", __func__);
    NSError *error;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:@"a.text"];
    NSURL *saveURL = [NSURL fileURLWithPath:savePath];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&error];
    if (error) {
        NSLog(@"Error :%@", error.localizedDescription);
    }
}


#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s", __func__);
    // 请求完成，成功或者失败的处理
    if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
    }
}



#pragma mark P4:NSURLSession backgroundSessionConfiguration
- (void)downloadFileByBackgroundSession {
    NSString *urlStr = kURL;
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
    NSLog(@"%s",__func__);
}

#pragma mark Util
- (void)loadData:(NSData *)data {
    NSLog(@"%s", __func__);
}
@end
