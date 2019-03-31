//
//  ViewController.m
//  CustomViews
//
//  Created by Dmitry Sharygin on 11/02/2019.
//  Copyright © 2019 Dmitry Sharygin. All rights reserved.
//

#import "ViewController.h"
#import "DSCoreAnimationView.h"
#import <Masonry.h>

#pragma SUPERVIEW

@interface ViewController ()
@property (strong, nonatomic) DSCoreAnimationView *searchView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSCoreAnimationView *searchView = [DSCoreAnimationView new];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(24);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@44);
        make.width.equalTo(self.view).with.offset(-32);
    }];
    self.searchView = searchView;
    [self.view addGestureRecognizer:recognizer];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)handleTap:(UITapGestureRecognizer *)sender{
    [self.searchView resignFirstResponder];
}


@end
