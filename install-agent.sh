#!/bin/sh
# 为本 fork 面板 (yvdonghai/komari) 安装兼容的官方 komari-agent。
# Agent 协议与上游一致，二进制默认取自 komari-monitor/komari-agent releases。
#
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/yvdonghai/komari/main/install-agent.sh | \
#     sh -s -- -e https://面板地址:25774 -t <节点Token>
#
# 常用参数（会原样传给 agent）:
#   -e, --endpoint   面板地址（必填）
#   -t, --token      节点 Token（必填，或与自动发现密钥二选一）
#   --auto-discovery KEY  自动发现密钥（可选）
#
# 安装脚本自身参数:
#   --install-ghproxy URL   GitHub 代理前缀
#   --install-version TAG   指定 agent 版本（默认 latest）
#   --install-dir DIR       安装目录
#   --install-no-mirror     不走公共镜像加速

set -eu

ENDPOINT=""
TOKEN=""
AUTO_KEY=""
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

# 默认关闭 agent 侧网页终端/远程执行（本 fork 面板已移除对应能力）
case " $PASSTHROUGH " in
  *" --disable-web-ssh "*) ;;
  *) PASSTHROUGH="$PASSTHROUGH --disable-web-ssh" ;;
esac

AGENT_INSTALL_URL="${AGENT_INSTALL_URL:-https://raw.githubusercontent.com/komari-monitor/komari-agent/main/install.sh}"

echo "[INFO] 面板: $ENDPOINT"
echo "[INFO] 拉取官方 agent 安装脚本: $AGENT_INSTALL_URL"
# shellcheck disable=SC2086
curl -fsSL "$AGENT_INSTALL_URL" | sh -s -- $PASSTHROUGH
