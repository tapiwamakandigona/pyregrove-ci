from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC = "/work/temp/emberwood_shots/store/s1_title.png"
OUT = "/work/temp/emberwood_shots/store/feature-graphic-1024x500.png"
FONT = "/work/repos/pyregrove/assets/fonts/Cinzel-Variable.ttf"

img = Image.open(SRC).convert("RGB")
# Clean forest band from the real title backdrop, avoiding the centered menu UI:
# use the full width but a band ABOVE the menu (y 0..640 has wordmark at 340-420...
# instead take lower-left forest: crop (0, 56) sized 1920x937 shifted so menu is out?
# Menu occupies x 630-940 y 335-550. Take band y=[143,1080] and paste a blurred
# cover over nothing -- simpler: use right-shifted crop x=[0,1920], y=[500,1080] is 580 tall.
# UI-free forest crop with correct 2.048 aspect: menu ends ~y660, so use
# y=[666,1080] (414 tall) and width 414*2.048=848 centered on x=960.
band = img.crop((581, 710, 1339, 1080)).resize((1024, 500), Image.LANCZOS)
band = band.filter(ImageFilter.GaussianBlur(0.5))
# darken slightly for wordmark contrast
overlay = Image.new("RGB", band.size, (10, 8, 6))
band = Image.blend(band, overlay, 0.25)

d = ImageDraw.Draw(band)
try:
    f_big = ImageFont.truetype(FONT, 92)
    f_big.set_variation_by_axes([700])
    f_sub = ImageFont.truetype(FONT, 30)
    f_sub.set_variation_by_axes([500])
except Exception as e:
    print("font err", e); raise

def center_text(draw, y, text, font, fill, ls=0):
    # letter-spaced centered text
    widths = [draw.textlength(c, font=font) + ls for c in text]
    total = sum(widths) - ls
    x = (1024 - total) / 2
    for c, w in zip(text, widths):
        draw.text((x, y), c, font=font, fill=fill)
        x += w

# glow
glow = Image.new("RGB", band.size, (0,0,0))
gd = ImageDraw.Draw(glow)
center_text(gd, 150, "PYREGROVE", f_big, (232, 99, 26), ls=14)
glow = glow.filter(ImageFilter.GaussianBlur(18))
from PIL import ImageChops
band = ImageChops.add(band, glow)

d = ImageDraw.Draw(band)
# shadow then wordmark
center_text(d, 154, "PYREGROVE", f_big, (0, 0, 0), ls=14)
center_text(d, 150, "PYREGROVE", f_big, (232, 163, 61), ls=14)
center_text(d, 285, "DELVE THE BURNING GROVE", f_sub, (222, 214, 202), ls=6)
center_text(d, 350, "FAIR PIXEL PLATFORMING — NO ADS, EVER.", f_sub, (150, 140, 128), ls=4)

band.save(OUT)
print("saved", band.size)
