ffmpeg -r 10 -i $1 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" $2
