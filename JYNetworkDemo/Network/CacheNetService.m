//
//  CacheNetService.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/30.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CacheNetService.h"
#import "CustomNetworkingCache.h"
#import "AFNetworking.h"

@interface CacheNetService()
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) AFHTTPSessionManager *manager;


@property (nonatomic, strong) NSArray *supportMimeType;
@property (nonatomic, assign) NSInteger limitSize;// M
@end

@implementation CacheNetService

+ (instancetype)sharedService {
    static CacheNetService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
   
    return _sharedService;
}

- (NSURLSessionConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _configuration.HTTPShouldSetCookies = YES;
        _configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        _configuration.URLCache = [NSURLCache sharedURLCache];
        _configuration.allowsCellularAccess = YES;
        _configuration.timeoutIntervalForRequest = 1.0;
    }
    return _configuration;
}
// 懒加载
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_configuration];
    }
    
    return _manager;
}

/**
 * 通过HEAD从response获取文件基本信息: 如文件大小，文件类型，文件名称,判断是否下载
 */
- (void)headDownloadTaskWithString:(NSString *)urlString {
    if (!self.dataTask) {
        self.dataTask = [self.manager HEAD:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task) {
            NSURLResponse *response = self.dataTask.response;
            NSLog(@"%@ %llu %@", response.MIMEType, response.expectedContentLength, response.suggestedFilename);
            if (![self.supportMimeType containsObject: response.MIMEType]) {
                NSLog(@"不支持下载该文件类型");
                return ;
            }
            if (response.expectedContentLength / (1024.0 * 1024.0) > self.limitSize) {
                NSLog(@"文件超过限制大小");
                return;
            }
//            [self downloadTaskWithString:urlString];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"下载失败show error:%@", error.description);
        }];
    } else {
//        [self downloadTaskWithString:urlString];
    }
}

- (void)downloadTaskWithString:(NSString *)urlString
                      progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSURL *cacheUrl = [CustomNetworkingCache downloadCacheURLForRequest:urlString];
    if (cacheUrl) {
        if (completionHandler) {
            completionHandler(nil, cacheUrl, nil);
        }
        return;
    }
    
    if (!_downloadTask) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        _downloadTask = [self.manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSString *cachesPath = [CustomNetworkingCache attachmentCachesDirectory];
            NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
            NSURL *destinationUrl = [NSURL fileURLWithPath:path];
            
            [CustomNetworkingCache setDownloadCacheURL:destinationUrl reqeust:urlString];
            return destinationUrl;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            completionHandler(response, filePath, error);
        }];
    }
    if (_downloadTask.state == NSURLSessionTaskStateSuspended) {
        [_downloadTask resume];
    } else if (_downloadTask.state == NSURLSessionTaskStateCanceling) {
        
    } else if (_downloadTask.state == NSURLSessionTaskStateRunning) {
        NSLog(@"正在下载中...");
    } else if (_downloadTask.state == NSURLSessionTaskStateCompleted) {
        NSLog(@"已下载完毕，请从本地获取");
    }
}

- (void)suspendDownloadTask {
    [self.downloadTask suspend];
}

- (void)resumeDownloadTask {
    [self.downloadTask resume];
}

- (void)removeAllCache {
    [CustomNetworkingCache removeAllDownloadCache];
}

- (void)removeCacheForURL:(NSString *)urlString {
    [CustomNetworkingCache removeDownloadCacheForURL:urlString];
}

- (void)removeDownloadCacheForURL:(NSString *)urlString {
    // 删除URL所在目录的文件
    [CustomNetworkingCache removeAllDownloadCache];
}

@end
