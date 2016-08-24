//
//  JYNetworking.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/10.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYRequest.h"
#import "JYResponse.h"

@interface JYNetworking : NSObject

//@property (nonatomic, copy) void (^blockName)(NSString *msg);
//@property (nonatomic, copy) NSString* (^blockName)(NSString *msg);
//typedef void (^blockName)(NSString *msg);
//typedef NSString* (^blockName)(NSString *msg);

typedef void (^HttpResponseBlock)(JYResponse *responseObject, NSError *error);
#pragma mark 集约型
//+ (id)request:(JYRequest *)baseRequest callback:(HttpResponseBlock)block;

#pragma mark 离散型
//- (NSURLSessionTask *)getUserInfo:(NSString *)userId success:(void (^)(NSURLSessionDataTask *dataTask, id *responseObject))success failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;
//- (NSURLSessionTask *)getMsgList:(NSString *)userId success:(void (^)(NSURLSessionDataTask *dataTask, id *responseObject))success failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;
@end
