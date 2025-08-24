const {ipcRenderer} = require("electron");


function injectChiiDevtools(port) {
    const script = document.createElement("script");
    script.defer = "defer";
    script.src = `http://localhost:${port}/target.js`;
    document.head.append(script);
}


ipcRenderer.invoke("mojinran.chii_devtools.ready").then(port => {

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', async () => {
            injectChiiDevtools(port);
        });
    } else {
        injectChiiDevtools(port);
    }
    navigation.addEventListener("navigatesuccess", () => {
        injectChiiDevtools(port);
    });
});
