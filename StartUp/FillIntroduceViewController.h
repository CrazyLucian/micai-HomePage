//
//  FillIntroduceViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/7/25.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"

@interface FillIntroduceViewController : MTBaseViewController
@property (nonatomic, assign) NSInteger type;//0介绍  1优势
@property (nonatomic, copy) NSString *defaultStr;
@property (nonatomic, copy) void(^returnStrBlock)(NSString *);
@end
