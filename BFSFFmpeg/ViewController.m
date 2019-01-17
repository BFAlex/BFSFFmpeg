//
//  ViewController.m
//  BFSFFmpeg
//
//  Created by Alex BF on 2018/12/4.
//  Copyright © 2018年 Alex BF. All rights reserved.
//

#import "ViewController.h"
#import "BFSPlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *playerBG;
@property (nonatomic, assign) float lastFrameTime;

@property (nonatomic, strong) BFSPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.player = [BFSPlayer sharedInstance];
}


#pragma mark - Action

- (IBAction)actionPlayBtn:(UIButton *)sender {
    
    self.lastFrameTime = -1;
    [_player seekTime:0.0];
    
}


@end
