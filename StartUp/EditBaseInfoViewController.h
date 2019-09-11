//
//  EditBaseInfoViewController.h
//  micai
//
//  Created by 苏晓凯 on 2019/4/4.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"
#import "ApplyModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EditBaseInfoViewController : MTBaseViewController
@property (nonatomic, strong) ApplyModel *model;
@property (nonatomic, copy) void (^returnApplyModel)(ApplyModel *);
@end

NS_ASSUME_NONNULL_END
