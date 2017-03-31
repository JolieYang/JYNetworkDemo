//
//  AFNetworkingCache.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/30.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomCache : NSObject
+ (void)setHttpCache:(id)httpData urlString:(NSString *)urlString;
+ (void)setHttpCache:(id)httpData urlString:(NSString *)urlString parameters:(NSDictionary *)parameters;

+ (id)httpCacheForUrlString:(NSString *)urlString;
+ (id)httpCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters;

+ (void)removeHttpCacheForUrlString:(NSString *)urlString;
+ (void)removeAllHttpCache;

+ (NSString *)cachesDirectoryWithFileDir:(NSString *)fileDictory;
+ (BOOL)removeFileAtPath:(NSString *)fileDictory;

#pragma mark -- Tool
+ (NSString *)cacheKeyWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters;
@end
