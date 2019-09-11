//
//  InvoiceUpdateViewController.h
//  micai
//
//  Created by 苏晓凯 on 2018/5/30.
//  Copyright © 2018年 mingteng. All rights reserved.
//

#import "WhiteStatusBarViewController.h"
#import "InvoiceModel.h"
@interface InvoiceUpdateViewController : WhiteStatusBarViewController
@property (nonatomic, retain) InvoiceModel *invoiceModel;
@property (nonatomic, copy) void(^returnReloadBlock)(void);
@end
