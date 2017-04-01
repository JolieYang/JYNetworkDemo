//
//  CustomPreviewController.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/27.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface CustomPreviewController : QLPreviewController
@property (nonatomic, strong) id <QLPreviewItem> previewItem;

- (instancetype)initWithPreviewItem:(id <QLPreviewItem>)item;
- (instancetype)initWithFilePath:(NSURL *)filePath;
- (instancetype)initWithFilePath:(NSURL *)filePath title:(NSString *)titile;
@end
