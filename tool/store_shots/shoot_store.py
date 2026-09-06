import asyncio, sys
from playwright.async_api import async_playwright

EXE = "/root/.cache/ms-playwright/chromium_headless_shell-1234/chrome-headless-shell-linux64/chrome-headless-shell"
BASE = "http://localhost:8123/index.html"
OUT = "/work/temp/emberwood_shots/store"

async def shot_static(page, name, q, settle=1500):
    await page.goto(f"{BASE}?{q}")
    await page.wait_for_function("window.__pyregrove && window.__pyregrove.loaded", timeout=30000)
    await page.wait_for_timeout(settle)
    await page.screenshot(path=f"{OUT}/{name}.png")
    print(name, "ok")

async def shot_action(page, name, q, actions, settle=1000):
    """actions: list of (delay_ms, kind, key_or_none). kind: down/up/press/shoot"""
    await page.goto(f"{BASE}?{q}")
    await page.wait_for_function("window.__pyregrove && window.__pyregrove.loaded", timeout=30000)
    await page.wait_for_timeout(settle)
    for delay, kind, key in actions:
        await page.wait_for_timeout(delay)
        if kind == "down":
            await page.keyboard.down(key)
        elif kind == "up":
            await page.keyboard.up(key)
        elif kind == "press":
            await page.keyboard.press(key)
        elif kind == "shoot":
            await page.screenshot(path=f"{OUT}/{name}.png")
            print(name, "ok")
            return
    await page.screenshot(path=f"{OUT}/{name}.png")
    print(name, "ok")

async def main():
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(executable_path=EXE)
        page = await browser.new_page(viewport={"width": 1920, "height": 1080})
        await shot_static(page, "s1_title", "screen=title", settle=2000)
        # w1 action: run right then attack mid-run
        await shot_action(page, "s2_w1_action", "level=w1_l2&seed=7", [
            (300, "down", "ArrowRight"),
            (900, "press", "Space"),
            (250, "press", "KeyX"),
            (120, "shoot", None),
        ])
        # w2 biome look, mid-run jump
        await shot_action(page, "s3_w2_action", "level=w2_l2&seed=13", [
            (300, "down", "ArrowRight"),
            (700, "press", "Space"),
            (200, "press", "Space"),
            (150, "shoot", None),
        ])
        # boss intro
        await shot_action(page, "s4_boss", "level=w1_boss&seed=7", [
            (300, "down", "ArrowRight"),
            (1200, "up", "ArrowRight"),
            (400, "press", "KeyX"),
            (150, "shoot", None),
        ])
        await shot_static(page, "s5_select", "screen=select&allclear=1", settle=1500)
        await shot_static(page, "s6_shop", "screen=shop&coins=300", settle=1500)
        await page.close()
        await browser.close()

asyncio.run(main())
