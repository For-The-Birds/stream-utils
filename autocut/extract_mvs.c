/*
 * Copyright (c) 2012 Stefano Sabatini
 * Copyright (c) 2014 Clément Bœsch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// gcc extract_mvs.c -o extract_mvs -lavcodec -lavutil -lavformat -lm

#include <libavutil/motion_vector.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>

/*
#include <time.h>

unsigned count = 0;
struct timespec start, stop;

double ts_diff(struct timespec *ts1, struct timespec *ts2) {
    return ts1->tv_sec - ts2->tv_sec + (ts1->tv_nsec - ts2->tv_nsec) / 1e9;
}

void tstart(unsigned c) {
    count = c;
    clock_gettime(CLOCK_MONOTONIC, &start);
}

double tfinish(unsigned c) {
    clock_gettime(CLOCK_MONOTONIC, &stop);
    unsigned d = c - count;
    double sps = d/ts_diff(&stop, &start); // samples per second
    tstart(c);
    return sps;
}
*/

static AVFormatContext *fmt_ctx = NULL;
static AVCodecContext *video_dec_ctx = NULL;
static AVStream *video_stream = NULL;
static const char *src_filename = NULL;

static int video_stream_idx = -1;
static AVFrame *frame = NULL;
static int frame_count = 0;

int64_t old_pts = 0, old_i = 0;
double old_sum = 0, old_area = 0;

static int decode_packet(const AVPacket *pkt)
{
    const float fps = (float)(video_dec_ctx->framerate.num)/video_dec_ctx->framerate.den;
    const float tb = (float)(video_dec_ctx->time_base.num)/video_dec_ctx->time_base.den;
    int ret;
#if 0
    do {
        ret = avcodec_send_packet(video_dec_ctx, pkt);
    } while (ret != AVERROR(EAGAIN) || ret > 0);
    if (ret < 0 && ret != AVERROR(EAGAIN)) {
        fprintf(stderr, "Error during decoding\n");
        return ret;
    }
#else
    ret = avcodec_send_packet(video_dec_ctx, pkt);
    if (ret < 0) {
        fprintf(stderr, "Error while sending a packet to the decoder: %s\n", av_err2str(ret));
        return ret;
    }
#endif

    //tstart(frame_count);

    while (1)  {
//    do {
        ret = avcodec_receive_frame(video_dec_ctx, frame);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            break;
        } else if (ret < 0) {
            fprintf(stderr, "Error while receiving a frame from the decoder: %s\n", av_err2str(ret));
            return ret;
        }

        if (ret >= 0) {
            int i;
            AVFrameSideData *sd;

            frame_count++;
            //printf("Frame %0.9d,", frame_count);
            //if (frame_count % 100 == 0)
            //    printf(" fps %0.3f,", tfinish(frame_count));

            sd = av_frame_get_side_data(frame, AV_FRAME_DATA_MOTION_VECTORS);
            if (sd) {
                const AVMotionVector *mvs = (const AVMotionVector *)sd->data;
                double sum = 0, area = 0;
                for (i = 0; i < sd->size / sizeof(*mvs); i++) {
                    const AVMotionVector *mv = &mvs[i];
                    const int dx = mv->src_x - mv->dst_x;
                    const int dy = mv->src_y - mv->dst_y;
                    sum += sqrt(dx*dx + dy*dy);// * (mv->w * mv->h);
                    area += mv->w * mv->h;
                    /*
                    printf("%d,%2d,%2d,%2d,%4d,%4d,%4d,%4d,0x%"PRIx64"\n",
                        frame_count, mv->source,
                        mv->w, mv->h, mv->src_x, mv->src_y,
                        mv->dst_x, mv->dst_y, mv->flags);
                        */
                }
                //sum /= i;
                if (old_pts == frame->pts) {
                    old_sum += sum;
                    old_area += area;
                    old_i += i;
                } else {
//#define PRINTF_ALL
#ifdef PRINTF_ALL
                    printf("%d\t%lu\t%f\t%f\t%f\n",
                        frame_count,
                        old_i,
                        old_area,
                        old_pts/fps,
                        old_sum);
#else
                    printf("%f\t%f\n",
                        old_pts*tb*0.1,
                        old_sum);
#endif
                    old_sum = sum;
                    old_area = area;
                    old_i = i;
                    old_pts = frame->pts;
                }
            }
            av_frame_unref(frame);
        }
        //printf("\r");
        //fflush(stdout);
    }
    //while (ret >= 0 || ret != AVERROR(EAGAIN));


    return 0;
}

static int open_codec_context(AVFormatContext *fmt_ctx, enum AVMediaType type)
{
    int ret;
    AVStream *st;
    AVCodecContext *dec_ctx = NULL;
    const AVCodec *dec = NULL;
    AVDictionary *opts = NULL;

    ret = av_find_best_stream(fmt_ctx, type, -1, -1, &dec, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not find %s stream in input file '%s'\n",
                av_get_media_type_string(type), src_filename);
        return ret;
    } else {
        int stream_idx = ret;
        st = fmt_ctx->streams[stream_idx];

        dec_ctx = avcodec_alloc_context3(dec);
        if (!dec_ctx) {
            fprintf(stderr, "Failed to allocate codec\n");
            return AVERROR(EINVAL);
        }

        ret = avcodec_parameters_to_context(dec_ctx, st->codecpar);
        if (ret < 0) {
            fprintf(stderr, "Failed to copy codec parameters to codec context\n");
            return ret;
        }

        // set codec to automatically determine how many threads suits best for the decoding job
        dec_ctx->thread_count = 0;

        if (dec->capabilities | AV_CODEC_CAP_FRAME_THREADS)
            dec_ctx->thread_type |= FF_THREAD_FRAME;
        if (dec->capabilities | AV_CODEC_CAP_SLICE_THREADS)
            dec_ctx->thread_type |= FF_THREAD_SLICE;
        else
            dec_ctx->thread_count = 1; //don't use multithreading

        //dec_ctx->skip_frame = AVDISCARD_NONKEY;
        /* Init the video decoder */
        av_dict_set(&opts, "flags2", "+export_mvs", 0);
        ret = avcodec_open2(dec_ctx, dec, &opts);
        av_dict_free(&opts);
        if (ret < 0) {
            fprintf(stderr, "Failed to open %s codec\n",
                    av_get_media_type_string(type));
            return ret;
        }

        video_stream_idx = stream_idx;
        video_stream = fmt_ctx->streams[video_stream_idx];
        video_dec_ctx = dec_ctx;
    }

    return 0;
}

int main(int argc, char **argv)
{
    int ret = 0;
    AVPacket *pkt = NULL;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <video>\n", argv[0]);
        exit(1);
    }
    src_filename = argv[1];

    if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
        fprintf(stderr, "Could not open source file %s\n", src_filename);
        exit(1);
    }

    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        exit(1);
    }

    open_codec_context(fmt_ctx, AVMEDIA_TYPE_VIDEO);

    av_dump_format(fmt_ctx, 0, src_filename, 0);

    if (!video_stream) {
        fprintf(stderr, "Could not find video stream in the input, aborting\n");
        ret = 1;
        goto end;
    }

    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Could not allocate frame\n");
        ret = AVERROR(ENOMEM);
        goto end;
    }

    pkt = av_packet_alloc();
    if (!pkt) {
        fprintf(stderr, "Could not allocate AVPacket\n");
        ret = AVERROR(ENOMEM);
        goto end;
    }

    //printf("framenum,source,blockw,blockh,srcx,srcy,dstx,dsty,flags\n");

    /* read frames from the file */
    while (av_read_frame(fmt_ctx, pkt) >= 0) {
        if (pkt->stream_index == video_stream_idx)
            ret = decode_packet(pkt);
        av_packet_unref(pkt);
        if (ret < 0)
            break;
    }

    /* flush cached frames */
    decode_packet(NULL);

end:
    avcodec_free_context(&video_dec_ctx);
    avformat_close_input(&fmt_ctx);
    av_frame_free(&frame);
    av_packet_free(&pkt);
    return ret < 0;
}
