# 构建本 fork 发布的 agent 镜像（二进制由 CI 交叉编译后 COPY 进来）
FROM alpine:3.21

WORKDIR /app

ARG TARGETOS
ARG TARGETARCH

COPY --chmod=755 komari-agent-${TARGETOS}-${TARGETARCH} /app/komari-agent

RUN touch /.komari-agent-container

ENTRYPOINT ["/app/komari-agent"]
CMD ["--help"]
