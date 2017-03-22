//
//  defaultSessionViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/26.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "defaultSessionViewController.h"

static NSString *flower_url = @"http://img.blog.csdn.net/20160822174348226";

@interface defaultSessionViewController ()<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *loadBtn;

@property (nonatomic, strong) NSURLSessionTask *downloadTask;
@end

@implementation defaultSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
// 加载
- (IBAction)loadAction:(id)sender {
    // 1. URL 请求
    NSString *urlStr = flower_url;
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // 2. 创建会话
    // 2.1 配置会话
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    configuration.timeoutIntervalForRequest = 15.0f;
    configuration.allowsCellularAccess = true;
    // 2.2 创建
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.downloadTask = [session downloadTaskWithRequest:urlRequest];
    
    [self.downloadTask resume];
    [self.loadBtn setTitle:@"正在下载..." forState:UIControlStateNormal];
}
//取消
- (IBAction)cancelAction:(id)sender {
    if ([self.downloadTask state] != NSURLSessionTaskStateRunning) {
        return;
    }
    [self.downloadTask cancel];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadBtn setTitle:@"已取消下载" forState:UIControlStateNormal];
    });
}
//挂起
- (IBAction)suspendAction:(id)sender {
    if ([self.downloadTask state] != NSURLSessionTaskStateRunning) {
        return;
    }
    [self.downloadTask suspend];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.loadBtn setTitle:@"挂起下载" forState:UIControlStateNormal];
}
//恢复
- (IBAction)resumeAction:(id)sender {
    if ([self.downloadTask state] != NSURLSessionTaskStateSuspended) {
        return;
    }
    [self.downloadTask resume];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.loadBtn setTitle:@"恢复下载中..." forState:UIControlStateNormal];
}

#pragma mark NSURLSessionDelegate

#pragma mark NSURLSessionTaskDelegate
// 完成任务。  下载可能成功可能失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        NSLog(@"error:%@", error.localizedDescription);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    NSLog(@"complete");
}

#pragma mark NSURLSessionDownloadDelegate
// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"download complete");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [URLs objectAtIndex:0];
    
    NSURL *originURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentDirectory URLByAppendingPathComponent:[originURL lastPathComponent]];
    NSError *errorCopy;
    
    BOOL removeSuccess = [fileManager removeItemAtURL:destinationURL error:NULL];
    if (!removeSuccess) {
        NSLog(@"remove failed");
    }
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    if (!errorCopy) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithContentsOfFile:[destinationURL path]];
        });
    }
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
   dispatch_async(dispatch_get_main_queue(), ^{
       self.progressView.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
       if (totalBytesWritten == totalBytesExpectedToWrite) {
           // 下载完成
           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
           [self.loadBtn setTitle:@"下载完成" forState:UIControlStateNormal];
       } else {
           // 正在下载
           [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
       }
   });
}
@end
