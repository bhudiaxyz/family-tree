import time
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch(executable_path="C:/Program Files/Google/Chrome/Application/chrome.exe", args=["--use-angle=swiftshader","--enable-unsafe-swiftshader"])
    pg = b.new_page(viewport={"width": 1600, "height": 860})
    errs=[]; pg.on("pageerror", lambda e: errs.append(str(e))); pg.on("console", lambda m: m.type=="error" and errs.append(m.text[:200]))
    pg.goto("http://localhost:5199/family-tree/?saga=potter"); time.sleep(6)
    print(pg.evaluate("[...document.querySelectorAll('.lil-gui .controller')].map(c => c.className + ' | ' + c.textContent.trim().slice(0,30) + ' | ' + c.style.display)"))
    b.close(); print("errors:", errs)
