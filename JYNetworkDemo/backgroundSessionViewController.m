//
//  backgroundSessionViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/24.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "backgroundSessionViewController.h"
#import "AppDelegate.h"
#import "const.h"

static NSString * const download_url = @"http://img.blog.csdn.net/20160823161814146";
static NSString * const download_book_url = @"http://dl.download.csdn.net/down10/20140604/8e7db27fb09bf1dfc59cc7b2b0939e58.docx?response-content-disposition=attachment%3Bfilename%3D%22Apple%20Swift%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B.docx%22&OSSAccessKeyId=9q6nvzoJGowBj4q1&Expires=1470385444&Signature=kAM1C1UFk6yi25EzzIdpg6FG8UI%3D";

static NSString * const backgroundSessionIdentifier = @"com.jy.networking.session.background1";

@interface backgroundSessionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *loadBtn;
@property (weak, nonatomic) IBOutlet UIButton *testBtn;

@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation backgroundSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化
//    self.backgroundSession= [self backgroundSession];
}

- (NSURLSession *)backgroundSession {
   // 使用dispatch_once 确保应用程序实例中没有创建相同标识符的多个后台会话。如果想在一个线程中支持多个后台会话，则应给每个后台会话配置自己的标志符
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: backgroundSessionIdentifier];
        session = [NSURLSession sessionWithConfiguration:configuration];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];// NSURLSessionDelegate
    });
    return session;
}

#pragma mark NSURLSessionDelegate
// 当程序收到-application:handleEventsForBackgroundURLSession:completionHandler:消息时，
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *pDelegate = [UIApplication sharedApplication].delegate;
    if (pDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = pDelegate.backgroundSessionCompletionHandler;
        pDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"All tasks are finished");
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    YLog(@"hello");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [URLs objectAtIndex:0];
    
    NSURL *originURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentDirectory URLByAppendingPathComponent:[originURL lastPathComponent]];
    NSError *errorCopy;
    
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    if (errorCopy) {
        YLog(@"Error during copy:%@", errorCopy.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadBtn.titleLabel.text = @"加载失败!";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
            self.imageView.image = image;
            self.loadBtn.titleLabel.text = @"加载成功";
        });
    }
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"receive data");
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    YLog();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startLoadPictureAction:(id)sender {
    if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadBtn.titleLabel.text = @"加载中..";
    });
    NSURL *downloadURL = [NSURL URLWithString:download_book_url];
    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];
    
    // 显示" background URLSession with identifier com.jy.networking.session.background1 already exists!"  ？？？
    self.downloadTask = [self.backgroundSession downloadTaskWithRequest: request];
    [self.downloadTask resume];
    
    // 崩溃信息：Completion handler blocks are not supported in background sessions. Use a delegate instead.
//    self.downloadTask = [self.backgroundSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//    }];
}
- (IBAction)testAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.testBtn.titleLabel.text = @"hi";
    });
}

- (void)dealloc {
    [self.downloadTask cancel];
//    [self.backgroundSession finishTasksAndInvalidate];
    [self.backgroundSession invalidateAndCancel];
}


@end
