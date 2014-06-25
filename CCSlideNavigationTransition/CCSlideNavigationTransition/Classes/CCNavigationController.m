//
//  CCNavigationController.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CCNavigationController.h"

#import "UIView+CCAddition.h"
#import "NSObject+CCAssociative.h"
#import "CCSlideAnimatedTransitioning.h"

static const NSTimeInterval kCCNavigationControllerSlidingAnimationDuration = 0.35;
static const CGFloat kCCNavigationControllerPanVelocityPositiveThreshold = 300;
static const CGFloat kCCNavigationControllerPanVelocityNegativeThreshold = - 300;
static const CGFloat kCCNavigationControllerPanProgressThreshold = 0.3;

@interface CCNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSURL *snapshotCacheURL;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *previousSnapshotView;
@property (nonatomic, assign) CGPoint gestureBeganPoint;
@property (nonatomic, assign) float transitioningProgress;

@end

@implementation CCNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[[self class]setCacheSnapshotImageInMemory:NO];

		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _snapshotCacheURL = [NSURL fileURLWithPathComponents:@[[paths objectAtIndex:0], @"SnapshotCache"]];
		[self createCacheDirectory];

		_previousSlideViewInitailOriginX = - 200;
		_slidingPopEnable = YES;
		_useSystemAnimatedTransitioning = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    self.view.layer.shadowOffset = CGSizeMake(6, 6);
    self.view.layer.shadowRadius = 5;
    self.view.layer.shadowOpacity = 0.9;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
	
	if (self.isSlidingPopEnable) {
		if ([self isAboveIOS7]) {
			self.interactivePopGestureRecognizer.enabled = NO;
		}
		[self addPanGestureRecognizers];
	}
	
	if (self.isUseSystemAnimatedTransitioning) {
		self.delegate = self;
	}
}

- (void)addPanGestureRecognizers
{
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self
																		 action:@selector(handlePanGestureRecognizer:)];
    [self.view addGestureRecognizer:pan];
	
	UIScreenEdgePanGestureRecognizer * edgePan = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self
																								  action:@selector(handlePanGestureRecognizer:)];
	[self.view addGestureRecognizer:edgePan];
}

- (BOOL)isAboveIOS7
{
	return [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromViewController
                                                 toViewController:(UIViewController*)toViewController
{
	if (UINavigationControllerOperationPush == operation) {
		CCSlideAnimatedTransitioning *transitoning = [[CCSlideAnimatedTransitioning alloc]initWithReverse:NO];
		transitoning.transitioningInitailOriginX = self.previousSlideViewInitailOriginX;
		return transitoning;
	}
	return nil;
}

#pragma mark - Public

static BOOL _cacheSnapshotImageInMemory = YES;

+ (BOOL)cacheSnapshotImageInMemory
{
	return _cacheSnapshotImageInMemory;
}

+ (void)setCacheSnapshotImageInMemory:(BOOL)cacheSnapshotImageInMemory
{
	_cacheSnapshotImageInMemory = cacheSnapshotImageInMemory;
}

#pragma mark - Private

- (NSString *)encodedFilePathForKey:(NSString *)key
{
    if (![key length]){
		return nil;
	}
	
    return [[_snapshotCacheURL URLByAppendingPathComponent:[NSString stringWithUTF8String:[key UTF8String]]] path];
}

- (BOOL)createCacheDirectory
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_snapshotCacheURL path]]) {
		return NO;
	}
	
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_snapshotCacheURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    return success;
}

- (void)setTransitioningProgress:(float)transitioningProgress
{
	_transitioningProgress = MIN(1,MAX(0, transitioningProgress));
//	NSLog(@"transitioningProgress %f",transitioningProgress);
}

#pragma mark - Overwrite

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[self saveSnapshotImage:[self.view snapshotImage] forViewController:viewController];
	
	if (animated && !self.isUseSystemAnimatedTransitioning) {
	
		[self createPreviousSnapshotView];
		self.previousSnapshotView.image = [self snapshotForViewController:viewController];
		
		[super pushViewController:viewController animated:NO];

		[self layoutViewsWithSlideProgress:1];
		[UIView animateWithDuration:kCCNavigationControllerSlidingAnimationDuration animations:^{
			[self layoutViewsWithSlideProgress:0];
		}];
	} else {
		[super pushViewController:viewController animated:animated];
	}
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	[self removeSnapshotForViewController:self.topViewController];

    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	NSArray *popedController = [super popToRootViewControllerAnimated:animated];
    for (UIViewController *controller in popedController) {
        [self removeSnapshotForViewController:controller];
    }
	return popedController;
}

#pragma mark - Snapshot

- (void)saveSnapshotImage:(UIImage *)snapshotImage forViewController:(UIViewController *)controller
{
	[controller setAssociativeObject:snapshotImage forKey:[self cacheSnapshotImageKeyForViewController:controller]];

	if (![[self class] cacheSnapshotImageInMemory]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
			BOOL isArchiveSuccess = [NSKeyedArchiver archiveRootObject:snapshotImage toFile:path];
			if (isArchiveSuccess) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[controller setAssociativeObject:nil forKey:[self cacheSnapshotImageKeyForViewController:controller]];
				});
			}
		});
	}
}

- (UIImage *)snapshotForViewController:(UIViewController *)controller
{
	UIImage *image = [controller associativeObjectForKey:[self cacheSnapshotImageKeyForViewController:controller]];
	if (!image) {
		NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
		image = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	}
	return image;
}

- (void)removeSnapshotForViewController:(UIViewController *)controller
{
	[controller setAssociativeObject:nil forKey:[self cacheSnapshotImageKeyForViewController:controller]];
	NSString *path = [self encodedFilePathForKey:[self cacheSnapshotImageKeyForViewController:controller]];
	NSFileManager *fileManager = [[NSFileManager alloc]init];
	[fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheSnapshotImageKeyForViewController:(UIViewController *)controller
{
	return [NSString stringWithFormat:@"%lu_SnapshotImageKey",controller.hash];
}

#pragma mark - Event

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
	if (self.viewControllers.count < 2 || !self.isSlidingPopEnable || [pan numberOfTouches] > 1) {
		return;
	}
	
	CGPoint point = [pan locationInView:[UIApplication sharedApplication].keyWindow];
	self.transitioningProgress = (point.x - self.gestureBeganPoint.x) / [UIScreen mainScreen].bounds.size.width;

	switch (pan.state) {
		case UIGestureRecognizerStateBegan:
		{
			self.gestureBeganPoint = point;
			[self createPreviousSnapshotView];
		} break;
		case UIGestureRecognizerStateChanged:
		{
			[self layoutViewsWithSlideProgress:self.transitioningProgress];
		}break;
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
		{
			CGPoint velocity = [pan velocityInView:pan.view];
			BOOL isFastPositiveSwipe = velocity.x > kCCNavigationControllerPanVelocityPositiveThreshold;
			BOOL isFastNegativeSwipe = velocity.x < kCCNavigationControllerPanVelocityNegativeThreshold;
			NSTimeInterval duration = (isFastNegativeSwipe || isFastPositiveSwipe) ? kCCNavigationControllerSlidingAnimationDuration * 0.3
																				   : kCCNavigationControllerSlidingAnimationDuration;

			if ((self.transitioningProgress > kCCNavigationControllerPanProgressThreshold && !isFastNegativeSwipe) || isFastPositiveSwipe) {
				[UIView animateWithDuration:duration animations:^{
					[self layoutViewsWithSlideProgress:1];
				} completion:^(BOOL finished) {
					self.backgroundView.hidden = YES;
					[self popViewControllerAnimated:NO];
					[self layoutViewsWithSlideProgress:0];
				}];
			} else {
				[UIView animateWithDuration:duration animations:^{
									 [self layoutViewsWithSlideProgress:0];
								 }];
			}
		}break;
		default:
			break;
	}
}

- (void)createPreviousSnapshotView
{
	if (!self.backgroundView) {
		self.backgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
		[self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
	}
	self.backgroundView.hidden = NO;

	[self.previousSnapshotView removeFromSuperview];
	self.previousSnapshotView = [[UIImageView alloc]initWithImage:[self snapshotForViewController:self.topViewController]];
	
	CGRect frame = self.backgroundView.bounds;
	frame.origin.x = self.previousSlideViewInitailOriginX;
	self.previousSnapshotView.frame = frame;
	
	[self.backgroundView addSubview:self.previousSnapshotView];
}

- (void)layoutViewsWithSlideProgress:(float)progress
{
	self.transitioningProgress = progress;
	
	CGRect frame = self.view.frame;
	frame.origin.x = CGRectGetWidth([[UIScreen mainScreen] bounds]) * self.transitioningProgress;
	self.view.frame = frame;
	
	CGRect previewFrame = self.previousSnapshotView.frame;
    CGFloat offset = frame.origin.x * self.previousSlideViewInitailOriginX / previewFrame.size.width;
	previewFrame.origin.x = self.previousSlideViewInitailOriginX - offset;
    self.previousSnapshotView.frame = previewFrame;
}

@end
