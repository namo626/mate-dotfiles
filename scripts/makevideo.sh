ffmpeg -r $1 -i $2 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" $3
