//
//  RecruitDetailViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/6/15.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"

@interface RecruitDetailViewController : MTBaseViewController
@property (nonatomic, strong) NSNumber *jobId;
@property (nonatomic, strong) NSNumber *isFull; //1全职  2兼职
@property (nonatomic, assign) NSInteger type;//0 normal 1我的发布进入，隐藏按钮
@end
