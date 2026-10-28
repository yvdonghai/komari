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

## Agent 安装（自己的镜像）

镜像：`ghcr.io/yvdonghai/komari-agent:latest`（Actions 工作流 `Publish Agent Docker Image` 构建）。

面板添加节点拿到 Token 后：

```bash
# Docker（默认，推荐）
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
  sh -s -- -e https://你的面板地址:25774 -t <节点Token>

# 或 compose
export AGENT_ENDPOINT=https://你的面板:25774
export AGENT_TOKEN=<节点Token>
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/docker-compose.agent.yml -o docker-compose.agent.yml
docker compose -f docker-compose.agent.yml up -d

# 宿主机二进制（可选）
curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
  sh -s -- --binary -e https://你的面板:25774 -t <节点Token>
```

首次使用请先在仓库 Actions 里手动跑一次 **Publish Agent Docker Image**，或合并含 `agent/` 的改动到 `main`。