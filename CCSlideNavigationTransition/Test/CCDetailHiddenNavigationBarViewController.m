//
//  CCDetailHiddenNavigationBarViewController.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CCDetailHiddenNavigationBarViewController.h"
#import "CCDetailViewController.h"

@interface CCDetailHiddenNavigationBarViewController ()

@end

@implementation CCDetailHiddenNavigationBarViewController

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
    // Do any additional setup after loading the view.
	self.view.backgroundColor = [CCAppDelegate randomColor];
	self.title = @"Detail";

	UIButton *button = [CCAppDelegate createCustomButton:@"Go Detail"];
	button.center = CGPointMake(self.view.frame.size.width / 2,self.view.frame.size.height / 2);
	[button addTarget:self action:@selector(handleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}

- (void)handleButtonClicked:(UIButton *)button
{
	[self.navigationController pushViewController:[[CCDetailViewController alloc]init] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
