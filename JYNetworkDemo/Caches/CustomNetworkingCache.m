//
//  CustomNetworkingCache.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/31.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CustomNetworkingCache.h"

@implementation CustomNetworkingCache
static NSUserDefaults *_downloadCacheUserDefaults;
static NSString *const UserDefaultsDownloadCache = @"com.jy.userdefaults.download.cache";
static NSString *const AttachmentCachesDirectory = @"attachment";

+ (void)initialize {
    _downloadCacheUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:UserDefaultsDownloadCache];
}

#pragma mark -- Download
+ (void)setDownloadCacheURL:(NSURL *)cacheUrl
                    reqeust:(NSString *)urlString
{
    [self setDownloadCacheURL:cacheUrl request:urlString parameters:nil];
}

+ (void)setDownloadCacheURL:(NSURL *)cacheUrl
                    request:(NSString *)urlString
                 parameters:(NSDictionary *)parameters
{
    NSString *cacheKey = [super cacheKeyWithUrlString:urlString parameters:parameters];
    [_downloadCacheUserDefaults setURL:cacheUrl forKey:cacheKey];
    [_downloadCacheUserDefaults synchronize];
}

+ (NSURL *)downloadCacheURLForRequest:(NSString *)urlString
{
    return [self downloadCacheURLForRequest:urlString paramters:nil];
}

+ (NSURL *)downloadCacheURLForRequest:(NSString *)urlString
                            paramters:(NSDictionary *)parameters
{
    NSString *cacheKey = [super cacheKeyWithUrlString:urlString parameters:parameters];
    return [_downloadCacheUserDefaults URLForKey:cacheKey];
}

+ (void)removeDownloadCacheForURL:(NSString *)urlString
{
    [self removeDownloadCacheForRequest:urlString parameters:nil];
}

+ (void)removeDownloadCacheForRequest:(NSString *)urlString
                           parameters:(NSDictionary *)parameters
{
    // 移除缓存文件
    NSURL *cacheUrl = [self downloadCacheURLForRequest:urlString paramters:parameters];
    [[NSFileManager defaultManager] removeItemAtURL:cacheUrl error:nil];
    // 移除缓存路径
    NSString *cacheKey = [super cacheKeyWithUrlString:urlString parameters:parameters];
    [_downloadCacheUserDefaults removeObjectForKey:cacheKey];
}

+ (void)removeAllDownloadCache {
    // 移除缓存文件
    NSString *path = [self attachmentCachesDirectory];
    [super removeFileAtPath:path];
    [_downloadCacheUserDefaults removeSuiteNamed:UserDefaultsDownloadCache];
}

#pragma mark FileManager
+ (NSString *)attachmentCachesDirectory {
    return [self cachesDirectoryWithFileDir:AttachmentCachesDirectory];
}
@end
