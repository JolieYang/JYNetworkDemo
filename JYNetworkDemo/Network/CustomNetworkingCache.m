//
//  AFNetworkingCache.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/30.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CustomNetworkingCache.h"
#import "YYCache.h"

@implementation CustomNetworkingCache {
}
static YYCache *_cache;
static YYCache *_downloadCache;
static NSString *const NetworkingCache = @"com.jy.networking.cache";
static NSString *const NetworkingDownloadCache = @"com.jy.networking.download.cache";

+ (void)initialize {
    _cache = [YYCache cacheWithName:NetworkingCache];
    _downloadCache = [YYCache cacheWithName:NetworkingDownloadCache];
}

#pragma mark -- GET/POST
+ (void)setHttpCache:(id)httpData urlString:(NSString *)urlString {
    [_cache setObject:httpData forKey:urlString];
}
+ (void)setHttpCache:(id)httpData urlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    // 异步缓存
    [_cache setObject:httpData forKey:cacheKey];
}
+ (id)httpCacheForUrlString:(NSString *)urlString {
    return [self httpCacheForCacheKey:urlString];
}

+ (id)httpCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    return [self httpCacheForCacheKey:cacheKey];
}

+ (id)httpCacheForCacheKey:(NSString *)cacheKey {
    return [_cache objectForKey:cacheKey];
}

+ (void)removeHttpCacheForUrlString:(NSString *)urlString {
    [_cache removeObjectForKey:urlString];
}

+ (void)removeHttpCacheForCacheKey:(NSString *)cacheKey {
    [_cache removeObjectForKey:cacheKey];
}

+ (void)removeAllHttpCache {
    [_cache removeAllObjects];
}

#pragma mark -- Download
+ (void)setDownloadCacheURL:(NSURL *)cacheUrl request:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    [_cache setObject:cacheUrl forKey:cacheKey];
}

+ (void)setDownloadCacheURL:(NSURL *)cacheUrl reqeust:(NSString *)urlString {
    [_cache setObject:cacheUrl forKey:urlString];
}

+ (NSURL *)dwonloadCacheURLForRequest:(NSString *)urlString {
    return (NSURL *)[_cache objectForKey:urlString];
}

+ (NSURL *)downloadCacheURLForRequest:(NSString *)urlString paramters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    return (NSURL *)[_cache objectForKey:cacheKey];
}

+ (void)removeDownloadCacheForURL:(NSString *)urlString {
    [_cache.diskCache removeObjectForKey:urlString];
}

+ (void)removeDownloadCacheForRequest:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    [_cache.diskCache removeObjectForKey:cacheKey];
}

+ (void)removeAllDownloadCache {
    [_cache.diskCache removeAllObjects];
}

#pragma mark Size
+ (NSInteger)getHttpCacheSize {
    return [_cache.diskCache totalCost];
}

#pragma mark Tool
+ (NSString *)cacheKeyWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    if (!parameters) {
        return urlString;
    }
    // dict --> string
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *parametersString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *cacheKey = [urlString stringByAppendingString:parametersString];
    
    return cacheKey;
}
@end
