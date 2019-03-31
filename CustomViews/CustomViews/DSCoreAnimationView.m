//
//  DSCoreAnimationView.m
//  CustomViews
//
//  Created by Dmitry Sharygin on 24/02/2019.
//  Copyright © 2019 Dmitry Sharygin. All rights reserved.
//

#import "DSCoreAnimationView.h"

#define INSET_SIZE 8
#define FINAL_INSET_SIZE 2

#define CORNER_RADIUS_KEY @"cornerRadius"
#define BOUNDS_KEY @"bounds"
#define POSITION_KEY @"position"

@interface DSCoreAnimationView ()
@property (strong, nonatomic) UIView *roundView;
@property (strong, nonatomic) UIView *firstCrossView;
@property (strong, nonatomic) UIView *secondCrossView;
@property (assign, nonatomic ) BOOL isCollapsed;
@property (strong, nonatomic) UITextField *label;
@property (assign, nonatomic) BOOL isAnimating;
@end

@implementation DSCoreAnimationView

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.isCollapsed = YES;
        self.isAnimating = NO;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        //[self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self createUI];
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(BOOL)becomeFirstResponder{
    //[self performAnimations];
    
    return YES;
}
-(BOOL)resignFirstResponder{
    if (!self.isCollapsed) {
        [self performAnimations];
    }
    return YES;
}
-(BOOL)canResignFirstResponder{
    return YES;
}

-(CGFloat)height{
    return CGRectGetHeight(self.bounds);
}
- (void)createUI{
    self.backgroundColor = [UIColor clearColor];
    self.roundView = [UIView new];
    self.roundView.layer.borderColor = [UIColor orangeColor].CGColor;
    self.roundView.layer.borderWidth = 2;
    [self addSubview: self.roundView];
    CGFloat x = CGRectGetWidth(self.bounds) - [self height];
    CGFloat y = CGRectGetHeight(self.bounds) - [self height];
    CGRect roundViewFrame = CGRectMake(x+INSET_SIZE, y+INSET_SIZE, [self height]-2*INSET_SIZE, [self height]-2*INSET_SIZE);
    [self.roundView setFrame:roundViewFrame];
    self.roundView.layer.cornerRadius = ([self height] - 2 * INSET_SIZE)/2;
    self.label = [UITextField new];
    self.label.clearButtonMode = UITextFieldViewModeAlways;
    self.label.keyboardAppearance = UIKeyboardAppearanceDark;
    [self addSubview:self.label];
    [self.label setLayoutMargins:UIEdgeInsetsMake(4, 4, 4, 4)];
    CGRect labelFrame = CGRectMake(4*FINAL_INSET_SIZE, 4*FINAL_INSET_SIZE, CGRectGetWidth(self.bounds)-8*FINAL_INSET_SIZE, [self height]-8*FINAL_INSET_SIZE);
    [self.label setFrame:labelFrame];
    self.label.alpha = 0;
    self.firstCrossView = [UIView new];
    [self addSubview:self.firstCrossView];
    CGRect firstCrossFrame = CGRectMake(CGRectGetWidth(self.bounds)-1.4*INSET_SIZE, [self height]-1.4*INSET_SIZE, 1.4*INSET_SIZE, 2);
    self.firstCrossView.frame = firstCrossFrame;
    self.firstCrossView.transform = CGAffineTransformMakeRotation(M_PI/4);
    self.firstCrossView.layer.borderWidth = 2;
    self.firstCrossView.layer.borderColor = [UIColor orangeColor].CGColor;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [button setFrame:roundViewFrame];
    
}

- (void)handleTap:(UITapGestureRecognizer *)sender{
    [self performAnimations];
}
- (void)performAnimations{
    if (self.isAnimating) {
        return;
    }
    if (!self.isCollapsed) {
        [self.label resignFirstResponder];
        self.label.alpha=0;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.label becomeFirstResponder];
        });
    }
    self.isAnimating = YES;
    CAKeyframeAnimation *radiusAnimation = [self performRadiusIncreaseAnimation];
    CAKeyframeAnimation *widthAnimation = [self performWidthAnimation];
    CAKeyframeAnimation *sizeIncreaseAnimation = [self performSizeIncreaseAnimation];
    CAKeyframeAnimation *sizeWidthAnimation = [self performSizeWidthAnimation];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:0.8];
    [group setAnimations:[NSArray arrayWithObjects:radiusAnimation, widthAnimation, sizeIncreaseAnimation, sizeWidthAnimation, nil]];
    [self.roundView.layer addAnimation:group forKey:nil];
    [self.firstCrossView.layer addAnimation:[self crossAnimation] forKey:BOUNDS_KEY];
    CGFloat newWidth = CGRectGetWidth(self.bounds) - 2*FINAL_INSET_SIZE;
    CGFloat newHeight = CGRectGetHeight(self.bounds) - 2*FINAL_INSET_SIZE;
    
    CGFloat x = CGRectGetWidth(self.bounds) - [self height];
    CGFloat y = CGRectGetHeight(self.bounds) - [self height];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.roundView.frame = self.isCollapsed ? CGRectMake(FINAL_INSET_SIZE, FINAL_INSET_SIZE, newWidth, newHeight) : CGRectMake(x+INSET_SIZE, y+INSET_SIZE, [self height]-2*INSET_SIZE, [self height]-2*INSET_SIZE);
        if (self.isCollapsed) {
            self.firstCrossView.alpha = 0;
        }
        
        self.isCollapsed = !self.isCollapsed;
        self.isAnimating = NO;
        
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.81 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.firstCrossView.alpha = self.isCollapsed ? 1 : 0;
        self.label.alpha = self.isCollapsed ? 0 : 1;
    });
}

- (CAKeyframeAnimation *) crossAnimation{
    CGRect firstSize = CGRectMake(CGRectGetWidth(self.bounds)-1.4*INSET_SIZE, [self height]-1.4*INSET_SIZE, 1.4*INSET_SIZE, 2);
    CGRect finalSize = CGRectMake(0, 0, 0, 0);
    NSArray *sizeValues = self.isCollapsed ? @[[NSValue valueWithCGRect:firstSize], [NSValue valueWithCGRect:finalSize]] : @[[NSValue valueWithCGRect:finalSize], [NSValue valueWithCGRect:firstSize]];
    CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:BOUNDS_KEY];
    sizeAnimation.values = sizeValues;
    sizeAnimation.duration = 0.31;
    [sizeAnimation setBeginTime:self.isCollapsed ? 0 : 0.5];
    return sizeAnimation;
}

- (CAKeyframeAnimation *)performSizeIncreaseAnimation{
    CGRect firstSize = CGRectMake(0, 0, [self height]-2*INSET_SIZE, [self height]-2*INSET_SIZE);
    CGRect finalSize = CGRectMake(0, 0, [self height]-2*FINAL_INSET_SIZE, [self height]-2*FINAL_INSET_SIZE);
    NSArray *sizeValues = self.isCollapsed ? @[[NSValue valueWithCGRect:firstSize], [NSValue valueWithCGRect:finalSize]] : @[[NSValue valueWithCGRect:finalSize], [NSValue valueWithCGRect:firstSize]];
    CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:BOUNDS_KEY];
    sizeAnimation.values = sizeValues;
    sizeAnimation.duration = 0.3;
    [sizeAnimation setBeginTime:self.isCollapsed ? 0 : 0.5];
    return sizeAnimation;
}

- (CAKeyframeAnimation *)performRadiusIncreaseAnimation{
    CGFloat firstRadius = ([self height] - 2 * INSET_SIZE)/2;
    CGFloat finishRadius = ([self height] - 2 * FINAL_INSET_SIZE)/2;
    CAKeyframeAnimation *cornerRadiusAnimation = [CAKeyframeAnimation animationWithKeyPath:CORNER_RADIUS_KEY];
    NSArray *cornerRadiusValues = self.isCollapsed ?  @[[NSNumber numberWithFloat:firstRadius], [NSNumber numberWithFloat:finishRadius]] : @[[NSNumber numberWithFloat:finishRadius], [NSNumber numberWithFloat:firstRadius]];
    cornerRadiusAnimation.values = cornerRadiusValues;
    cornerRadiusAnimation.duration = 0.3;
    [cornerRadiusAnimation setBeginTime:self.isCollapsed ? 0: 0.5];
    return cornerRadiusAnimation;
}

- (CAKeyframeAnimation *)performWidthAnimation{
    CGFloat x = CGRectGetWidth(self.frame) - [self height];
    CGFloat y = CGRectGetHeight(self.frame) - [self height] / 2;

    CGPoint firstPosition = CGPointMake(x + [self height]/2, y);
    CGPoint finishPosition = CGPointMake(x/2+ [self height]/2, y);
    NSArray *values = self.isCollapsed ? @[[NSValue valueWithCGPoint:firstPosition], [NSValue valueWithCGPoint:finishPosition]] :  @[[NSValue valueWithCGPoint:finishPosition], [NSValue valueWithCGPoint:firstPosition]];
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:POSITION_KEY];
    positionAnimation.values = values;
    [positionAnimation setDuration:0.5];
    [positionAnimation setBeginTime:self.isCollapsed ? 0.3 : 0];
    return positionAnimation;
}

- (CAKeyframeAnimation *)performSizeWidthAnimation{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGRect firstSize = CGRectMake(0, 0, [self height]-2*FINAL_INSET_SIZE, [self height]-2*FINAL_INSET_SIZE);
    CGRect finalSize = CGRectMake(0, 0, width - FINAL_INSET_SIZE, [self height]-2*FINAL_INSET_SIZE);
    NSArray *sizeValues = self.isCollapsed ?  @[[NSValue valueWithCGRect:firstSize], [NSValue valueWithCGRect:finalSize]] : @[[NSValue valueWithCGRect:finalSize], [NSValue valueWithCGRect:firstSize]];
    CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:BOUNDS_KEY];
    sizeAnimation.values = sizeValues;
    sizeAnimation.duration = 0.5;
    [sizeAnimation setBeginTime:self.isCollapsed ? 0.3 : 0];
    return sizeAnimation;
}

- (void)performColorAnimation{
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    NSArray *values = [NSArray arrayWithObjects:
                       (id)[UIColor redColor].CGColor,
                       (id)[UIColor purpleColor].CGColor,
                       (id)[UIColor blueColor].CGColor,
                       nil];
    colorAnimation.values = values;
    colorAnimation.duration = 2;
    [self.roundView.layer addAnimation:colorAnimation forKey:@"backgroundColor"];
    
}

@end
