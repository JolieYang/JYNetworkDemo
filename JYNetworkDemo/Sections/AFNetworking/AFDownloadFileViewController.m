//
//  AFDownloadFileViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/20.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//
//  限制下载文件类型[solve]--> HEAD请求
//  限制下载文件大小[solve]--> HEAD请求
//  取消下载图片，恢复则会重新下载，没有缓存之前下载的[solved] --> 是因为我暂停任务的时候将任务设为nil

#import "AFDownloadFileViewController.h"
#import "CustomPreviewController.h"
#import "CacheNetService.h"

@interface AFDownloadFileViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@end

@implementation AFDownloadFileViewController
static NSString *Download_URL = nil;
static NSInteger Limit_Size = 0;// 单位为M
static NSArray *Support_MIMEType = nil;
static NSString *LOCAL_FILE_PATH = @"LOCAL_FILE_PATH";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupData];
}

- (void)setupData {
    Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/%E6%9E%81%E7%AE%80%E5%94%AF%E7%BE%8E.pptx";// application/octet-stream 2048835 极简唯美.pptx
//    Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/%E7%94%B5%E8%AF%9D%E6%8C%87%E5%8D%972017%E5%B9%B42%E6%9C%88%E4%BB%BD%E6%9B%B4%E6%96%B0%E9%9B%86%E5%9B%A2.xls";// application/octet-stream 1805824 电话指南2017年2月份更新集团.xls
//    Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/zip%E5%BD%92%E6%A1%A3.zip";// application/zip 1688858 zip归档.zip
//    Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/Free-Converter.com-20170323224402-4184295600.7z";//
//    Download_URL = @"https://raw.githubusercontent.com/JolieYang/Picture/master/Mail/gray_girl.png";
        Download_URL = @"http://img.blog.csdn.net/20160822174348226";
    //    Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/1-1F303161315.rar";// application/octet-stream 1982573 1-1F303161315.rar
//        Download_URL = @"https://github.com/JolieYang/Picture/raw/master/Mail/AFnetworking%E6%96%87%E6%A1%A3.docx";// application/octet-stream 101067 AFnetworking文档.docx
    
    Limit_Size = 10;
    Support_MIMEType = @[@"image/png", @"application/octet-stream", @"application/zip",@"application/x-7z-compressed"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- Action
// 开始下载
- (IBAction)startDownload:(id)sender {
    UIButton *selectedBtn = (id)sender;
    if ([selectedBtn.currentTitle isEqualToString:@"开始下载"]) {
        [self downloadTaskWithString:Download_URL];
        [selectedBtn setTitle:@"取消下载" forState:UIControlStateNormal];
    } else {
        [selectedBtn setTitle:@"开始下载" forState:UIControlStateNormal];
//        [self.downloadTask suspend];
    }
}

// 从本地加载
- (IBAction)quickLookLocalFileAction:(UIButton *)sender {
    if ([self existCache]) {
        // 从本地获取
        NSURL *filePath = [[NSUserDefaults standardUserDefaults] URLForKey:LOCAL_FILE_PATH];
        [self jumpToPreviewControllerWithFilePath:filePath];
        [sender setTitle:@"从本地加载" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"本地无数据" forState:UIControlStateNormal];
    }
}
- (IBAction)deleteCacheAction:(id)sender {
    [[CacheNetService sharedService] removeCacheForURL:Download_URL];
}

- (void)downloadTaskWithString:(NSString *)urlString {
    __weak typeof(self) weakSelf = self;
    [[CacheNetService sharedService] downloadTaskWithString:urlString progress:^(NSProgress *downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
            [weakSelf updateProgressUIWithProgress:progress];
        });
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"show httpResponse:%@", httpResponse);
        if (!error) {
            NSLog(@"success download");
            // 进入显示页面
            [self jumpToPreviewControllerWithFilePath:filePath];
        }
    }];
}

#pragma mark -- UI
- (void)updateProgressUIWithProgress:(float)progress {
    self.progressView.progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度为:%.2f%%", progress * 100];
}

- (void)jumpToPreviewControllerWithFilePath:(NSURL *)filePath {
    CustomPreviewController *vc = [[CustomPreviewController alloc] initWithFilePath:filePath];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- Tool
/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

- (BOOL)existCache {
    if ([[NSUserDefaults standardUserDefaults] URLForKey:LOCAL_FILE_PATH]) {
        return YES;
    }
    return NO;
}

- (NSString *)cachesPathWithFileDir:(NSString *)fileDictory {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDictory ? fileDictory : @"Download"];
}
@end
