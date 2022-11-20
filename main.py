from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# driverのpath指定
CHROMEDRIVER = '/usr/bin/chromedriver'
# 対象URL
URL = 'https://honahuku.com/'

# ドライバー指定でChromeを開く
chrome_service = Service(ChromeDriverManager().install())

options = Options()

# GUIがない環境で起動するためのオプション
# options.add_argumentでの指定はなぜか落ちる
options.headless = True

# docker内で起動するためにsandboxをオフにする
options.add_argument('--no-sandbox')

# メモリ省力化のフラグ
options.add_argument('--disable-gpu')

# ディスクのメモリスペースを使う
options.add_argument('--disable-dev-shm-usage')

options.add_argument(f'service={chrome_service}')
# ブラウザを表示しない

driver = webdriver.Chrome(service=chrome_service, options=options)

# ウィンドウサイズ＝画像サイズ
driver.set_window_size(1024, 768)
# 対象ページへアクセス
driver.get(URL)
# スクリーンショットを取得
driver.save_screenshot('result.png')

driver.quit()