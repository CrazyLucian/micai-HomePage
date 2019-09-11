//
//  PositionDetailViewController.h
//  micai
//
//  Created by 苏晓凯 on 2019/4/2.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PositionDetailViewController : MTBaseViewController
@property (nonatomic, strong) NSNumber *jobId;
@property (nonatomic, strong) NSNumber *isFull; //1全职  2兼职
@property (nonatomic, assign) NSInteger type;//0 normal 1我的发布进入，隐藏按钮
@end

NS_ASSUME_NONNULL_END
