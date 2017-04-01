//
//  AttachmentEntity.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/4/1.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentEntity : NSObject
@property (nonatomic, strong) NSString *attachmentName;// 包括后缀名
@property (nonatomic, assign) float fileSize;
@end
