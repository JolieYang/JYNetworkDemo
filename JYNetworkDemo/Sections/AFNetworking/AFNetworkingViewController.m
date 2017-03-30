//
//  AFNetworkingViewController.m
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/10.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import "AFNetworkingViewController.h"
#import "AFNetworking.h"
#define TEST_URL @"https://github.com"

@interface AFNetworkingViewController () {
    NSString *_userName;
    NSString *_password;
    
    NSMutableData *_data; // 响应数据
    long long totalLength;
    long long loadedLength;
    
    __weak IBOutlet UITextField *textField;
    __weak IBOutlet UIProgressView *progressView;
    __weak IBOutlet UILabel *label;
    __weak IBOutlet UIButton *button;
}

@end

@implementation AFNetworkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)downloadAction:(id)sender {
    
}

- (void)sendRequest {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[[NSURL alloc] initWithString: TEST_URL]];
    [manager GET:@"relative_url" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error.localizedDescription);
    }];
    
}

- (void)configuration:(AFHTTPSessionManager *)manager {
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
}

/**
 * 通过Reqest判断是否存在对应request的缓存
 */
- (BOOL)isExistCacheWithRequest:(NSURLRequest *)requeest {
    BOOL isExistCache = NO;
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache setMemoryCapacity:10 * 1024 * 1024]; // 设置内存中缓存的大小
    
    NSCachedURLResponse *response = [cache cachedResponseForRequest:requeest];
    if (response) {
        isExistCache = YES;
    }
    return isExistCache;
}

@end
