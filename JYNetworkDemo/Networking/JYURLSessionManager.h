//
//  JYURLSessionManager.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/12.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYURLSessionManager : NSObject

@end

@interface JYHTTPResposneSerializer : NSObject
- (instancetype)init;
+ (instancetype)serializer;

@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, copy) NSIndexSet *acceptableStatusCode;
@property (nonatomic, copy) NSSet<NSString *> *acceptableContentTypes;

- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;
@end
