//
//  BFSPlayer.h
//  BFSFFmpeg
//
//  Created by Alex BF on 2018/12/10.
//  Copyright © 2018年 Alex BF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFSPlayer : NSObject

+ (instancetype)sharedInstance;

- (void)seekTime:(double)seconds;

@end
