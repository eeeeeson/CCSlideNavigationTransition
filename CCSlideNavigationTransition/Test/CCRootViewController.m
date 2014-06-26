//
//  CCRootViewController.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CCRootViewController.h"

#import "CCDetailViewController.h"
#import "CCDetailHiddenNavigationBarViewController.h"

@interface CCRootViewController ()

@end

@implementation CCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Root";

	self.view.backgroundColor = [CCAppDelegate randomColor];
	UIButton *button = [CCAppDelegate createCustomButton:@"Go Detail"];
	button.center = CGPointMake(self.view.frame.size.width / 2,self.view.frame.size.height / 2);
	[button addTarget:self action:@selector(handleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
}

- (void)handleButtonClicked:(UIButton *)button
{
	[self.navigationController pushViewController:[[CCDetailHiddenNavigationBarViewController alloc]init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
