//
//  BFSDemuxing.m
//  BFSFFmpeg
//
//  Created by 刘玲 on 2019/2/16.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#import "BFSDemuxing.h"
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/imgutils.h>
#include <libavcodec/avcodec.h>


@interface BFSDemuxing() {
    
    AVFormatContext *fmt_ctx;
    AVCodecContext  *dec_ctx;
    AVCodecContext  *video_dec_ctx;
    AVCodecContext  *audio_dec_ctx;
    AVStream        *video_stream;
    AVStream        *audio_stream;
    FILE            *video_dst_file;
    FILE            *audio_dst_file;
    AVFrame         *frame;
    AVPacket        pkt;
    
    int refcount;
    int video_stream_idx;
    int audio_stream_idx;
    NSString *src_filename;
    NSString *video_dst_filename;
    NSString *audio_dst_filename;
    int video_frame_count;
    int audio_frame_count;
    uint8_t *video_dst_data[4];
    int     video_dst_linesize[4];
    int     video_dst_bufsize;
    
    int width;
    int height;
    enum AVPixelFormat pix_fmt;
    
}

@end

@implementation BFSDemuxing

- (void)startDemuxingForFile:(NSString *)fileUrl {
    
    int ret = 0;
    int got_frame;
    //
    if (avformat_open_input(&fmt_ctx, [fileUrl UTF8String], NULL, NULL) < 0) {
        NSLog(@"");
        return;
    }
    //
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        NSLog(@"");
        return;
    }
    //
    if ([self open_codec_context:&video_stream_idx codecContext:&video_dec_ctx formatContext:fmt_ctx andMediaType:AVMEDIA_TYPE_VIDEO] >= 0) {
        video_stream = fmt_ctx->streams[video_stream_idx];
        video_dst_file = fopen([video_dst_filename UTF8String], "wb");
        if (!video_dst_file) {
            NSLog(@"");
            ret = 1;
            goto end;
        }
    }
    width = video_dec_ctx->width;
    height = video_dec_ctx->height;
    pix_fmt = video_dec_ctx->pix_fmt;
    ret = av_image_alloc(video_dst_data, video_dst_linesize, width, height, pix_fmt, 1);
    if (ret < 0) {
        NSLog(@"");
        goto end;
    }
    video_dst_bufsize = ret;
    
    if ([self open_codec_context:&audio_stream_idx codecContext:&audio_dec_ctx formatContext:fmt_ctx andMediaType:AVMEDIA_TYPE_AUDIO] >= 0) {
        audio_stream = fmt_ctx->streams[audio_stream_idx];
        audio_dst_file = fopen([audio_dst_filename UTF8String], "wb");
        if (!audio_dst_file) {
            NSLog(@"");
            ret = 1;
            goto end;
        }
    }
    av_dump_format(fmt_ctx, 0, [src_filename UTF8String], 0);
    if (!audio_stream && !video_stream) {
        NSLog(@"");
        ret = 1;
        goto end;
    }
    frame = av_frame_alloc();
    if (!frame) {
        NSLog(@"");
        ret = -12;
        goto end;
    }
    
    av_init_packet(&pkt);
    pkt.data = NULL;
    pkt.size = NULL;
    if (video_stream) {
        NSLog(@"");
    }
    if (audio_stream) {
        NSLog(@"");
    }
    //
    while (av_read_frame(fmt_ctx, &pkt) >= 0) {
        AVPacket orig_pkt = pkt;
        do {
            ret = [self decode_packet:&got_frame andCached:0];
            if (ret < 0) {
                break;
            }
            pkt.data += ret;
            pkt.size -= ret;
        } while (pkt.size > 0);
        av_packet_unref(&orig_pkt);
    }
    
    pkt.data = NULL;
    pkt.size = 0;
    do {
        [self decode_packet:&got_frame andCached:1];
    }while (got_frame);
    
    if (video_stream) {
        NSLog(@"video_stream");
    }
    if (audio_stream) {
        enum AVSampleFormat sfmt = audio_dec_ctx->sample_fmt;
        int n_channels = audio_dec_ctx->channels;
        const char *fmt;
        if (av_sample_fmt_is_planar(sfmt)) {
            const char *packed = av_get_sample_fmt_name(sfmt);
            NSLog(@"");
            sfmt = av_get_packed_sample_fmt(sfmt);
            n_channels = 1;
        }
        if ((ret = [self get_format_from_sample_fmt:&fmt andAVSampleFormat:sfmt])) {
            goto end;
        }
    }
    
end:
    avcodec_free_context(&video_dec_ctx);
    avcodec_free_context(&audio_dec_ctx);
    avformat_close_input(&fmt_ctx);
    if (video_dst_file) {
        fclose(video_dst_file);
    }
    if (audio_dst_file) {
        fclose(audio_dst_file);
    }
    av_frame_free(&frame);
    av_free(video_dst_data[0]);
    
    return;
}

- (int)get_format_from_sample_fmt:(const char **)fmt andAVSampleFormat:(enum AVSampleFormat)sample_fmt {
    
    int i;
    struct sample_fmt_entry {
        enum AVSampleFormat sample_fmt;
        const char *fmt_be;
        const char *fmt_le;
    } sample_fmt_entries[] = {
        { AV_SAMPLE_FMT_U8,  "u8",    "u8"    },
        { AV_SAMPLE_FMT_S16, "s16be", "s16le" },
        { AV_SAMPLE_FMT_S32, "s32be", "s32le" },
        { AV_SAMPLE_FMT_FLT, "f32be", "f32le" },
        { AV_SAMPLE_FMT_DBL, "f64be", "f64le" },
    };
    *fmt = NULL;
    for (i = 0; i < FF_ARRAY_ELEMS(sample_fmt_entries); i++) {
        struct sample_fmt_entry *entry = &sample_fmt_entries[i];
        if (sample_fmt == entry->sample_fmt) {
            *fmt = AV_NE(entry->fmt_be, entry->fmt_le);
            return 0;
        }
    }
    NSLog(@"");
    
    return -1;
}

- (int)decode_packet:(int *)got_frame andCached:(int)cached {
    
    int ret = 0;
    int decoded = pkt.size;
    *got_frame = 0;
    if (pkt.stream_index == video_stream_idx) {
        
        ret = avcodec_decode_video2(video_dec_ctx, frame, got_frame, &pkt);
        if (ret < 0) {
            NSLog(@"");
            return ret;
        }
        if (*got_frame) {
            if (frame->width != width || frame->height != height || frame->format != pix_fmt) {
                NSLog(@"");
                return -1;
            }
            NSLog(@"");
            av_image_copy(video_dst_data, video_dst_linesize, (const uint8_t **)(frame->data), frame->linesize, pix_fmt, width, height);
            fwrite(video_dst_data[0], 1, video_dst_bufsize, video_dst_file);
        }
    } else if (pkt.stream_index == audio_stream_idx) {
        
        ret = avcodec_decode_audio4(audio_dec_ctx, frame, got_frame, &pkt);
        if (ret < 0) {
            NSLog(@"");
            return ret;
        }
        decoded = FFMIN(ret, pkt.size);
        if (*got_frame) {
            size_t unpadded_linesize = frame->nb_samples * av_get_bytes_per_sample(frame->format);
            NSLog(@"");
            fwrite(frame->extended_data[0], 1, unpadded_linesize, audio_dst_file);
        }
    }
    
    if (*got_frame && refcount) {
        av_frame_unref(frame);
    }
    
    return decoded;
}

- (int)open_codec_context:(int *)stream_idx
             codecContext:(AVCodecContext **)dec_ctx
            formatContext:(AVFormatContext *)fmt_ctx andMediaType:(enum AVMediaType)type {
    
    int ret;
    int stream_index;
    AVStream *st;
    AVCodec *dec = NULL;
    AVDictionary *opts = NULL;
    
    ret = av_find_best_stream(fmt_ctx, type, -1, -1, NULL, 0);
    if (ret < 0) {
        NSLog(@"");
        return ret;
    }
    
    stream_index = ret;
    st = fmt_ctx->streams[stream_index];
    dec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!dec) {
        NSLog(@"");
        return -22;
    }
    
    *dec_ctx = avcodec_alloc_context3(dec);
    if (!*dec_ctx) {
        NSLog(@"");
        return -12;
    }
    
    if ((ret = avcodec_parameters_to_context(*dec_ctx, st->codecpar)) < 0) {
        NSLog(@"");
        return ret;
    }
    
    av_dict_set(&opts, "refcounted_frames", refcount ? "1" : "0", 0);
    if ((ret = avcodec_open2(*dec_ctx, dec, &opts)) < 0) {
        NSLog(@"");
        return ret;
    }
    
    *stream_idx = stream_index;
    
    return 0;
}

@end
