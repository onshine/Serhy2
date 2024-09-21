#!/bin/sh

# 设置端口和密码
SERVER_PORT=32710
PASSWORD="ad9b7bee-f06b-4f8a-8b1b-b1a5830c5127"
HYSTERIA_DIR="/usr/home/hysteria"

# 确保使用 sudo 执行脚本
if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 sudo 执行此脚本"
  exit 1
fi

# 创建目录并确保有正确的权限
mkdir -p $HYSTERIA_DIR
chown $(whoami) $HYSTERIA_DIR
chmod 755 $HYSTERIA_DIR

# 安装必要工具 (pkg 前需要先 bootstrap，确保 pkg 管理器正常工作)
if ! command -v pkg >/dev/null 2>&1; then
  echo "正在引导 pkg 管理器..."
  /usr/sbin/pkg bootstrap -y
fi

pkg install -y wget openssl

# 下载 Hysteria2 二进制文件
ARCH=$(uname -m)
if [ "$ARCH" = "amd64" ]; then
    DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/download/v2.0.0/hysteria-freebsd-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/download/v2.0.0/hysteria-freebsd-arm64"
else
    echo "不支持的系统架构: $ARCH"
    exit 1
fi

# 下载 Hysteria2 并设置权限
wget -O $HYSTERIA_DIR/hysteria $DOWNLOAD_URL
chmod +x $HYSTERIA_DIR/hysteria

# 生成 TLS 证书和私钥
openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
    -keyout $HYSTERIA_DIR/server.key -out $HYSTERIA_DIR/server.crt \
    -subj "/CN=example.com" -days 3650

# 创建配置文件
cat << EOF > $HYSTERIA_DIR/config.yaml
listen: :$SERVER_PORT

tls:
  cert: $HYSTERIA_DIR/server.crt
  key: $HYSTERIA_DIR/server.key

auth:
  type: password
  password: "$PASSWORD"

fastOpen: true

masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com
    rewriteHost: true

transport:
  udp:
    hopInterval: 30s
EOF

# 启动 Hysteria2 服务
nohup $HYSTERIA_DIR/hysteria server -c $HYSTERIA_DIR/config.yaml >/dev/null 2>&1 &

echo "Hysteria2 安装完成并已启动"
echo "配置文件路径: $HYSTERIA_DIR/config.yaml"
