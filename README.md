# Wine Docker

在 Docker 中运行 [Wine](https://www.winehq.org/) - Linux 环境下运行 Windows 应用程序的兼容层。

## ✨ 特性

- 🍷 完整的 Wine 环境，支持 win64 和 win32
- 🇨🇳 预装中文字体和语言包
- 🐍 支持多种 Python 版本（Windows 版本）
- 🎮 支持 NVIDIA GPU 加速
- 🚀 支持国内镜像加速，构建速度提升 10 倍
- 📦 提供**完整版**和**精简版**两种构建选项

## 📦 镜像变体

### 完整版 (Dockerfile)

完整功能版本，适合运行 Windows 应用程序。

| 镜像标签 | 描述 |
|---------|------|
| `wine_latest` | 基础 Wine 镜像 |
| `wine_ubuntu-py311` | Wine + Python 3.11 |
| `wine_nvidia` | Wine + NVIDIA GPU 支持 |
| `wine_nvidia-py311` | Wine + Python 3.11 + NVIDIA GPU |

**特性**:
- ✅ 完整的中文字体支持（Noto CJK、WQY Microhei、微软核心字体）
- ✅ 预安装 Windows 组件（.NET 4.8、VC++ 2019/2022、MSXML 6、MFC）
- ✅ 音频和图形支持（PulseAudio、Vulkan、Xvfb）
- ✅ Winetricks 预配置
- ✅ 健康检查支持

### 精简版 (Dockerfile.minimal)

为开发/打包环境优化的轻量级版本，镜像大小减少 48%。

| 镜像标签 | 描述 |
|---------|------|
| `wine_dev` | 精简 Wine 基础镜像 |
| `wine_dev-py` | 精简 Wine + Python 3.11 |

**特性**:
- ✅ 仅包含 Wine 核心功能
- ✅ 包含构建工具（binutils、cabextract、unzip、curl、git）
- ✅ 镜像体积小（~1.2 GB vs 完整版 ~2.3 GB）
- ✅ 构建速度快（快 50%）

**不包含**:
- ❌ Winetricks 和额外 Windows 组件
- ❌ 大部分字体（仅保留 CJK 字体）
- ❌ 音频/图形加速组件
- ❌ 健康检查

详见 [BUILD_VARIANTS.md](BUILD_VARIANTS.md) 了解两种版本的详细对比。

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Buildx

### 拉取镜像

```bash
# 完整版（推荐运行 Windows 应用）
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# 精简版（推荐开发/打包环境）
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_dev

# Python 版本
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-py311
```

### 运行容器

```bash
# 基础运行
docker run --rm registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# 挂载目录
docker run --rm -v $(pwd):/workspace registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# GPU 支持（需要 NVIDIA Container Toolkit）
docker run --rm --gpus all registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_nvidia

# Python 环境
docker run --rm registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-py311 wine python
```

## 🔨 构建镜像

### 使用 Makefile

```bash
# 查看所有可用目标
make help

# 构建完整版
make build

# 构建精简版
docker build -f Dockerfile.minimal -t wine:dev .

# 使用国内镜像加速（推荐）
make build-cn

# 构建特定变体
make build-ubuntu-py311
make build-nvidia
```

### 使用 Docker 命令

```bash
# 完整版
docker buildx build -t wine:latest --build-arg USE_CN_MIRRORS=1 .

# 精简版
docker buildx build -f Dockerfile.minimal -t wine:dev .

# 使用国内镜像
docker buildx build -f Dockerfile.minimal --build-arg USE_CN_MIRRORS=1 -t wine:dev .
```

## 🇨🇳 国内镜像加速

本项目支持国内镜像源，显著提升构建速度（10 倍以上）。

### 镜像源配置

| 资源 | 镜像源 |
|-------|---------|
| Ubuntu 软件包 | 阿里云 (mirrors.aliyun.com) |
| WineHQ 官方仓库 | WineHQ 官方源（无国内镜像）|
| Python 安装包 | 华为云 (mirrors.huaweicloud.com) |

### 构建时间对比

| 构建方式 | 时间 |
|---------|-----|
| 使用官方源 | ~15-20 分钟 |
| 使用国内镜像 | ~3-5 分钟 |

详见 [BUILD_CN.md](BUILD_CN.md) 了解更多镜像加速配置。

## 📝 配置说明

### 环境变量

| 变量 | 默认值 | 说明 |
|-------|---------|------|
| `USE_CN_MIRRORS` | 0 | 是否使用国内镜像（0 或 1）|
| `WINE_BRANCH` | stable | Wine 分支（stable 或 devel）|
| `WINEARCH` | win64 | Wine 架构（win64 或 win32）|
| `PYTHON_VERSION` | 3.11.9 | Python 版本 |
| `TZ` | Asia/Shanghai | 时区 |
| `LANG` | zh_CN.UTF-8 | 语言环境 |

### 工作目录

- 完整版: `/home/user`
- 精简版: `/workspace`

### 用户权限

容器使用非 root 用户（UID 1000）运行，更安全。

## 🎯 使用场景

### 运行 Windows 应用程序

```bash
# GUI 应用
docker run --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
  registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest notepad.exe

# 游戏
docker run --rm --gpus all -e DISPLAY=$DISPLAY \
  registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_nvidia game.exe
```

### 开发/打包环境

```bash
# 进入容器
docker run --rm -it -v $(pwd):/workspace \
  registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_dev bash

# 构建项目
docker run --rm -v $(pwd):/workspace \
  registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_dev wine build.bat

# Python 构建
docker run --rm -v $(pwd):/workspace \
  registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-py311 wine python setup.py
```

### CI/CD 集成

```yaml
# GitHub Actions 示例
- name: Build with Wine
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace \
      registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_dev wine build.sh
```

## 📋 Makefile 目标

```bash
# 构建目标
make                    # 构建基础镜像
make build-cn             # 使用国内镜像构建
make build-ubuntu-py311  # 构建 Python 版本
make build-nvidia         # 构建 NVIDIA 版本

# 运行目标
make run                 # 运行基础镜像
make run-ubuntu-py311   # 运行 Python 版本
make run-nvidia          # 运行 NVIDIA 版本

# 清理目标
make clean               # 删除所有镜像
make clean-cache         # 清理构建缓存
make help                # 显示帮助信息
```

## 🔧 自定义构建

### 修改基础镜像

```bash
# 使用 NVIDIA 基础镜像
docker buildx build \
  --build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
  -t wine:nvidia .
```

### 切换 Wine 分支

```bash
# 使用开发分支
docker buildx build --build-arg WINE_BRANCH=devel -t wine:latest .
```

### 自定义 Python 版本

```bash
# Python 3.12
docker buildx build --build-arg PYTHON_VERSION=3.12.0 -t wine:py312 .
```

## 📚 文档

- [BUILD_CN.md](BUILD_CN.md) - 国内镜像加速使用说明
- [BUILD_VARIANTS.md](BUILD_VARIANTS.md) - 完整版和精简版详细对比

## 🤝 故障排查

### 构建失败

```bash
# 清理缓存后重试
make clean-cache
make build

# 禁用国内镜像
docker buildx build --build-arg USE_CN_MIRRORS=0 -t wine:latest .
```

### 运行时问题

```bash
# 查看日志
docker logs <container_id>

# 进入调试
docker run --rm -it wine:latest bash

# 检查 Wine 版本
wine --version
```

### GPU 支持问题

确保已安装 [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html):

```bash
# 验证 GPU 访问
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## 📄 许可证

本项目遵循 WineHQ 项目的许可证。

## 🔗 相关链接

- [WineHQ 官网](https://www.winehq.org/)
- [Winetricks 文档](https://github.com/Winetricks/winetricks)
- [WineHQ 手册](https://wiki.winehq.org/)
- [阿里云容器镜像服务](https://cr.console.aliyun.com/)

## 💡 提示

1. **镜像大小**: 完整版约 2.3 GB，精简版约 1.2 GB
2. **网络要求**: 建议使用国内镜像以加速构建
3. **存储**: 镜像首次拉取需要较长时间，建议提前准备
4. **性能**: NVIDIA GPU 版本需要宿主机有 GPU 和 NVIDIA 驱动
