//
//  CCSlideAnimatedTransitioning.m
//  CCSlideNavigationTransition
//
//  Created by eson on 14-6-25.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CCSlideAnimatedTransitioning.h"

@implementation CCSlideAnimatedTransitioning

static const NSTimeInterval kSlideAnimatedTransitioningDuration = .35;

#pragma mark - Initialization

- (instancetype)initWithReverse:(BOOL)reverse
{
    self = [super init];
    if ( self ) {
        self.reverse = reverse;
		self.transitioningInitailOriginX = - [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

+ (instancetype)transitioningWithReverse:(BOOL)reverse
{
    return [[self alloc] initWithReverse:reverse];
}

#pragma mark - Transitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSString * fromKey = UITransitionContextFromViewControllerKey;
    NSString * toKey = UITransitionContextToViewControllerKey;
    UIViewController * fromViewController = [transitionContext viewControllerForKey:fromKey];
    UIViewController * toViewController = [transitionContext viewControllerForKey:toKey];
	
    UIView * containerView = [transitionContext containerView];
    UIView * fromView = fromViewController.view;
    UIView * toView = toViewController.view;
	
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGFloat viewWidth = CGRectGetWidth(containerView.frame);
    __block CGRect fromViewFrame = fromView.frame;
    __block CGRect toViewFrame = toView.frame;
	
    toViewFrame.origin.x = self.reverse ? self.transitioningInitailOriginX : viewWidth;
    toView.frame = toViewFrame;
	[containerView addSubview:toView];
	if (self.isReverse) {
		[containerView bringSubviewToFront:fromView];
	}
	
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toViewFrame.origin.x = CGRectGetMinX(containerView.frame);
                         fromViewFrame.origin.x = self.isReverse ? viewWidth : self.transitioningInitailOriginX;
                         toView.frame = toViewFrame;
                         fromView.frame = fromViewFrame;
                     }
                     completion:^(BOOL finished) {
                         if (self.isReverse && ![transitionContext transitionWasCancelled]) {
							 [fromView removeFromSuperview];
						 }
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kSlideAnimatedTransitioningDuration;
}
@end
