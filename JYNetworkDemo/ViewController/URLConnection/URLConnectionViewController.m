//
//  ViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/5.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "URLConnectionViewController.h"

#define FILE_SECTION_SIZE (1024)
#define kURL @""

@interface URLConnectionViewController ()<NSURLConnectionDataDelegate> {
    NSString *_userName;
    NSString *_password;
    
    NSMutableData *_data; // 响应数据
    long long totalLength;
    long long loadedLength;
    
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet UIProgressView *progressView;
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UIButton *button;
}

@end

@implementation URLConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    progressView.progress = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downloadAction:(id)sender {
    [self sendRequest];
}

#pragma mark P1: 发送请求
- (void)sendConnectionRequest {
    NSString *urlStr = [NSString stringWithFormat:@"%@", kURL];
    // 对url中的中文就行编码。其中url解码使用stringByRemovingPercentEncoding
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //  创建可变请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:@"POST"];
    // 设置POST参数
    NSString *bodyDataStr = [NSString stringWithFormat:@"username=%@&password=%@", _userName, _password];
    NSData *bodyData = [bodyDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    // 发送异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError != nil || data == nil) {
            NSLog(@"网络不给力");
            NSLog(@"error :%@", connectionError.localizedDescription);
            return ;
        } else {
            [self loadData:data];
        }
    }];
}

#pragma mark P2:分段下载

// #define FILE_SECTION_SIZE (1024) // 即每次1kb
// 异步下载文件
- (void)downloadFileAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self downloadFile];
    });
}
// 文件下载
- (void)downloadFile {
    totalLength = [self getFileTotlaLength];
    loadedLength = 0;
    long long startSize = 0;
    long long endSize = 0;
    // 分段下载
    while (startSize < totalLength) {
        endSize = startSize + FILE_SECTION_SIZE - 1;
        if (endSize > totalLength) {
            endSize = totalLength - 1;
        }
        [self downloadFile:@"" startByte:startSize endByte:endSize];
        
        // 更新进度
        loadedLength += (endSize - startSize) + 1;
        
        startSize += FILE_SECTION_SIZE;
    }
}
// 取得文件大小
- (long long)getFileTotlaLength {
    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    [request setHTTPMethod:@"HEAD"];
    
    NSURLResponse *response;
    NSError *error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"send getHead request error:%@", error.localizedDescription);
    }
    return response.expectedContentLength;
}

// 下载指定块大小区域的数据
- (void)downloadFile:(NSString *)fileName startByte:(long long)start endByte:(long long)end {
    NSString *range = [NSString stringWithFormat:@"Bytes=%lld-%lld", start,end];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@""]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"send getHead request error:%@", error.localizedDescription);
    } else {
        [self fileAppend:@"savePath" data: data];
    }
    
}
// 追加文件
- (void)fileAppend:(NSString *)filePath data:(NSData *)data {
    // 以可写方式打开文件
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (fileHandler) {
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:data];
        [fileHandler closeFile];
    } else {
        [data writeToFile:filePath atomically:YES]; // 不存在创建文件
    }
}



#pragma mark P3:通过代理，发送请求，接收数据。实际开发中一般不使用该方法
- (void)sendRequest {
    NSString *urlStr = [NSString stringWithFormat:@"http://dl.download.csdn.net/down10/20140604/8e7db27fb09bf1dfc59cc7b2b0939e58.docx?response-content-disposition=attachment%3Bfilename%3D%22Apple%20Swift%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B.docx%22&OSSAccessKeyId=9q6nvzoJGowBj4q1&Expires=1470385444&Signature=kAM1C1UFk6yi25EzzIdpg6FG8UI%3D"];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    _data = [[NSMutableData alloc] init];
    progressView.progress = 0;
    
    // 通过响应头中的content-length取得整个响应的长度
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpResponseHeaderFields = httpResponse.allHeaderFields;
    totalLength = [[httpResponseHeaderFields valueForKey:@"Content-Length"] longLongValue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    [_data appendData: data];
    [self updateProgress];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    savePath = [savePath stringByAppendingPathComponent:textField.text];
    [_data writeToFile:savePath atomically:YES];
}

#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError:%@", error.localizedDescription);
}


#pragma mark Util
- (void)loadData:(NSData *)data {
    
}
- (void)updateProgress {
    if (_data.length == totalLength) {
        label.text = @"下载完成";
    } else {
        label.text = @"正在下载...";
        [progressView setProgress:(float)_data.length/totalLength animated:YES];
    }
}

@end
