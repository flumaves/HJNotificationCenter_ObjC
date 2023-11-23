//
//  HJNotificationCenter.m
//  HJNotificationCenter
//
//  Created by xiong_jia on 2023/3/13.
//

#import "HJNotificationCenter.h"
#import "HJNotificationObserver.h"

@interface HJNotificationCenter ()

/// 储存只指定了 object ，没有指定通知名称的观察者集合
/// 键为 object，值为 object 的哈希表
@property (nonatomic, strong) NSMutableDictionary *nameLessNotifications;

/// 储存了指定了 name 和 object 的观察者集合
/// 键为 name，值为 object 的哈希表
@property (nonatomic, strong) NSMutableDictionary *normalNotifications;

/// 既没有指定 name，也没有指定 object 的观察者集合
@property (nonatomic, strong) NSMutableArray <HJNotificationObserver *>*wildNotifications;

@property (nonatomic, strong) NSLock *observerLock;

@end


@implementation HJNotificationCenter

+ (instancetype)defaultCenter {
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nameLessNotifications = [[NSMutableDictionary alloc] init];
        self.normalNotifications = [[NSMutableDictionary alloc] init];
        self.wildNotifications = [[NSMutableArray alloc] init];
        self.observerLock = [[NSLock alloc] init];
    }
    return self;
}


#pragma mark - 添加观察者
/// 添加观察者到表中
- (void)addObserver:(HJNotificationObserver *)observer {
    [self.observerLock lock];
    
    if (observer.name) {   // normalNotification
        NSMutableDictionary *dict = [self.normalNotifications valueForKey:observer.name];
        if (dict) { // 已经存在 key 为 name 的字典
            NSMutableArray *observers = [dict valueForKey:observer.object];
            if (observers) {    // 字典中已经存在 key 为 object 的数组
                [observers addObject:observer];
            } else {    // 字典中不存在 key 为 object 的数组
                observers = [[NSMutableArray alloc] init];
                [dict setValue:observers forKey:observer.object];
            }
        } else {    // 不存在 key 为 name 的字典
            dict = [[NSMutableDictionary alloc] init];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:observer];
            [dict setValue:array forKey:observer.object];
            [self.normalNotifications setValue:dict forKey:observer.name];
        }
    } else if (observer.object) {  // namelessNotification
        NSMutableArray *array = [self.nameLessNotifications valueForKey:observer.object];
        if (array) {
            [array addObject:observer];
        } else {
            array = [[NSMutableArray alloc] init];
            [array addObject:observer];
            [self.nameLessNotifications setValue:array forKey:observer.object];
        }
    } else {    // wildNotification
        [self.wildNotifications addObject:observer];
    }
    
    [self.observerLock unlock];
}

- (void)addObserver:(id)observer
           selector:(SEL)selector
               name:(HJNotificationName)name
             object:(id)object {
    HJNotificationObserver *observerModel = [[HJNotificationObserver alloc] init];
    observerModel.observer = observer;
    observerModel.selector = selector;
    observerModel.name = name;
    observerModel.object = object;
    
    [self addObserver:observerModel];
}

- (id<NSObject>)addObserverForName:(HJNotificationName)name
                            object:(id)object
                             queue:(NSOperationQueue *)queue
                        usingBlock:(void (^)(HJNotification * _Nonnull))block {
    HJNotificationObserver *observerModel = [[HJNotificationObserver alloc] init];
    observerModel.object = object;
    observerModel.name = name;
    observerModel.queue = queue;
    observerModel.block = block;
    
    [self addObserver:observerModel];
    return nil;
}


#pragma mark - 发送通知
- (void)postNotificationName:(HJNotificationName)name object:(id)object {
    [self postNotificationName:name object:object userInfo:nil];
}

- (void)postNotificationName:(HJNotificationName)name object:(id)object userInfo:(NSDictionary *)userInfo {
    HJNotification *notification = [HJNotification notificationWithName:name object:object userInfo:userInfo];
    [self postNotification:notification];
}

- (void)postNotification:(HJNotification *)notification {
    // 维护一个队列发送通知
    NSMutableArray *sendTo = [[NSMutableArray alloc] init];
    if (notification.name) {
        NSMutableDictionary *dict = [self.normalNotifications valueForKey:notification.name];
        if (dict) {
            if (notification.object) {
                NSMutableArray *observers = [dict valueForKey:notification.object];
                [sendTo addObjectsFromArray:observers];
            } else {
                for (NSMutableArray *observers in dict) {
                    [sendTo addObjectsFromArray:observers];
                }
            }
        }
    }
    
    if (notification.object) {
        NSMutableArray *observers = [self.nameLessNotifications valueForKey:notification.object];
        [sendTo addObject:observers];
    }
    
    [sendTo addObjectsFromArray:self.wildNotifications];
    
    for (HJNotificationObserver *observer in sendTo) {
        [observer performSelector:observer.selector withObject:notification.userInfo];
    }
}

#pragma mark - 删除通知
- (void)removeObserver:(id)observer {
    [self.observerLock lock];
    
    for (NSMutableDictionary *dict in self.normalNotifications) {
        for (NSMutableArray *observers in dict) {
            for (HJNotificationObserver *observerModel in observers) {
                if (observerModel.observer == observer) {
                    [observers removeObject:observerModel];
                }
            }
        }
    }
    
    for (NSMutableArray *observers in self.nameLessNotifications) {
        for (HJNotificationObserver *observerModel in observers) {
            if (observerModel.observer == observer) {
                [observers removeObject:observerModel];
            }
        }
    }
    
    for (HJNotificationObserver *observerModel in self.wildNotifications) {
        if (observerModel.observer == observer) {
            [self.wildNotifications removeObject:observerModel];
        }
    }
    
    [self.observerLock unlock];
}

- (void)removeObserver:(id)observer name:(HJNotificationName)name object:(id)object {
    [self.observerLock lock];
    
    if (name) { // 指定了 name
        NSMutableDictionary *dict = [self.normalNotifications valueForKey:name];
        if (!dict) { return; }   // 不存在 key 为 name 的字典
        if (object) {   //指定了 object
            NSMutableArray *observers = [dict valueForKey:object];
            for (HJNotificationObserver *observerModel in observers) {
                if (observerModel.observer == observer) {
                    [observers removeObject:observerModel];
                }
            }
        }
        [self.normalNotifications removeObjectForKey:name];
    } else if (object) {    // 指定了 object
        NSMutableArray *observers = [self.nameLessNotifications valueForKey:object];
        if (!observers) { return; }  // 不存在 key 为 object 的数组
        for (HJNotificationObserver *observerModel in observers) {
            if (observerModel.observer == observer) {
                [observers removeObject:observerModel];
            }
        }
    } else {    // 既没有指定 name 也没有指定 object 的通知
        for (HJNotificationObserver *observerModel in self.wildNotifications) {
            if (observerModel.observer == observer) {
                [self.wildNotifications removeObject:observerModel];
            }
        }
    }
    
    [self.observerLock unlock];
}
@end
