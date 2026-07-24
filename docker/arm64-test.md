# 在 Oracle ARM64 服务器上测试 PMHQ arm64

在真 aarch64 机器上端到端验证 arm64 版 pmhq（注入器 + `libpmhq.so`）+ llbot WebUI 登录/收发消息的流程。

> **为什么要真机**：本机（x86）用 Docker 跑 arm64 走的是 QEMU 用户态模拟，实测踩到三层坑，前两层可绕、第三层绕不过，所以端到端只能真机验证：
>
> 1. **VMProtect 加壳的 arm64 注入器 QEMU 加载不了**：`qemu-aarch64: /opt/pmhq: PT_LOAD with non-writable bss`。
>    - **可绕**：宿主机升级 QEMU 即可（旧版 qemu-user 拒绝 bss 落在不可写 PT_LOAD 段的 ELF，新版已修）：
>      ```bash
>      docker run --privileged --rm tonistiigi/binfmt:latest --install arm64
>      ```
>      注意这是宿主机 binfmt_misc 层面的全局改动，不是镜像层面；在 x86 上模拟 arm64 的机器都要先跑一次。
> 2. **QEMU 跑不起来 QQ（Electron/Chromium）**：`uncaught target signal 5 (Trace/breakpoint trap)` + `GPU process isn't usable. Goodbye.`（QQ 直接退出）。
>    - **可绕**：强制 ANGLE + SwiftShader 纯软件渲染，绕开 qemu 下 GPU 进程起不来的死结。已固化进 `startup.sh`：aarch64 下给 pmhq 加
>      `--qq-args "--use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader --disable-gpu-sandbox --disable-dev-shm-usage"`。
>      注意用的是 `--use-gl=angle --use-angle=swiftshader`；写成 `--use-gl=swiftshader` 会被这个 Electron 版本解析成 `gl=none` 而失败。
>      绕过后实测裸跑 QQ（不注入）在 qemu-arm64 下能稳定存活数分钟、进程树完整（主/渲染/NetworkService 都在）。
>      > 这套软件渲染参数在真 arm64 无头容器里同样需要（容器没真 GPU），`startup.sh` 的 `uname -m = aarch64` 判断对真机也生效，保留即可。
> 3. **注入后 QQ 必现 `signal 11` (SIGSEGV)**：pmhq LD_PRELOAD + `install_hook` 成功，但 QQ 在 hook 等待 `wrapper.node` 期间稳定崩溃（`[HOOK] Waiting for wrapper.node...` 数百 ms 后 `qemu: uncaught target signal 11`）。
>    - **绕不过**：这是 qemu-user 对 ARM64 inline hook（运行时改代码 / 自修改代码 SMC）的支持问题。对照实验：**QQ 裸跑（不注入 pmhq）在 qemu-arm64 下稳定存活 2min+、5 个进程、NetworkService 网络进程存活、日志无任何 crash**；一旦经 pmhq 注入则 8s 内 `signal 11` SIGSEGV。唯一变量是注入本身，故崩溃根因确定在注入/hook 层，非 QQ 本体。`debug: true` / `debug: false` 两种配置都实测过，均必现，与 debug 模式无关。Public 仓库只有 dist 二进制、改不了 hook 实现，本机也无法绕过。
>
> 真 arm64（Apple 芯片 Docker / arm64 云主机 / oracle）上三层坑都不存在（见文末表格：注入 + hook + 登录 + 发包全部 ✅）。所以 QEMU 只能验证到「QQ 本体能起来」，**注入之后的一切必须真机**。

---

## ⚠️ 重要：oracle 是生产服务器，务必隔离限量

`oracle`（`ubuntu@150.136.100.122`，Ampere aarch64，24 核 / 23 GB，Ubuntu 24.04）**同时跑着生产服务**（`luckylilliamanagerserver` 全家桶 + Postgres/Redis + new-api + sub2api 等 13 个容器）。在上面测试必须遵守：

1. **重活（反汇编 / 逆向 / 大二进制分析）一律本地做**。要分析 `wrapper.node`（~103 MB）就 `scp` 下来在本地用 capstone/objdump，**绝不在服务器上跑**（capstone detail 反汇编 ~2500 万条指令会吃大量内存）。
2. **用独立 compose project 名**（如 `pmhqarmtest`），别污染现有 stack。
3. **端口只绑 `127.0.0.1`**（`127.0.0.1:3080:3080`），靠 SSH 隧道访问，不公网暴露。
4. **用完立刻拆**：`docker compose -p pmhqarmtest down`，需要时连镜像/卷一起清。
5. 装的系统包（binutils / python3-capstone 等）测完 `apt remove` 掉。
6. 操作前后看一眼负载：`ssh oracle uptime`（24 核，load 到 ~20 才算满）。

> 教训：曾在这台 prod box 上部署测试栈并让后台 agent 起分析脚本，恰逢 3:26 一次（疑似内核自动升级）重启，把人吓到了。之后所有分析改为纯本地。

---

## 0. 前置条件

- 本机能 `ssh oracle`（免密）。若报 `Bad owner or permissions on ~/.ssh/config`（Windows 沙箱把 `CodexSandboxUsers`/未知 SID 加进了 ACL）：重建该文件并重置继承——
  ```powershell
  $cfg = "$env:USERPROFILE\.ssh\config"
  Copy-Item $cfg "$cfg.new" -Force; Remove-Item $cfg; Rename-Item "$cfg.new" "config"
  cmd /c "icacls `"$cfg`" /inheritance:r /grant:r `"$env:USERNAME:F`" `"SYSTEM:F`" `"Administrators:F`""
  ```
- 本机装好交叉编译链：`rustup target add aarch64-unknown-linux-gnu`、`cargo install cargo-zigbuild`、zig 0.13+ 在 PATH；VMProtect Ultimate 在 `D:\ProEnv\Tools\VMProtect Ultimate`（或设 `$env:VMP_DIR`）。
- auth token：`LuckyLillia.Bot/data/auth_token.txt`（compose 里作 `PMHQ_AUTH_TOKEN`）。
- WebUI 登录 token：`LuckyLillia.Bot/llbot_config/webui_token.txt`（默认 `123`）。

---

## 1. 本地交叉编译 arm64 pmhq

在 `PMHQ.Rust/`：

```powershell
# VMProtect 加壳版（生产形态，验证真机能加载加壳注入器）
.\build-linux.ps1 -Arch arm64
# 或调试版（不加壳，纯 plain，迭代 .so 改动时更快）
.\build-linux.ps1 -Arch arm64 -Plain
```

产物：`PMHQ.Rust/dist/pmhq-linux-arm64/{pmhq-linux-arm64, libpmhq.so}`。

> 注入器与 `.so` 靠 `PMHQ_BUILD_KEY` 做 challenge-response 绑定，**必须成对**。`build-linux.ps1` 一次跑里 key 一致；若手动分开 `cargo zigbuild -p pmhq-injector` / `-p pmhq-inject-dll`，要保证两次 `PMHQ_BUILD_KEY` 相同（都不设=同一 dev key 也行）。

拷到 docker 测试镜像的构建上下文：

```powershell
Copy-Item ..\PMHQ.Rust\dist\pmhq-linux-arm64\pmhq-linux-arm64 ..\PMHQ.Public\dist\linux-arm64\pmhq-linux-arm64 -Force
Copy-Item ..\PMHQ.Rust\dist\pmhq-linux-arm64\libpmhq.so        ..\PMHQ.Public\dist\linux-arm64\libpmhq.so        -Force
```

---

## 2. 把镜像弄到 oracle

**pmhq 镜像：在 oracle 上原生 build**（上传只需 ~9 MB dist，base 镜像 oracle 自己从 Hub 拉，省本机上行带宽）：

```powershell
# 传构建上下文（在 PMHQ.Public/ 下）
ssh oracle "mkdir -p ~/pmhq-arm-test/dist/linux-arm64 ~/pmhq-arm-test/docker ~/pmhq-arm-test/llbot_config"
scp dist\linux-arm64\pmhq-linux-arm64 dist\linux-arm64\libpmhq.so oracle:pmhq-arm-test/dist/linux-arm64/
scp docker\Dockerfile.test docker\startup.sh oracle:pmhq-arm-test/docker/
# 在 oracle 原生 build（native arm64，不走 QEMU）
ssh oracle "cd ~/pmhq-arm-test && docker build --platform linux/arm64 --build-arg PMHQ_VERSION=test -f docker/Dockerfile.test -t linyuchen/pmhq:test-arm ."
```

**llbot 镜像：本地 `docker save` → scp → oracle `docker load`**（Hub 上没有 `:test-arm` tag）：

```powershell
docker save linyuchen/llbot:test-arm -o $env:TEMP\llbot-test-arm.tar   # ~171 MB
scp $env:TEMP\llbot-test-arm.tar oracle:pmhq-arm-test/
ssh oracle "docker load -i ~/pmhq-arm-test/llbot-test-arm.tar && rm ~/pmhq-arm-test/llbot-test-arm.tar"
```

llbot 配置（复制本机现有 `LuckyLillia.Bot/llbot_config/` 的必要文件，**别传 logs**）：

```powershell
$b = "..\LuckyLillia.Bot\llbot_config"
scp $b\auth_token.txt $b\config_721011692.json $b\email_config.json $b\webui_token.txt oracle:pmhq-arm-test/llbot_config/
ssh oracle "mkdir -p ~/pmhq-arm-test/llbot_config/database"
scp $b\database\721011692.v3.db oracle:pmhq-arm-test/llbot_config/database/
```

---

## 3. compose 文件（端口绑 127.0.0.1）

`~/pmhq-arm-test/docker-compose.yml`（在 `LuckyLillia.Bot/docker-compose.yml` 基础上把 `"3080:3080"` 改成 `"127.0.0.1:3080:3080"`）：

```yaml
services:
  pmhq:
    image: linyuchen/pmhq:test-arm
    platform: linux/arm64
    privileged: true
    environment:
      - AUTO_LOGIN_QQ=721011692
      - PMHQ_AUTH_TOKEN=<见 LuckyLillia.Bot/data/auth_token.txt>
    volumes: [ "qq_volume:/root/.config/QQ" ]
    networks: [ app_network ]
    restart: unless-stopped
  llbot:
    image: linyuchen/llbot:test-arm
    platform: linux/arm64
    ports: [ "127.0.0.1:3080:3080" ]   # 只绑本地，靠 SSH 隧道访问
    environment: [ WEBUI_PORT=3080, PROTOCOL_MODE=pmhq, PMHQ_HOST=pmhq ]
    volumes: [ "./llbot_config:/app/llbot/data:rw" ]
    networks: [ app_network ]
    depends_on: [ pmhq ]
    restart: unless-stopped
volumes: { qq_volume: {} }
networks: { app_network: { driver: bridge } }
```

启动（**独立 project 名**）：

```powershell
scp $env:TEMP\docker-compose.oracle.yml oracle:pmhq-arm-test/docker-compose.yml
ssh oracle "cd ~/pmhq-arm-test && docker compose -p pmhqarmtest up -d"
```

---

## 4. 隧道 + 登录测试

```powershell
# 本地 3080 -> oracle 上容器的 3080
ssh -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 127.0.0.1:3080:localhost:3080 oracle
```

浏览器开 `http://localhost:3080`，token = `123`（`webui_token.txt`），扫码/快速登录 `721011692`。

---

## 5. 验证

```powershell
ssh oracle "docker ps --filter label=com.docker.compose.project=pmhqarmtest --format '{{.Names}} {{.Status}}'"
# 注入器加载 + hook 安装（真机应正常，无 QEMU 的 PT_LOAD 报错）
ssh oracle "docker logs pmhqarmtest-pmhq-1 2>&1 | grep -aiE 'Hooks installed|ARM64-HOOK|PT_LOAD' | tail"
# 登录后收发/主动发包
ssh oracle "docker logs pmhqarmtest-pmhq-1 2>&1 | grep -aiE 'ACTIVE-SEND|sendSso|KernelMsgService' | tail"
ssh oracle "docker logs pmhqarmtest-llbot-1 2>&1 | grep -aiE 'PMHQ send failed|error' | tail"
```

判据：`Hooks installed successfully`；登录后 `ACTIVE-SEND` 拿到 `KernelMsgService`、无 `sendSso ... TODO`；llbot 无 `PMHQ send failed`；dashboard/WebQQ 能出数据、能发消息。

---

## 6. 拆除 / 清理

```powershell
ssh oracle "cd ~/pmhq-arm-test && docker compose -p pmhqarmtest down"     # 停容器+网络，保留卷
# 彻底清（连卷+镜像+目录）：
ssh oracle "docker compose -p pmhqarmtest down -v; docker rmi linyuchen/pmhq:test-arm linyuchen/llbot:test-arm; rm -rf ~/pmhq-arm-test"
# 若装过分析工具：sudo apt-get remove -y binutils python3-capstone
```

本地隧道自己 `Ctrl-C`；后台起的话 `Get-NetTCPConnection -LocalPort 3080 -State Listen | %{ Stop-Process -Id $_.OwningProcess -Force }`。

---

## 7. 本次实测关键结论（QQ arm64 = 3.2.18-36497）

| 项 | arm64 真机状态 | QEMU（x86 模拟）状态 |
|---|---|---|
| VMProtect 注入器加载 | ✅ 正常 | 旧 QEMU ❌ `PT_LOAD non-writable bss`；升级 binfmt/qemu 后 ✅ 可加载 |
| QQ/Electron 运行 | ✅ 正常 | 默认 ❌ `signal 5` / GPU fatal；加软件渲染 `--qq-args` 后 ✅ 裸跑稳定存活 2min+、NetworkService 在 |
| LD_PRELOAD 注入 + ARM64 hook（send/recv/getMsgService） | ✅ 正常 | ❌ 必现 `signal 11` SIGSEGV（qemu SMC/inline-hook 限制，绕不过） |
| 登录（扫码/快速） | ✅ 正常 | ❌ 到不了这步（注入已崩） |
| 主动发包 `sendSso`（dashboard/群成员/历史/发消息） | ✅ 修复后正常 —— 见下 |
| 反检测：sign 检测位洗白（`anti_detect.rs` WASH）+ sign dump（`sign_dump.rs`） | ❌ **仅 x86-64**，arm64 未实现（见下） |
| 路径洗白（避 `Robot` needle，LD_PRELOAD 走 `/tmp/pmhq/`） | ✅ 跨平台生效 |

### 已修复：aarch64 `sendSso` 主动发包
`inject-dll/src/active_send/call.rs` 里 aarch64 分支原本是 `Err("aarch64 sendSso call: TODO ...")` 桩，导致一切主动发包 `code=-1`。AAPCS64 与 x86-64 的 4 参整数寄存器 ABI 一致（`this` 为 arg0、返回无 sret），已把 aarch64 并入 x86_64 分支用同样的 `transmute`+调用。

### 待做：arm64 反检测
`anti_detect.rs`（WASH，扫 `cmpl $1,[rip]` 洗检测位）和 `sign_dump.rs`（MSFSign x86 prologue needle）都是 x86-64 机器码专用，arm64 上 `WASH` 会报 `flag region not recognized; skip`、sign dump 找不到 needle。要在 arm64 生效需逆向 arm64 `wrapper.node`（**本地做**）：找 17 个检测 flag 簇 + arm64 读取/比较模式（多半 `ADRP+LDR` 取 flag → `CMP #1`），实现 arm64 版扫描/patch（把 `CMP #1` 立即数改成 `#2`，逻辑同 x86）。机制细节见 `LuckyLillia.Sign/docs/anti-detection.md`（注意其偏移是 3.2.28-48517，arm64 是 3.2.18-36497，需重新定位）。
