const chii = require("chii");
const path = require("path");
const net = require("net");
const { BrowserWindow, ipcMain, session } = require("electron");
// const { slug } = require("../manifest.json");


// 获取空闲端口号
const port = (() => {
    const server = net.createServer().listen(0);
    const { port } = server.address();
    return server.close() && port;
})();


// 启动chii服务器
chii.start({ port });


// 把端口传给渲染进程
ipcMain.handle("mojinran.chii_devtools.ready", () => port);


// 打开DevTools
async function openDevTools(window) {
    const current_url = window.webContents.getURL();
    const targets_url = `http://localhost:${port}/targets`;
    const targets = await (await fetch(targets_url)).json();
    for (const target of targets.targets.reverse()) {
        if (target.url != current_url) continue;
        const devtools_params = `?ws=localhost:${port}/client/LiteLoader?target=${target.id}`;
        const devtools_url = `http://localhost:${port}/front_end/chii_app.html${devtools_params}`;
        const devtools_window = new BrowserWindow({
            autoHideMenuBar: true,
            webPreferences: {
                session: session.fromPartition('persist:pmhq')
            }
        });
        devtools_window.loadURL(devtools_url);
        console.log('open dev window')
        return devtools_window;
    }
}


// 创建窗口时触发
exports.onBrowserWindowCreated = (window) => {
    console.log('chii on window created')
    let devtools_window = null;
    window.webContents.on("before-input-event", async (event, input) => {
        console.log('chii keydown', input.key)
        if ((input.key == "F12" || (
            input.key == "I" && (process.platform === "darwin" ? input.meta : input.control) && input.shift)
        ) && input.type == "keyUp") {
            if (devtools_window) {
                devtools_window.close();
                devtools_window = null;
            }
            else {
                devtools_window = await openDevTools(window);
                devtools_window.on("closed", () => devtools_window = null);
            }
        }
    });
}
