import asyncio, io
from playwright.async_api import async_playwright
from PIL import Image

EXE = "/root/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell"
BASE = "http://localhost:8123/index.html"
OUT = "/work/temp/emberwood_shots/store"

def golem_pixels(img):
    # dark greenish mass in central band
    band = img.crop((300, 300, 1650, 620)).convert("RGB")
    px = band.getdata()
    return sum(1 for r,g,b in px if r<70 and g<90 and b<80 and g>=r and g>=b)

def player_pixels(img):
    # red helmet plume anywhere mid-band
    band = img.crop((300, 350, 1650, 620)).convert("RGB")
    px = band.getdata()
    return sum(1 for r,g,b in px if r>160 and g<70 and b<70)

async def main():
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(executable_path=EXE)
        page = await browser.new_page(viewport={"width": 1920, "height": 1080})
        await page.goto(f"{BASE}?level=w1_boss&seed=42")
        await page.wait_for_function("window.__pyregrove && window.__pyregrove.loaded", timeout=30000)
        await page.wait_for_timeout(5200)
        # advance with the jump cadence that kept hearts full
        await page.keyboard.down("ArrowRight")
        for i in range(40):
            await page.wait_for_timeout(100)
            if i % 5 == 2: await page.keyboard.press("Space")
            if i % 5 == 3: await page.keyboard.press("Space")
            t = await page.evaluate("window.__pyregrove")
            if t["x"] >= 300: break
        await page.keyboard.up("ArrowRight")
        results = []
        for i in range(25):
            await page.wait_for_timeout(120)
            if i % 6 == 3: await page.keyboard.press("KeyX")
            buf = await page.screenshot()
            t = await page.evaluate("window.__pyregrove")
            img = Image.open(io.BytesIO(buf))
            g, p = golem_pixels(img), player_pixels(img)
            results.append((min(g, 2000) + min(p*10, 2000), g, p, i, t["hearts"], buf))
            if t["over"]: break
        results.sort(key=lambda r: -r[0])
        for rank, (score, g, p, i, hearts, buf) in enumerate(results[:4]):
            open(f"{OUT}/duel_{rank}.png","wb").write(buf)
            print("rank",rank,"frame",i,"golem_px",g,"player_px",p,"hearts",hearts)
        await page.close(); await browser.close()

asyncio.run(main())
