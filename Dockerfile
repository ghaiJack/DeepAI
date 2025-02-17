# 使用多阶段构建
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的构建工具
RUN apk add --no-cache git

# 复制源代码
COPY . .

# 下载依赖
RUN go mod tidy

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -o deepai

# 使用轻量级基础镜像
FROM alpine:latest

# 安装必要的运行时依赖
RUN apk add --no-cache ca-certificates tzdata wget

# 创建非root用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 创建必要的目录
RUN mkdir -p /app/conf /app/logs && \
    chown -R appuser:appgroup /app

# 从builder阶段复制编译好的应用
COPY --from=builder /app/deepai /app/
COPY --from=builder /app/config-example.yaml /app/conf/config.yaml

# 设置工作目录
WORKDIR /app

# 设置文件权限
RUN chmod 755 /app/deepai && \
    chmod 644 /app/conf/config.yaml && \
    chown -R appuser:appgroup /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8888

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8888/health || exit 1

# 启动应用
CMD ["/app/deepai"]
