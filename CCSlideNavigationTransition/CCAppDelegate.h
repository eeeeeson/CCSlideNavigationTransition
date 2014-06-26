//
//  CCAppDelegate.h
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (UIButton *)createCustomButton:(NSString *)title;
+ (UIColor *)randomColor;

@end
