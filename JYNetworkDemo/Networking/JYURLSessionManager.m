//
//  JYURLSessionManager.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/12.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "JYURLSessionManager.h"

@implementation JYURLSessionManager

@end

@implementation JYHTTPResposneSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return self;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    self.acceptableStatusCode = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = nil;
    
    return self;
}

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error {
    
    
    return YES;
}

@end
