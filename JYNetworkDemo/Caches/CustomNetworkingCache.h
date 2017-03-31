//
//  CustomNetworkingCache.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/31.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CustomCache.h"

@interface CustomNetworkingCache : CustomCache

#pragma mark -- attachment
+ (void)setDownloadCacheURL:(NSURL *)cacheUrl reqeust:(NSString *)urlString;
+ (NSURL *)downloadCacheURLForRequest:(NSString *)urlString;
+ (void)removeDownloadCacheForURL:(NSString *)urlString;
+ (void)removeDownloadCacheForRequest:(NSString *)urlString parameters:(NSDictionary *)parameters;
+ (void)removeAllDownloadCache;

// 缓存路径
+ (NSString *)attachmentCachesDirectory;
@end
