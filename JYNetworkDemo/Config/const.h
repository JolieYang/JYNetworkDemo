//
//  const.h
//  JYNetworkDemo
//
//  Created by Jolie_Yang on 16/8/10.
//  Copyright © 2016年 Jolie_Yang. All rights reserved.
//

//#ifndef const_h
#define const_h

#if DEBUG
    #define SERVER_URL @""
#else
    #define SERVER_URL @""

#define GRAY_GIRL = @"https://raw.githubusercontent.com/JolieYang/Picture/master/gray_girl.png";

#endif /* const_h */

#ifndef __IPHONE_7_0

#endif

#define YLog(formatString, ...) NSLog((@"%s" formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);
