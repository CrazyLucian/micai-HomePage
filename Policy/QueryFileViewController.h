//
//  QueryFileViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "WhiteStatusBarViewController.h"

@interface QueryFileViewController : WhiteStatusBarViewController
@property (nonatomic, copy) void(^returnBlock)(NSString *);
@end
