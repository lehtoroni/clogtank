#!/bin/bash

swirl=$(( (RANDOM % 180) + 1 ))
stamp="$(date +%F_%H-%M-%S)"
text_colors=("cyan" "magenta" "yellow" "white" "black" "red" "green" "blue" "lime" "pink" "brown")

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
    random.png
    
convert random.png \
    -size 210x297 \
    -channel G \
    -threshold 50% \
    -separate \
    +channel -negate \
    -scale 2000% \
    random.png

#
# Create plasma noise with random swirl
#
convert -size 210x297 \
    -blur 0x1 -swirl $swirl -shave 20x20 \
    -paint 8 \
    -modulate 100,150,180 \
    -scale 20% \
    -scale 2000% \
    plasma:fractal temp.png

#
# Mask created noise with random mask from before
#
convert temp.png \( random.png -alpha off -negate \) \
    -compose copyopacity \
    -composite \
    temp.png
convert temp.png \
    -background white \
    -alpha remove \
    -alpha off \
    temp.png

#
# Loop all basic colors in the text_colors array,
# and write the timestamp over the image
#
for color in ${text_colors[@]}; do
    psize=$(( 50 + (RANDOM % 50) + 1 ))
    xpos=$(( -200 + (RANDOM % 400) + 1 ))
    ypos=$(( -400 + (RANDOM % 800) + 1 ))
    angle=$(( -90 + (RANDOM % 180) + 1 ))
    convert temp.png \
        -gravity Center \
        -pointsize $psize \
        -stroke white -strokewidth 20 \
        -annotate ${angle}x${angle}+${xpos}+${ypos} $stamp \
        -stroke black -strokewidth 4 \
        -annotate ${angle}x${angle}+${xpos}+${ypos} $stamp \
        -stroke none \
        -fill $color \
        -annotate ${angle}x${angle}+${xpos}+${ypos} $stamp \
        temp.png
    ypos=$((ypos+100))
done

#
# Finally, compress image to jpeg
#
convert temp.png temp.jpg
rm temp.png


#
# Print the file
#
if [ $2 = "pdf" ]; then
    convert temp.jpg -auto-orient temp.pdf
    lp -d $1 temp.pdf
else
    lp -o fit-to-page -d $1 temp.jpg
fi

echo "All done! (I hope!)"
