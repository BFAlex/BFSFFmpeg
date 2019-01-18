//
//  FFmpegTestVC.m
//  BFSFFmpeg
//
//  Created by Alex BF on 2019/1/18.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#import "FFmpegTestVC.h"

@interface FFmpegTestVC ()

@end

@implementation FFmpegTestVC

- (instancetype)init {
    if (self = [super init]) {
        UIView *baseView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        baseView.backgroundColor = [UIColor blueColor];
        self.view = baseView;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self startDemuxingAV];
}

#pragma mark - demuxing

- (void)startDemuxingAV {
    
}

@end
