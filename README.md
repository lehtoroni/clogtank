# clogtank.sh 🖨️🩸

Do you have an inkjet tank printer, such as an Epson EcoTank?
Do you not print often enough, thus your printheads get clogged, and you reduce the lifetime of your printer by filling up the waste sponge with each head cleaning?

Here, take **clogtank.sh**, a Bash script which generates a simple image with many colors and prints it with the given printer. Just add it to a cronjob, remember to keep paper loaded to your printer, and never have a clogged printhead again! (Hopefully!)

## Requirements
- **Bash** on Linux (might work on WSL too?)
    - Tested to work on `Debian 6.1.106-3`
- **CUPS** (`sudo apt install cups cups-client`) and a printer configured on it
- **ImageMagick** (`sudo apt install imagemagick`)
    - Tested to work with version `ImageMagick 6.9.11-60 Q16 x86_64`

If you want to automate the printing, you will need a Linux server, NAS, Raspberry Pi, or anything connected to your printer (or network, if you want to get fancy). Then you will also need **Cron**.

## Usage
```bash
./clogtank.sh cups_printer_id_here
```

Tested on a network EcoTank with the following command:
```bash
./clogtank.sh EPSON_ET_2870_Series
```

**If for some reason your CUPS will not print the jpeg directly,**
you can give "pdf" as the second argument:
```bash
./clogtank.sh cups_printer_id_here pdf
```

To use this, you will probably have to [allow PDF modifications in ImageMagick's security policy](https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion).

## Example of installation
Run `crontab -e` to edit your Cron jobs.
Then add the following line:
```
0 15 */3 * * /path/to/clogtank.sh cups_printer_id_here
```
This will print a random page every 3 days at 15:00.

## Word of caution
**ImageMagick and Cups might work differently based on the installed version.**
Go ahead and modify the script parameters for your need, if it doesn't work at first!

## Troubleshooting: Print as PDF instead of JPG?
On my server, the jpeg does not get printed. The printer just wakes up and does nothing.
Thus, there is the option to print the image as a pdf.

Just uncomment these lines:


## What does it do?

Below is an example of the produced image.
The script generates some noise, masks it with other noise,
and overlays the current timestamp in many colors on top.

Then the script sends the image to your chosen printer via `lp`,
and requests the image to be fit to the page.

The idea is that by printing all colors often enough,
the printheads shouldn't get clogged.

Does this waste a lot of ink? Honestly, I'm not concerned of that. After printing hundreds and hundreds of pages on an ink tank printer, and only seeing the ink levels drop a little, it shouldn't be an issue.

And afterall, less head cleanings means less money spent on a maintenance box or a new printer in the future, even if a few A4 sheets were wasted in the process.

<img src="https://lehtodigital.fi/f/awy0n" style="width: 300px;">

# License
The script is licensed under the MIT license.
This project was made just for fun (and for a very specific use of the author),
but useful commits are welcome!

