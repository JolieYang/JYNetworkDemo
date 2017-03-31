//
//  AFNetworkingCache.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/30.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CustomCache.h"
#import "YYCache.h"

@implementation CustomCache {
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
+ (void)setHttpCache:(id)httpData
           urlString:(NSString *)urlString {
    [_cache setObject:httpData forKey:urlString];
}

+ (void)setHttpCache:(id)httpData
           urlString:(NSString *)urlString
          parameters:(NSDictionary *)parameters {
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

#pragma mark Size
+ (NSInteger)getHttpCacheSize {
    return [_cache.diskCache totalCost];
}

#pragma mark FileManager
+ (NSString *)cachesDirectoryWithFileDir:(NSString *)fileDictory {
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDictory ? fileDictory : @"Default"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:cachePath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachePath;
}

+ (BOOL)removeFileAtPath:(NSString *)fileDictory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:fileDictory error:nil];
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
