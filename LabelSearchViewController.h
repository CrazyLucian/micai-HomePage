//
//  LabelSearchViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/8/8.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"

@interface LabelSearchViewController : MTBaseViewController
@property (nonatomic, assign) NSInteger titleIndex;
@property (nonatomic, copy) void(^returnSearchBlock)(NSString *);
@end
