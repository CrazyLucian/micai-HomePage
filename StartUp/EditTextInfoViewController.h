//
//  EditTextInfoViewController.h
//  micai
//
//  Created by 苏晓凯 on 2019/4/4.
//  Copyright © 2019 mingteng. All rights reserved.
//

#import "MTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditTextInfoViewController : MTBaseViewController
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) void (^returnTextBlock)(NSString *);
@end

NS_ASSUME_NONNULL_END
