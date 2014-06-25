//
//  NSObject+CCAssociative.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "NSObject+CCAssociative.h"

#import <objc/runtime.h>

@implementation NSObject (CCAssociative)

static char associativeObjectsKey;

- (id)associativeObjectForKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    return [dict objectForKey:key];
}

- (void)removeAssociatedObjectForKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    [dict removeObjectForKey:key];
}

- (void)setAssociativeObject:(id)object forKey:(NSString *)key
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &associativeObjectsKey);

    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &associativeObjectsKey, dict, OBJC_ASSOCIATION_RETAIN);
    }

    if (object == nil) {
        [dict removeObjectForKey:key];
    } else {
        [dict setObject:object forKey:key];
    }
}

@end
