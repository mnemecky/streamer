#!/bin/sh

OUTPUT_PATH=/app

DEFAULT_AUDIO="copy"
DEFAULT_VIDEO="copy"
LACKING_AUDIO=""
IS_RTSP=""

INPUT=$1
OUTPUT=$2

# Check if codecs are already in the format supported by Chromecast devices (aac for audio and h264 for video)
AUDIO_RESULT="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name   -of default=noprint_wrappers=1:nokey=1 $INPUT)"
VIDEO_RESULT="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name   -of default=noprint_wrappers=1:nokey=1 $INPUT)"


if [ "$AUDIO_RESULT" != "aac" ]; then
  DEFAULT_AUDIO=aac
fi

# Check if it's empty to add silent dummy stream
if [ -z "$AUDIO_RESULT" ]; then
  LACKING_AUDIO="-f lavfi -i aevalsrc=0"
fi

if [ "$VIDEO_RESULT" != "h264" ]; then
  DEFAULT_VIDEO=h264
fi

case "$INPUT" in
  rtsp://*)
  IS_RTSP="-rtsp_transport tcp"
esac

FFMPEG_CMD="ffmpeg ${IS_RTSP} -thread_queue_size 32 -fflags +genpts -i ${INPUT} ${LACKING_AUDIO} -acodec ${DEFAULT_AUDIO} -vcodec ${DEFAULT_VIDEO} -hls_list_size 2 -hls_init_time 1 -hls_time 1 -hls_flags delete_segments ${OUTPUT_PATH}/${OUTPUT}.m3u8"

echo "${FFMPEG_CMD}"
