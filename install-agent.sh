#!/bin/sh
# 为本 fork 面板 (yvdonghai/komari) 安装「自己的」agent。
#
# 默认：Docker 部署自己的镜像 ghcr.io/yvdonghai/komari-agent
# 可选：--binary 走宿主机二进制（仍下载上游 agent release）
#
# 用法:
#   # Docker（推荐）
#   curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
#     sh -s -- -e https://面板:25774 -t <Token>
#
#   # 宿主机二进制
#   curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
#     sh -s -- --binary -e https://面板:25774 -t <Token>

set -eu

ENDPOINT=""
TOKEN=""
AUTO_KEY=""
MODE="docker"
IMAGE="${AGENT_IMAGE:-ghcr.io/yvdonghai/komari-agent:latest}"
NAME="${AGENT_CONTAINER_NAME:-komari-agent}"
PASSTHROUGH=""

while [ $# -gt 0 ]; do
  case "$1" in
    -e|--endpoint)
      ENDPOINT="$2"
      PASSTHROUGH="$PASSTHROUGH -e $2"
      shift 2
      ;;
    -t|--token)
      TOKEN="$2"
      PASSTHROUGH="$PASSTHROUGH -t $2"
      shift 2
      ;;
    --auto-discovery)
      AUTO_KEY="$2"
      PASSTHROUGH="$PASSTHROUGH --auto-discovery $2"
      shift 2
      ;;
    --docker)
      MODE="docker"
      shift
      ;;
    --binary)
      MODE="binary"
      shift
      ;;
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --name)
      NAME="$2"
      shift 2
      ;;
    --install-dir|--install-service-name|--install-ghproxy|--install-version)
      PASSTHROUGH="$PASSTHROUGH $1 $2"
      shift 2
      ;;
    --install-no-mirror|--disable-web-ssh|--disable-auto-update)
      PASSTHROUGH="$PASSTHROUGH $1"
      shift
      ;;
    *)
      PASSTHROUGH="$PASSTHROUGH $1"
      shift
      ;;
  esac
done

PASSTHROUGH="${PASSTHROUGH# }"

if [ -z "$ENDPOINT" ]; then
  echo "[ERROR] 必须提供面板地址: -e https://your-panel:25774" >&2
  exit 1
fi
if [ -z "$TOKEN" ] && [ -z "$AUTO_KEY" ]; then
  echo "[ERROR] 必须提供节点 Token (-t) 或自动发现密钥 (--auto-discovery)" >&2
  exit 1
fi

case " $PASSTHROUGH " in
  *" --disable-web-ssh "*) ;;
  *) PASSTHROUGH="$PASSTHROUGH --disable-web-ssh" ;;
esac

install_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[ERROR] 未找到 docker，请先安装 Docker，或改用 --binary" >&2
    exit 1
  fi

  echo "[INFO] 使用自己的 agent 镜像: $IMAGE"
  echo "[INFO] 面板: $ENDPOINT"

  if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
    echo "[INFO] 已存在容器 $NAME，先移除..."
    docker rm -f "$NAME" >/dev/null
  fi

  # shellcheck disable=SC2086
  docker run -d \
    --name "$NAME" \
    --restart unless-stopped \
    --network host \
    -e AGENT_ENDPOINT="$ENDPOINT" \
    ${TOKEN:+-e AGENT_TOKEN="$TOKEN"} \
    ${AUTO_KEY:+-e AGENT_AUTO_DISCOVERY_KEY="$AUTO_KEY"} \
    -e AGENT_DISABLE_WEB_SSH=true \
    -e AGENT_DISABLE_AUTO_UPDATE=true \
    "$IMAGE"

  echo "[OK] agent 容器已启动: $NAME"
  docker ps --filter "name=^/${NAME}$"
}

install_binary() {
  AGENT_INSTALL_URL="${AGENT_INSTALL_URL:-https://raw.githubusercontent.com/komari-monitor/komari-agent/main/install.sh}"
  echo "[INFO] 面板: $ENDPOINT"
  echo "[INFO] 拉取 agent 安装脚本: $AGENT_INSTALL_URL"
  # shellcheck disable=SC2086
  curl -fsSL "$AGENT_INSTALL_URL" | sh -s -- $PASSTHROUGH
}

case "$MODE" in
  docker) install_docker ;;
  binary) install_binary ;;
  *)
    echo "[ERROR] 未知模式: $MODE" >&2
    exit 1
    ;;
esac
