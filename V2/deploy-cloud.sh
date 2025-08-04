#!/bin/bash

# Review Gate V2 云部署脚本
# 用于在云服务上部署Review Gate V2

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}INFO: $1${NC}"; }
log_success() { echo -e "${GREEN}SUCCESS: $1${NC}"; }
log_warning() { echo -e "${YELLOW}WARNING: $1${NC}"; }
log_error() { echo -e "${RED}ERROR: $1${NC}"; }

echo -e "${BLUE}Review Gate V2 云部署脚本${NC}"
echo "=================================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    log_error "Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

log_success "Docker环境检查通过"

# 创建必要的目录
log_info "创建必要的目录..."
mkdir -p logs
mkdir -p /tmp/review-gate-v2

# 设置环境变量
export CLOUD_DEPLOYMENT=true
export PYTHONUNBUFFERED=1
export REVIEW_GATE_MODE=cloud_deployment
export LOG_LEVEL=INFO
export TEMP_DIR=/tmp

log_info "环境变量设置完成"

# 构建Docker镜像
log_info "构建Docker镜像..."
docker-compose build

if [ $? -eq 0 ]; then
    log_success "Docker镜像构建成功"
else
    log_error "Docker镜像构建失败"
    exit 1
fi

# 启动服务
log_info "启动Review Gate V2服务..."
docker-compose up -d

if [ $? -eq 0 ]; then
    log_success "服务启动成功"
else
    log_error "服务启动失败"
    exit 1
fi

# 等待服务启动
log_info "等待服务启动..."
sleep 10

# 检查服务状态
if docker-compose ps | grep -q "Up"; then
    log_success "Review Gate V2服务运行正常"
else
    log_error "服务启动异常，请检查日志"
    docker-compose logs
    exit 1
fi

# 显示服务信息
echo ""
log_success "部署完成！"
echo -e "${BLUE}服务信息:${NC}"
echo "  - 容器名称: review-gate-v2"
echo "  - 端口: 8000"
echo "  - 日志目录: ./logs"
echo ""
echo -e "${BLUE}常用命令:${NC}"
echo "  - 查看日志: docker-compose logs -f"
echo "  - 停止服务: docker-compose down"
echo "  - 重启服务: docker-compose restart"
echo "  - 更新服务: docker-compose up -d --build"
echo ""
log_success "Review Gate V2云部署完成！" 