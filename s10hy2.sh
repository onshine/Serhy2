#!/bin/bash

# 端口和密码
SERVER_PORT=32710
PASSWORD="8866bae1-1167-4be9-a2b8-72e572a006ae"
HYSTERIA_DIR="/usr/home/hysteria"

# 创建目录
mkdir -p $HYSTERIA_DIR

# 检测系统架构并选择合适的 Hysteria2 二进制文件
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/download/v2.0.0/hysteria-linux-arm64"
elif [[ "$ARCH" == "armv7l" ]]; then
    DOWNLOAD_URL="https://github.com/apernet/hysteria/releases/download/v2.0.0/hysteria-linux-arm"
else
    echo "不支持的系统架构: $ARCH"
    exit 1
fi

# 下载 Hysteria2
curl -L -o $HYSTERIA_DIR/hysteria $DOWNLOAD_URL
chmod +x $HYSTERIA_DIR/hysteria

# 生成 TLS 证书和密钥
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
