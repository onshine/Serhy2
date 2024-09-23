#!/bin/bash
# 安装 Hysteria2 的脚本
{
    echo -e "\e[92m" 
    echo "通往电脑的路不止一条，所有的信息都应该是免费的，打破电脑特权，在电脑上创造艺术和美，计算机将使生活更美好。"
    echo "    ______                   _____               _____         "
    echo "    ___  /_ _____  ____________  /______ ___________(_)______ _"
    echo "    __  __ \\__  / / /__  ___/_  __/_  _ \\__  ___/__  / _  __ \`/"
    echo "    _  / / /_  /_/ / _(__  ) / /_  /  __/_  /    _  /  / /_/ / "
    echo "    /_/ /_/ _\\__, /  /____/  \\__/  \\___/ /_/     /_/   \\__,_/  "
    echo "            /____/                                              "
    echo "                          ______          __________          "
    echo "    ______________ __________  /_____________  ____/         "
    echo "    __  ___/_  __ \\_  ___/__  //_/__  ___/______ \\           "
    echo "    _(__  ) / /_/ // /__  _  ,<   _(__  )  ____/ /        不要直连"
    echo "    /____/  \\____/ \\___/  /_/|_|  /____/  /_____/         没有售后"
    echo "缝合怪：天诚 原作者们：cmliu RealNeoMan、k0baya、eooce"
    echo "Cloudflare优选IP 订阅器，每天定时发布更新。"
    echo "欢迎加入交流群:https://t.me/cncomorg"
    echo -e "\e[0m"  
}

# 安装 Hysteria2 的主要函数
install_hysteria2() {
    # 定义端口和密码
    PORT="18328"
    PASSWORD="8866bae1-1167-4be9-a2b8-72e572a006ae"
    
    # 下载 Hysteria2
    wget -qO- https://github.com/HyNetwork/hysteria/releases/download/v2.0.0-beta.10/hysteria-linux-amd64.tar.gz | tar -zx -C /usr/local/bin

    # 创建配置文件目录
    mkdir -p /etc/hysteria

    # 生成配置文件
    cat <<EOF > /etc/hysteria/config.yaml
listen: :$PORT
protocol: udp
obfs:
  type: sni
  sni: bing.com
auth:
  password: $PASSWORD
EOF

    # 启动 Hysteria2
    nohup hysteria server -c /etc/hysteria/config.yaml > /dev/null 2>&1 &
    
    # 输出配置信息
    echo -e "\e[1;32mHysteria2 已成功安装并启动\e[0m"
    echo -e "\e[1;33m连接配置:\033[0m \e[1;32mhysteria2://$PASSWORD@$(curl -s ifconfig.me):$PORT/?sni=bing.com&protocol=udp\033[0m"
}

install_hysteria2
