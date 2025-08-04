# Review Gate V2 云服务部署指南

## 概述

本指南介绍如何将Review Gate V2部署到云服务上，支持容器化部署和云环境优化。

## 云部署特性

### ✅ 已实现的云部署功能
- **容器化部署**：Docker和Docker Compose支持
- **环境变量配置**：灵活的云环境配置
- **音频功能适配**：云环境中自动禁用本地音频功能
- **文件路径适配**：支持容器化文件系统
- **健康检查**：自动健康监控
- **资源限制**：内存和CPU资源管理
- **日志管理**：结构化日志输出

### 🔧 云部署配置修改

#### 1. 环境变量配置
```bash
CLOUD_DEPLOYMENT=true
PYTHONUNBUFFERED=1
REVIEW_GATE_MODE=cloud_deployment
LOG_LEVEL=INFO
TEMP_DIR=/tmp
```

#### 2. MCP配置文件修改
- 更新了`mcp.json`以支持云部署路径
- 添加了云部署环境变量
- 配置了容器化路径

#### 3. 代码修改
- 添加了云部署环境检测
- 修改了音频处理逻辑（云环境中禁用）
- 优化了临时文件路径处理
- 添加了云环境日志配置

## 快速部署

### 方法1：使用部署脚本（推荐）

```bash
# 克隆项目
git clone https://github.com/LakshmanTurlapati/Review-Gate.git
cd Review-Gate/V2

# 运行云部署脚本
./deploy-cloud.sh
```

### 方法2：手动Docker部署

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 方法3：Kubernetes部署

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: review-gate-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: review-gate-v2
  template:
    metadata:
      labels:
        app: review-gate-v2
    spec:
      containers:
      - name: review-gate-v2
        image: review-gate-v2:latest
        ports:
        - containerPort: 8000
        env:
        - name: CLOUD_DEPLOYMENT
          value: "true"
        - name: PYTHONUNBUFFERED
          value: "1"
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
```

## 云服务提供商特定配置

### AWS部署

```bash
# 使用AWS ECS
aws ecs create-cluster --cluster-name review-gate-cluster
aws ecs register-task-definition --cli-input-json file://task-definition.json
aws ecs create-service --cluster review-gate-cluster --service-name review-gate-service --task-definition review-gate-v2
```

### Google Cloud部署

```bash
# 使用Google Cloud Run
gcloud run deploy review-gate-v2 \
  --image gcr.io/PROJECT_ID/review-gate-v2 \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Azure部署

```bash
# 使用Azure Container Instances
az container create \
  --resource-group myResourceGroup \
  --name review-gate-v2 \
  --image review-gate-v2:latest \
  --dns-name-label review-gate-v2 \
  --ports 8000
```

## 监控和日志

### 日志配置
```python
# 结构化日志配置
import structlog

structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)
```

### 健康检查
```bash
# 检查服务状态
curl http://localhost:8000/health

# 查看容器日志
docker-compose logs -f review-gate-v2
```

## 性能优化

### 资源限制
```yaml
# docker-compose.yml 资源配置
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
    reservations:
      memory: 256M
      cpus: '0.25'
```

### 扩展配置
```bash
# 水平扩展
docker-compose up -d --scale review-gate-v2=3

# 负载均衡配置
# 使用nginx或traefik进行负载均衡
```

## 安全配置

### 环境变量安全
```bash
# 使用.env文件管理敏感信息
echo "CLOUD_DEPLOYMENT=true" > .env
echo "LOG_LEVEL=INFO" >> .env
```

### 网络安全
```yaml
# 网络隔离配置
networks:
  review-gate-network:
    driver: bridge
    internal: true  # 内部网络
```

## 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   # 检查日志
   docker-compose logs review-gate-v2
   
   # 检查资源使用
   docker stats review-gate-v2
   ```

2. **音频功能问题**
   - 云环境中音频功能已自动禁用
   - 如需音频功能，请配置WebRTC或其他云音频服务

3. **文件权限问题**
   ```bash
   # 修复权限
   sudo chown -R 1000:1000 /tmp/review-gate-v2
   ```

### 调试模式
```bash
# 启用调试模式
export LOG_LEVEL=DEBUG
docker-compose up
```

## 更新和维护

### 更新服务
```bash
# 拉取最新代码
git pull origin main

# 重新构建和部署
docker-compose up -d --build
```

### 备份配置
```bash
# 备份配置文件
cp mcp.json mcp.json.backup
cp docker-compose.yml docker-compose.yml.backup
```

## 支持

如有问题，请查看：
- [GitHub Issues](https://github.com/LakshmanTurlapati/Review-Gate/issues)
- [项目文档](https://github.com/LakshmanTurlapati/Review-Gate)
- [云部署日志](./logs/)

---

**注意**：云部署版本已优化音频处理，在云环境中自动禁用本地音频功能以提高性能和稳定性。 