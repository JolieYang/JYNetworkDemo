//
//  CustomPreviewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 2017/3/27.
//  Copyright © 2017年 Jolie_Yang. All rights reserved.
//

#import "CustomPreviewController.h"

#pragma mark CustomPreviewObject
@interface CustomPreviewItemObject : NSObject<QLPreviewItem>
@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;
@end
@implementation CustomPreviewItemObject
@end

#pragma mark CustomPreviewController
@interface CustomPreviewController ()< QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@end

@implementation CustomPreviewController

- (instancetype)initWithPreviewItem:(id<QLPreviewItem>)item {
    self = [super init];
    if (self) {
        self.previewItem = item;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSURL *)filePath {
    return [self initWithFilePath:filePath title:[filePath lastPathComponent]];
}
- (instancetype)initWithFilePath:(NSURL *)filePath title:(NSString *)title {
    self = [super init];
    if (self) {
        CustomPreviewItemObject *item = [[CustomPreviewItemObject alloc] init];
        item.previewItemURL = filePath;
        item.previewItemTitle = title;
        self.previewItem = item;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    [self refreshCurrentPreviewItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewItem;
}

#pragma mark QLPreviewControllerDelegate
@end
