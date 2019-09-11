//
//  QueryResultViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/5/31.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "WhiteStatusBarViewController.h"

@interface QueryResultViewController : WhiteStatusBarViewController
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *catId;
@end
