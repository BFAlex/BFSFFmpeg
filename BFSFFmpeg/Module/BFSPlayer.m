//
//  BFSPlayer.m
//  BFSFFmpeg
//
//  Created by Alex BF on 2018/12/10.
//  Copyright © 2018年 Alex BF. All rights reserved.
//

#import "BFSPlayer.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>

@interface BFSPlayer () {
    AVFormatContext     *_formatContext;
    AVCodecContext      *_codecContext;
    AVStream            *_stream;
    AVFrame             *_frame;
    
    int                 _videoStream;
    double              _fps;
}
@property (nonatomic, copy) NSString *moviePath;

@end

@implementation BFSPlayer

+ (instancetype)sharedInstance {
    
    static BFSPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[BFSPlayer alloc] init];
        [player configDefault];
    });
    
    return player;
}

- (void)configDefault {
    
    NSString *curMoviePath = @"...";
    self.moviePath = [curMoviePath copy];
    if (self.moviePath.length < 1) {
        return;
    }
    
    av_register_all();
    avformat_network_init();
    
    // 打开视频流
    int openResult = avformat_open_input(&self->_formatContext, [curMoviePath UTF8String], NULL, NULL);
    if (0 != openResult) {
        NSLog(@"open file fail.");
        goto initError;
    }
    
    int fsResult = avformat_find_stream_info(self->_formatContext, NULL);
    if (0 != fsResult) {
        NSLog(@"find sream fail");
        goto initError;
    }
    
    AVCodec *pCodec;
    _videoStream = av_find_best_stream(self->_formatContext, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0);
    if (0 > _videoStream) {
        NSLog(@"find best stream fail");
        goto initError;
    }
    
    // 打开视频流的详细信息
    self->_stream = self->_formatContext->streams[_videoStream];
    self->_codecContext = self->_stream->codec;
    
    if (_stream->avg_frame_rate.den && _stream->avg_frame_rate.num) {
        _fps = av_q2d(_stream->avg_frame_rate);
    } else {
        _fps = 30;
    }
    
    pCodec = avcodec_find_decoder(_codecContext->codec_id);
    if (!pCodec) {
        NSLog(@"找不到解码器");
        goto initError;
    }
    
    if (avcodec_open2(_codecContext, pCodec, NULL) < 0) {
        NSLog(@"打开解码器失败");
        goto initError;
    }
    
    _frame = av_frame_alloc();
    
    
initError:
    return;
}

- (void)seekTime:(double)seconds {
    
    AVRational timeBase = _formatContext->streams[_videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(_formatContext, _videoStream, 0, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(_codecContext);
}

@end
