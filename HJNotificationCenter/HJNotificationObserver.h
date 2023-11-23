//
//  HJNotificationObserver.h
//  HJNotificationCenter
//
//  Created by xiong_jia on 2023/3/13.
//

#import <Foundation/Foundation.h>
#import "HJNotification.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HJNotificationBlock) (HJNotification *notification);

@interface HJNotificationObserver : NSObject

/// 通知的接收者
@property (nonatomic, weak) id observer;

/// 通知的关联对象
@property (nonatomic, weak) id object;

/// 观察者回调方法
@property (nonatomic, nonnull, assign) SEL selector;

/// 通知名称
@property (nonatomic, copy) HJNotificationName name;

/// 通知注册的线程
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, copy) HJNotificationBlock block;

@end

NS_ASSUME_NONNULL_END
