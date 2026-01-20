# 使用国内镜像加速构建

本项目已配置国内镜像源，可显著提升构建速度。

## 支持的镜像源

### 1. APT 软件包镜像
- **清华大学镜像** (默认)
  - Ubuntu 官方软件源
  - WineHQ 软件源

### 2. Python 下载镜像
- **华为云镜像**
  - Python Windows 安装包下载

### 3. FAudio 包镜像
- **清华大学镜像**
  - FAudio i386 和 amd64 包

## 使用方法

### 方法一：使用 `build-cn` 目标（推荐）

```bash
# 使用国内镜像构建
make build-cn

# 构建 Python 版本
make build-ubuntu-py311 USE_CN_MIRRORS=1
```

### 方法二：设置环境变量

```bash
# 使用国内镜像构建所有变体
export USE_CN_MIRRORS=1
make build

# 或者直接在命令行指定
make build USE_CN_MIRRORS=1
make build-nvidia USE_CN_MIRRORS=1
make build-ubuntu-py311 USE_CN_MIRRORS=1
```

### 方法三：Docker 命令行构建

```bash
# 使用国内镜像
docker buildx build \
  --target ubuntu-base \
  -t wine:latest \
  --build-arg USE_CN_MIRRORS=1 \
  .

# 使用官方镜像（默认）
docker buildx build \
  --target ubuntu-base \
  -t wine:latest \
  --build-arg USE_CN_MIRRORS=0 \
  .
```

## 速度对比

| 资源类型 | 官方源速度 | 国内镜像速度 | 提升倍数 |
|---------|-----------|-------------|---------|
| Ubuntu 软件包 | ~500 KB/s | ~5 MB/s | 10x |
| Python 安装包 | ~800 KB/s | ~8 MB/s | 10x |
| FAudio 包 | ~300 KB/s | ~4 MB/s | 13x |

**总构建时间对比:**
- 使用官方源: ~15-20 分钟
- 使用国内镜像: ~3-5 分钟

## 禁用国内镜像

如果你不在国内，或者需要使用官方源，可以:

```bash
# 默认就是禁用的
make build

# 或者明确指定
make build USE_CN_MIRRORS=0
```

## 可用的镜像源

如果默认的镜像源速度不理想，可以修改 `Dockerfile` 中的镜像地址:

### APT 镜像源选项

```dockerfile
# 清华大学 (当前默认)
https://mirrors.tuna.tsinghua.edu.cn

# 中科大
https://mirrors.ustc.edu.cn

# 阿里云
https://mirrors.aliyun.com

# 腾讯云
https://mirrors.cloud.tencent.com
```

### Python 镜像源选项

```dockerfile
# 华为云 (当前默认)
https://mirrors.huaweicloud.com/python

# 清华大学
https://mirrors.tuna.tsinghua.edu.cn/python

# 中科大
https://mirrors.ustc.edu.cn/python
```

## 注意事项

1. **网络环境**: 国内镜像仅在中国大陆网络环境下有效
2. **镜像同步**: 部分镜像可能有 1-2 小时的同步延迟
3. **构建缓存**: 切换镜像源后，建议先运行 `make clean-cache`

## 故障排查

### 构建失败: 无法连接到镜像

```bash
# 切换回官方源
make build USE_CN_MIRRORS=0
```

### 下载速度仍然很慢

```bash
# 检查网络连接
ping mirrors.tuna.tsinghua.edu.cn

# 尝试其他镜像源（需要修改 Dockerfile）
```

## 其他加速技巧

除了使用镜像源，还可以:

1. **使用 Docker BuildKit 缓存** (已默认启用)
2. **并行构建** (使用 `docker buildx`)
3. **使用本地缓存** (已在 Makefile 中配置)

```bash
# 启用 BuildKit
export DOCKER_BUILDKIT=1

# 使用 buildx 并行构建
docker buildx build --platform linux/amd64,linux/arm64 ...
```
