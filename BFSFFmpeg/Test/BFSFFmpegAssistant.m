//
//  BFSFFmpegAssistant.m
//  BFSFFmpeg
//
//  Created by Alex BF on 2019/1/18.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#import "BFSFFmpegAssistant.h"
#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>

@implementation BFSFFmpegAssistant

- (BOOL)start {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    if (filePath.length < 1) {
        NSLog(@"file path: %@", filePath);
        goto initError;
    }
    //
    av_register_all();
    //
    static AVFormatContext *formatCtx = NULL;
    if (avformat_open_input(&formatCtx, [filePath cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL) < 0) {
        NSLog(@"open file fail...");
        goto initError;
    }
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        NSLog(@"find stream info fail...");
        goto initError;
    }
    
    AVPacket packet;
    av_init_packet(&packet);
    packet.data = NULL;
    packet.size = 0;
    while (av_read_frame(formatCtx, &packet) >= 0) {
        AVPacket curPacket = packet;
//        do {
//            
//        } while (packet.size > 0);
        
    }
    
    
    return true;
initError:
    return false;
}

@end
