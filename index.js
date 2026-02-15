const { chromium } = require('playwright');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function downloadFile(url, downloadFolder) {
    try {
        const fileName = path.basename(url);
        const filePath = path.join(downloadFolder, fileName);

        console.log(`Downloading ${fileName}...`);

        const response = await axios({
            method: 'GET',
            url: url,
            responseType: 'stream'
        });

        const writer = fs.createWriteStream(filePath);
        response.data.pipe(writer);

        return new Promise((resolve, reject) => {
            writer.on('finish', () => {
                console.log(`Successfully downloaded ${fileName}`);
                resolve();
            });
            writer.on('error', (err) => {
                console.error(`Failed to download ${fileName}:`, err.message);
                reject(err);
            });
        });
    } catch (error) {
        console.error(`Error downloading from ${url}:`, error.message);
    }
}

(async () => {
    const browser = await chromium.launch({ headless: true });
    const context = await browser.newContext({
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        viewport: { width: 1920, height: 1080 },
        deviceScaleFactor: 1,
        locale: 'zh-CN',
        timezoneId: 'Asia/Shanghai',
        extraHTTPHeaders: {
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
            'DNT': '1',
        }
    });

    // Stealth: Add init script to mask automation
    await context.addInitScript(() => {
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
        Object.defineProperty(navigator, 'languages', { get: () => ['zh-CN', 'zh'] });
        Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
    });

    const page = await context.newPage();

    try {
        const timestamp = Date.now();
        const url = `https://im.qq.com/linuxqq/index.shtml?t=${timestamp}`;

        // Intercept requests to linuxConfig.js and append cache-busting timestamp
        await page.route('**/linuxConfig.js', route => {
            const requestUrl = route.request().url();
            const newUrl = `${requestUrl}${requestUrl.includes('?') ? '&' : '?'}t=${timestamp}`;
            console.log(`Intercepted and cache-busting: ${newUrl}`);
            route.continue({ url: newUrl });
        });

        console.log(`Navigating to ${url}...`);
        await page.goto(url, { waitUntil: 'networkidle' });

        // Wait a bit more for the JS to execute and populate the links
        console.log('Waiting for download links to populate...');
        await page.waitForTimeout(3000);

        // Select all download links based on the provided selector
        console.log('Locating download links...');
        const links = await page.$$eval('div#id-download-area div.down-btn a', anchors =>
            anchors.map(a => a.href).filter(href => href && (href.startsWith('http') || href.endsWith('.deb') || href.endsWith('.rpm') || href.endsWith('.AppImage')))
        );

        console.log('Links found:', JSON.stringify(links, null, 2));

        if (links.length === 0) {
            console.log('No download links found. Please check the selectors.');
            return;
        }

        console.log(`Found ${links.length} download links.`);

        // Extract version from the first link (e.g., QQ_3.2.25_260205_amd64_01.deb -> 3.2.25_260205)
        const firstLink = links[0];
        const fileName = path.basename(firstLink);
        // Match everything from QQ_ until the architecture part begins (assuming arch part is after the version_build part)
        // A more robust way: capture the first two segments after QQ_
        const versionMatch = fileName.match(/QQ_([0-9.]+_[0-9.]+)/);
        const version = versionMatch ? versionMatch[1] : 'unknown';
        console.log(`Extracted version: ${version}`);
        fs.writeFileSync('version.txt', version);

        // Generate links.md for GitHub Release body
        let linksMd = '### Official Download Links\n\n';
        linksMd += '| Filename | Official URL |\n';
        linksMd += '| :--- | :--- |\n';
        links.forEach(link => {
            const name = path.basename(link);
            linksMd += `| ${name} | [Download](${link}) |\n`;
        });
        fs.writeFileSync('links.md', linksMd);

        const downloadFolder = path.join(__dirname, 'downloads');
        if (!fs.existsSync(downloadFolder)) {
            fs.mkdirSync(downloadFolder);
        }

        for (const link of links) {
            await downloadFile(link, downloadFolder);
        }

        console.log('All downloads completed.');
    } catch (error) {
        console.error('An error occurred during execution:', error);
    } finally {
        await browser.close();
    }
})();
