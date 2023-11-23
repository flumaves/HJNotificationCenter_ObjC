//
//  HJNotification.m
//  HJNotificationCenter
//
//  Created by xiong_jia on 2023/3/13.
//

#import "HJNotification.h"

@implementation HJNotification

+ (instancetype)notificationWithName:(HJNotificationName)name object:(id)object {
    return [self notificationWithName:name object:object userInfo:nil];
}

+ (instancetype)notificationWithName:(HJNotificationName)name object:(id)object userInfo:(NSDictionary *)userInfo {
    HJNotification *notifcation = [[HJNotification alloc] initWithName:name object:object userInfo:userInfo];
    
    return notifcation;
}

- (instancetype)initWithName:(HJNotificationName)name
                      object:(nullable id)object
                    userInfo:(nullable NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        _name = name;
        _object = object;
        _userInfo = userInfo;
    }
    
    return self;
}

@end
