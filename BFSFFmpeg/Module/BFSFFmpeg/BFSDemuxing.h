//
//  BFSDemuxing.h
//  BFSFFmpeg
//
//  Created by 刘玲 on 2019/2/16.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFSDemuxing : NSObject

- (void)startDemuxingForFile:(NSString *)fileUrl;

@end

NS_ASSUME_NONNULL_END
