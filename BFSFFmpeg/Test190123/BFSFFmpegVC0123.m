//
//  BFSFFmpegVC0123.m
//  BFSFFmpeg
//
//  Created by Alex BF on 2019/1/23.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#import "BFSFFmpegVC0123.h"

@interface BFSFFmpegVC0123 ()

@end

@implementation BFSFFmpegVC0123

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Action

- (IBAction)actionEncodeBtn:(UIButton *)sender {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}


@end
