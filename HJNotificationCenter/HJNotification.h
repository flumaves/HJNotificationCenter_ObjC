//
//  HJNotification.h
//  HJNotificationCenter
//
//  Created by xiong_jia on 2023/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * HJNotificationName;

@interface HJNotification : NSObject

/// 名称，标识通知的标记
@property (nonatomic, readonly, copy) HJNotificationName name;

/// 要通知的对象，可以为 nil
@property (nonatomic, nullable, readonly, retain) id object;

/// 发送通知时附带的信息，可以为 nil
@property (nonatomic, nullable, readonly, copy) NSDictionary *userInfo;


+ (instancetype)notificationWithName:(HJNotificationName)name
                              object:(nullable id)object;

+ (instancetype)notificationWithName:(HJNotificationName)name
                              object:(nullable id)object
                            userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
