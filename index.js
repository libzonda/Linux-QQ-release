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

async function getLinksFromConfig() {
    const timestamp = Date.now();
    const configUrl = `https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxConfig.js?vt=${timestamp}`;
    console.log(`Fetching config from ${configUrl}...`);

    const response = await axios.get(configUrl);
    const text = response.data;

    // Extract JSON part: look for "var params= { ... };"
    const jsonMatch = text.match(/var params=\s*(\{[\s\S]*?\});/);
    if (!jsonMatch) {
        throw new Error('Could not find params object in config file');
    }

    const config = JSON.parse(jsonMatch[1]);
    console.log('Successfully parsed linuxConfig.js JSON.');

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

    return extractUrls(config);
}

(async () => {
    try {
        const links = await getLinksFromConfig();

        if (links.length === 0) {
            console.log('No download links found in config API.');
            return;
        }

        console.log('Links found:', JSON.stringify(links, null, 2));
        console.log(`Using ${links.length} download links from config API.`);

        // Extract version from the first link (e.g., QQ_3.2.25_260205_amd64_01.deb -> 3.2.25_260205)
        const firstLink = links[0];
        const fileName = path.basename(firstLink);
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
        console.error('An error occurred during execution:', error.message);
    }
})();
