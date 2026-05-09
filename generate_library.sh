#!/bin/bash

mkdir -p music

artists=("Amthcis" "Lofi Girl" "Electronic Master")
genres=("Amthcis" "Lofi" "Electronic")

for i in "${!artists[@]}"; do
    artist="${artists[$i]}"
    genre="${genres[$i]}"
    for album in "Album 1" "Album 2"; do
        mkdir -p "music/$artist/$album"
        for track in {1..5}; do
            filename="music/$artist/$album/Track $track.mp3"
            ffmpeg -y -f lavfi -i "anullsrc=r=44100:cl=stereo" -t 1 -c:a libmp3lame \
                -metadata artist="$artist" \
                -metadata album="$album" \
                -metadata title="Track $track" \
                -metadata genre="$genre" \
                "$filename"
        done
    done
done

echo "Fake library generated."
