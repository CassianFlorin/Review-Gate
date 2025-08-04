FROM python:3.11-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV REVIEW_GATE_MODE=cloud_deployment
ENV CLOUD_DEPLOYMENT=true
ENV LOG_LEVEL=INFO
ENV TEMP_DIR=/tmp

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    sox \
    libsox-fmt-all \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY review_gate_v2_mcp.py .
COPY requirements_simple.txt .
COPY mcp.json .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements_simple.txt

# 创建必要的目录
RUN mkdir -p /tmp /app/logs

# 设置权限
RUN chmod +x review_gate_v2_mcp.py

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# 暴露端口（如果需要HTTP接口）
EXPOSE 8000

# 启动命令
CMD ["python", "review_gate_v2_mcp.py"] 