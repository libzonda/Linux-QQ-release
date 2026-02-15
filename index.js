const { chromium } = require('playwright');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function downloadFile(url, downloadFolder) {
    try {
        const fileName = path.basename(url);
        const filePath = path.join(downloadFolder, fileName);
        console.log(`Downloading ${fileName}...`);
        const response = await axios({ method: 'GET', url: url, responseType: 'stream' });
        const writer = fs.createWriteStream(filePath);
        response.data.pipe(writer);
        return new Promise((resolve, reject) => {
            writer.on('finish', () => { console.log(`Successfully downloaded ${fileName}`); resolve(); });
            writer.on('error', (err) => { console.error(`Failed to download ${fileName}:`, err.message); reject(err); });
        });
    } catch (error) {
        console.error(`Error downloading from ${url}:`, error.message);
    }
}

(async () => {
    // Note: headless: false requires Xvfb in CI environments
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext({
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        viewport: { width: 1920, height: 1080 },
        locale: 'zh-CN',
        timezoneId: 'Asia/Shanghai',
        extraHTTPHeaders: {
            'X-Forwarded-For': '183.60.209.130', // Force domestic (Shenzhen) IP hint
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
        }
    });

    await context.addInitScript(() => {
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
    });

    const page = await context.newPage();

    try {
        const timestamp = Date.now();
        // Navigate DIRECTLY to the config JS file to bypass any main-page caching/redirection issues
        const url = `https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxConfig.js?ga_t=${timestamp}`;

        console.log(`Navigating directly to config URL: ${url}`);
        await page.goto(url, { waitUntil: 'networkidle' });

        // Extract the content directly from the page body (Chromium displays JS as text)
        const text = await page.evaluate(() => document.body.innerText);

        // Extract JSON part: look for "var params= { ... };"
        const jsonMatch = text.match(/var params=\s*(\{[\s\S]*?\});/);

        if (!jsonMatch) {
            console.error('Failed to extract download links from direct page load. Content found:');
            console.error(text.substring(0, 500));
            return;
        }

        const config = JSON.parse(jsonMatch[1]);
        console.log(`Successfully parsed version: ${config.version}`);

        const extractUrls = (obj) => {
            let urls = [];
            for (const key in obj) {
                if (typeof obj[key] === 'string' && obj[key].startsWith('http')) {
                    urls.push(obj[key]);
                } else if (typeof obj[key] === 'object' && obj[key] !== null) {
                    urls = urls.concat(extractUrls(obj[key]));
                }
            }
            return urls;
        };
        const links = extractUrls(config);

        if (links.length === 0) {
            console.error('No links found in the config object.');
            return;
        }

        console.log(`Found ${links.length} download links.`);
        const versionMatch = path.basename(links[0]).match(/QQ_([0-9.]+_[0-9.]+)/);
        const version = versionMatch ? versionMatch[1] : (config.version || 'unknown');
        console.log(`Extracted version for release: ${version}`);
        fs.writeFileSync('version.txt', version);

        let linksMd = '### Official Download Links\n\n| Filename | Official URL |\n| :--- | :--- |\n';
        links.forEach(link => { linksMd += `| ${path.basename(link)} | [Download](${link}) |\n`; });
        fs.writeFileSync('links.md', linksMd);

        const downloadFolder = path.join(__dirname, 'downloads');
        if (!fs.existsSync(downloadFolder)) fs.mkdirSync(downloadFolder);

        for (const link of links) {
            await downloadFile(link, downloadFolder);
        }
        console.log('All downloads completed.');
    } catch (error) {
        console.error('An error occurred:', error.message);
    } finally {
        await browser.close();
    }
})();
