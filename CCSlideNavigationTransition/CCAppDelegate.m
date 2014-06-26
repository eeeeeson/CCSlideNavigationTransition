//
//  CCAppDelegate.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCRootViewController.h"
#import "CCNavigationController.h"

@implementation CCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	CCNavigationController *nav = [[CCNavigationController alloc]initWithRootViewController:[[CCRootViewController alloc]init]];
	self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

+ (UIButton *)createCustomButton:(NSString *)title
{
	UIButton *button = [[UIButton alloc]init];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button sizeToFit];
	button.backgroundColor = [[self class]randomColor];
	return button;
}

+ (UIColor *)randomColor
{
	return [UIColor colorWithRed:(arc4random() % 255 )/ 255.f green:(arc4random() % 255 )/ 255.f blue:(arc4random() % 255 )/ 255.f alpha:1];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
