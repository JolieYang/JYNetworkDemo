//
//  backgroundSessionViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/24.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

// Tips:
// T1: 后台会话模式不可使用Block获取数据，需通过delegate回调。
// Question List:
// ?1.[solved] 显示" background URLSession with identifier com.jy.networking.session.background1 already exists!"  // 因为在session单例中我先执行了sessionWithConfiguration,sessionWithConfiguration:delegate。 所以才会不进入回调。问题反思： 昨天在这个问题上，有个细节我发现了，就是一直没有进入NSURLSessionDownloadDelegate相关的回调方法，但是没有思考这背后的原因，通过sessionWithConfiguration获取session时，再进行sessionWithconfiguration:delegate:delegateQueue时这一步是失败的。至少在发起回调的地方应该检查下很奇怪编译器为什么没有在这里崩溃呢，而是报错信息。25th,August,2016
// ?2.[solved] button的更新 一开始button内容更新使用的是titleLabel.text修改文本， 现象是点击加载切换成加载中，但当加载完成后本应显示“加载成功”但是闪现“加载成功”后现实的是在Storyboard中设置的默认文本“加载图片”。 分析： 查看了下titleLabel，发现该属性是只读的，然后再查看了text属性strong，可读写。感觉编译器应该不允许这样的行为吧，既然titleLabel不可写，那么titleLabel里面的属性应该也不可写吧。正确的button文本更新方式 setTitle:forState
// ?3.[needSolve] 返回上一级界面再进入该页面就无法更新imageView了，为什么啊

#import "backgroundSessionViewController.h"
#import "AppDelegate.h"
#import "const.h"

static NSString * const download_url = @"http://img.blog.csdn.net/20160823161814146";

static NSString * const backgroundSessionIdentifier = @"com.jy.networking.session.background1";

@interface backgroundSessionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *loadBtn;

@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation backgroundSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化
    self.imageView.hidden = NO;
}

- (NSURLSession *)backgroundSession {
   // 使用dispatch_once 确保应用程序实例中没有创建相同标识符的多个后台会话。如果想在一个线程中支持多个后台会话，则应给每个后台会话配置自己的标志符
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: backgroundSessionIdentifier];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];// NSURLSessionDelegate
    });
    return session;
}

// 从网络加载图片
- (IBAction)startLoadPictureAction:(id)sender {
    [self.loadBtn setTitle:@"加载中" forState:UIControlStateNormal];
    self.imageView.image = [UIImage imageNamed:@"default_image"];
    
    if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
        return;
    }
    
    NSURL *downloadURL = [NSURL URLWithString:download_url];
    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];
    
    // ?1. 显示" background URLSession with identifier com.jy.networking.session.background1 already exists!"
    self.downloadTask = [self.backgroundSession downloadTaskWithRequest: request];
    [self.downloadTask resume];
    
    // 崩溃信息：Completion handler blocks are not supported in background sessions. Use a delegate instead.
    //    self.downloadTask = [self.backgroundSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //
    //    }];
}
// 从本地加载图片
- (IBAction)setLocalPictureAction:(id)sender {
    self.imageView.image = [UIImage imageNamed:@"download_failed"];
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
    if (errorCopy) {
        YLog(@"Error during copy:%@", errorCopy.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageNamed:@"download_failed"];
            [self.loadBtn setTitle:@"加载失败" forState:UIControlStateNormal];
        });
    } else {
        YLog(@"loading success");
        dispatch_async(dispatch_get_main_queue(), ^{
            // ?3. 返回上一级界面再进入该页面就无法更新imageView了，为什么啊
            UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
            [self.imageView setImage:image];
            [self.loadBtn setTitle:@"加载成功" forState:UIControlStateNormal];
        });
    }
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask == self.downloadTask) {// 多个进程时
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新进度条
            YLog(@"%f",progress);
        });
    }
    NSLog(@"receive data");
}

#pragma mark NSURLSessionTaskDelegate
// 没有发生错误也会进入该回调，所以要先判断是否有错误
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (error) {
        YLog(@"%@", error.localizedDescription);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.loadBtn setTitle:@"加载失败" forState:UIControlStateNormal];
        });
    }
    
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新进度条
        YLog(@"%f",progress);
    });
    
    self.downloadTask = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
