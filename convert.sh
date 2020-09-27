#!/bin/bash
mkdir -p output
SWFFILE=$1
FILENAME=$(basename $1)
MP4FILE=${FILENAME%.*}.mp4
TMPFILE=/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 32 | head -n 1).bin
TMPMP4=/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 32 | head -n 1).mp4
COMPRESSEDMP4=/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 32 | head -n 1).mp4
TMPMP3=/tmp/$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 32 | head -n 1).mp3

# create raw-dump
GNASHCMD="dump-gnash -1 -r 1 -D $TMPFILE $SWFFILE"
OUTPUT="$(exec $GNASHCMD)"

# extract parameters
WIDTH="$(echo $OUTPUT | grep -o 'WIDTH=[^, }]*' | sed 's/^.*=//')"
HEIGHT="$(echo $OUTPUT | grep -o 'HEIGHT=[^, }]*' | sed 's/^.*=//')"
FPS="$(echo $OUTPUT | grep -o 'FPS_ACTUAL=[^, }]*' | sed 's/^.*=//')"

# create raw, uncompressed mp4 file
mplayer $TMPFILE -vo yuv4mpeg:file=$TMPMP4 -demuxer rawvideo -rawvideo fps=$FPS:w=$WIDTH:h=$HEIGHT:format=bgra

# create compressed mp4 
ffmpeg -i $TMPMP4 -vcodec libx264 $COMPRESSEDMP4

# strip the autio from swf file 
ffmpeg -i $SWFFILE $TMPMP3

#conbine audio and video 
ffmpeg -i $COMPRESSEDMP4 -i $TMPMP3 -c:v copy -c:a aac output/$MP4FILE 

# clean up
rm -rf  $TMPFILE $TMPMP4 $COMPRESSEDMP4 $TMPMP3

