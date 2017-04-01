//
//  CacheNetService.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/30.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheNetService : NSObject
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

+ (instancetype)sharedService;
- (void)downloadTaskWithString:(NSString *)urlString
                      progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
- (void)suspendDownloadTask;
- (void)resumeDownloadTask;

- (void)removeCacheForURL:(NSString *)urlString;
- (void)removeAllCache;
@end
