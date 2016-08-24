//
//  AppDelegate.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/5.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackgroundSessionCompletionHandler)();
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) BackgroundSessionCompletionHandler backgroundSessionCompletionHandler;

@end

