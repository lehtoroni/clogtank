#!/bin/bash

swirl=$(( (RANDOM % 180) + 1 ))
stamp="$(date '+%F %H:%M:%S')"

if ! command -v convert 2>&1 >/dev/null
then
    echo "No 'convert' command was found. Please install ImageMagick."
    exit 1
fi

if [ -z "$1" ]; then
    echo "No arguments specified! Usage: ./clogtank.sh [printer_cups_id]"
    exit 1
fi

#
# Create pixel mask
#
convert -size 210x297 \
    -scale 20% \
    xc: +noise Random \
    -scale 500% \
    random.png
    
# Create striped pixel mask pattern
convert random.png \
    -size 210x297 \
    -channel G \
    -threshold 50% \
    -separate \
    +channel -negate \
    -gravity NorthWest -pointsize 200 \
    -draw "fill white   rectangle 0,0 210,30" \
    -draw "fill white   rectangle 0,75 210,105" \
    -draw "fill white   rectangle 0,150 210,180" \
    -draw "fill white   rectangle 0,225 210,255" \
    random.png
    
# Resize pixel pattern
convert random.png \
    -resize 2100x2970 \
    -filter point \
    random.png

# Draw color bars
convert -size 2100x2970 \
    -gravity NorthWest -pointsize 80 \
    xc:white \
    -draw "fill black   rectangle 1,1 2100,750" \
    -draw "fill cyan    rectangle 1,750 2100,1500" \
    -draw "fill magenta rectangle 1,1500 2100,2250" \
    -draw "fill yellow  rectangle 1,2250 2100,2970" \
    -draw "fill white   text 15,15 '$stamp'" \
    temp.png

# Mask with the random pattern
convert temp.png \( random.png -alpha off \) \
    -compose copyopacity \
    -composite \
    temp.png

convert temp.png \
    -background white \
    -alpha remove \
    -alpha off \
    temp.png

#
# Finally, compress image to jpeg
#
convert temp.png temp.jpg
rm temp.png


#
# Print the file
#
if printf '%s\n' "$@" | grep -qx -- "--dry-run"; then
    echo "Dry-run, not printing"
else
    if [ $2 = "pdf" ]; then
        convert temp.jpg -auto-orient temp.pdf
        lp -d $1 temp.pdf
    else
        lp -o fit-to-page -d $1 temp.jpg
    fi
fi

echo "All done! (I hope!)"
