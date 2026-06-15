#!/bin/bash
set -e

# 启动虚拟显示
Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
export DISPLAY=:99

# 等待 Xvfb 就绪
sleep 1

# 启动 x11vnc（默认密码 APP_PA126S74587SWOR1D，通过 VNC_PASSWORD 环境变量覆盖）
if [ -n "$VNC_PASSWORD" ]; then
    x11vnc -display :99 -rfbauth <(x11vnc -storepasswd "$VNC_PASSWORD" /tmp/vncpass && echo /tmp/vncpass) -forever -shared &
else
    x11vnc -display :99 -rfbauth <(x11vnc -storepasswd "APP_PA126S74587SWOR1D" /tmp/vncpass && echo /tmp/vncpass) -forever -shared &
fi

# 启动 noVNC（端口 6080 -> VNC 5900）
websockify --web=/usr/share/novnc 6080 localhost:5900 &

# 启动 FastAPI 后端
exec uvicorn main:app --host 0.0.0.0 --port 8000
