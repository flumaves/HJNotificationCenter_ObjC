//
//  HJNotificationCenter.h
//  HJNotificationCenter
//
//  Created by xiong_jia on 2023/3/13.
//

#import <Foundation/Foundation.h>
#import "HJNotification.h"

NS_ASSUME_NONNULL_BEGIN

/// 通知中心，单例模式
@interface HJNotificationCenter : NSObject

/// 单例
@property (nonatomic, strong, readonly) HJNotificationCenter *defaultCenter;

#pragma mark - 添加观察者
/// 添加通知的时候如果指定了 object，接收通知时只会接收也指定了相同 object 的通知
/// 发送通知时，指定 object 并不会影响没有指定 object 的观察者接收通知

/// 添加观察者
/// - Parameters:
///   - observer: 观察者
///   - selector: 回调方法
///   - name: 通知名称
///   - object: 发送通知的对象
/// 当 object 对象发送名称为 name 的通知，则调用 observer 中的对应 selector
- (void)addObserver:(id)observer
           selector:(nonnull SEL)selector
               name:(nullable HJNotificationName)name
             object:(nullable id)object;

/// 添加观察者
/// - Parameters:
///   - name: 通知名称
///   - obj: 关联对象
///   - queue: 通知所属队列
///   - block: 回调
- (id <NSObject>)addObserverForName:(nullable HJNotificationName)name
                             object:(nullable id)object
                         queue:(nullable NSOperationQueue *)queue
                    usingBlock:(nonnull void (^)(HJNotification * _Nonnull))block;


#pragma mark - 发送通知

/// 发送通知
/// - Parameter notification: 通知
- (void)postNotification:(HJNotification *)notification;

/// 发送通知
/// - Parameters:
///   - name: 通知名称
///   - object: 通知的对象
- (void)postNotificationName:(HJNotificationName)name
                      object:(nullable id)object;

/// 发送通知
/// - Parameters:
///   - name: 通知名称
///   - object: 通知的对象
///   - userInfo: 附带的信息
- (void)postNotificationName:(HJNotificationName)name
                      object:(nullable id)object
                    userInfo:(nullable NSDictionary *)userInfo;

#pragma mark - 删除观察者
/// 删除观察者为 observer 的通知
- (void)removeObserver:(id)observer;

/// 删除观察者为 observer，通知名字为 name，关联对象为 object 的通知
- (void)removeObserver:(id)observer
                  name:(nullable HJNotificationName)name
                object:(nullable id)object;

@end

NS_ASSUME_NONNULL_END
