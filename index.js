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
    });

    await context.addInitScript(() => {
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
    });

    const page = await context.newPage();
    let configLinks = [];

    // Capture the content of linuxConfig.js directly from the browser's response
    page.on('response', async (response) => {
        if (response.url().includes('linuxConfig.js')) {
            console.log(`Intercepted config from: ${response.url()}`);
            try {
                const text = await response.text();
                const jsonMatch = text.match(/var params=\s*(\{[\s\S]*?\});/);
                if (jsonMatch) {
                    const config = JSON.parse(jsonMatch[1]);
                    console.log(`Parsed version from intercepted config: ${config.version}`);

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
                    configLinks = extractUrls(config);
                }
            } catch (err) {
                console.error('Error parsing intercepted config:', err.message);
            }
        }
    });

    try {
        const timestamp = Date.now();
        const url = `https://im.qq.com/linuxqq/index.shtml?ga_t=${timestamp}`;

        console.log(`Navigating to ${url} (non-headless)...`);
        await page.goto(url, { waitUntil: 'networkidle' });

        // Wait for the response handler to catch the config
        console.log('Waiting for config capture...');
        for (let i = 0; i < 20; i++) {
            if (configLinks.length > 0) break;
            await page.waitForTimeout(500);
        }

        const links = configLinks.length > 0 ? configLinks : [];
        if (links.length === 0) {
            console.error('Failed to capture download links from linuxConfig.js. Verify the network interception.');
            return;
        }

        console.log(`Found ${links.length} download links.`);
        const versionMatch = path.basename(links[0]).match(/QQ_([0-9.]+_[0-9.]+)/);
        const version = versionMatch ? versionMatch[1] : 'unknown';
        console.log(`Extracted version: ${version}`);
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
