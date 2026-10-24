# Komari（yvdonghai fork）

自托管服务器监控面板的裁剪版：保留探针、通知、续费、GeoIP、备份；移除插件/主题市场/终端/文件管理/远程执行/OAuth。

## 面板安装

### Docker Compose（推荐）

```bash
mkdir -p komari && cd komari
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/docker-compose.yml -o docker-compose.yml
docker compose up -d
```

镜像：`ghcr.io/yvdonghai/komari:main`（由 Actions 在 `main` 推送时构建）。首次访问 `http://IP:25774` 完成安装向导。

### 一键二进制

```bash
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-komari.sh | bash
```

需要本仓库已有 Release 产物；若还没有 release，请先用 Docker 或源码构建。

### 源码 / 本地镜像

```bash
docker build -f Dockerfile.source -t ghcr.io/yvdonghai/komari:local .
```

## Agent 安装

面板添加节点后拿到 Token，在被监控机器执行：

```bash
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
  sh -s -- -e https://你的面板地址:25774 -t <节点Token>
```

Agent 二进制来自上游 `komari-monitor/komari-agent`（协议兼容）；脚本默认加上 `--disable-web-ssh`。
