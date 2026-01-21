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

### Wine 版本

本项目提供两个 Wine 版本：

| Wine 版本 | 说明 | 标签前缀 |
|----------|------|---------|
| Wine 11 (Stable) | 最新稳定版，使用 WineHQ stable 分支 | `wine_latest`, `wine_ubuntu-*`, `wine_nvidia-*` |
| Wine 10 | 历史版本，使用 winehq-stable=10.0.0 历史包 | `wine_ubuntu-wine10*`, `wine_nvidia-wine10*` |

### 完整版 (Dockerfile)

完整功能版本，适合运行 Windows 应用程序。

#### Wine 11 (稳定版)

| 镜像标签 | 描述 |
|---------|------|
| `wine_latest` | Wine 11 基础镜像 (win64) |
| `wine_ubuntu-win32` | Wine 11 + win32 架构 |
| `wine_ubuntu-py311` | Wine 11 + Python 3.11 (win64) |
| `wine_ubuntu-win32-py311` | Wine 11 + Python 3.11 (win32) |
| `wine_nvidia` | Wine 11 + NVIDIA GPU 支持 (win64) |
| `wine_nvidia-win32` | Wine 11 + NVIDIA GPU (win32) |
| `wine_nvidia-py311` | Wine 11 + Python 3.11 + NVIDIA GPU (win64) |
| `wine_nvidia-win32-py311` | Wine 11 + Python 3.11 + NVIDIA GPU (win32) |

#### Wine 10 (历史版本)

| 镜像标签 | 描述 |
|---------|------|
| `wine_ubuntu-wine10` | Wine 10 基础镜像 (win64) |
| `wine_ubuntu-wine10-win32` | Wine 10 + win32 架构 |
| `wine_ubuntu-wine10-py311` | Wine 10 + Python 3.11 (win64) |
| `wine_ubuntu-wine10-win32-py311` | Wine 10 + Python 3.11 (win32) |
| `wine_nvidia-wine10` | Wine 10 + NVIDIA GPU 支持 (win64) |
| `wine_nvidia-wine10-win32` | Wine 10 + NVIDIA GPU (win32) |
| `wine_nvidia-wine10-py311` | Wine 10 + Python 3.11 + NVIDIA GPU (win64) |
| `wine_nvidia-wine10-win32-py311` | Wine 10 + Python 3.11 + NVIDIA GPU (win32) |

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
# Wine 11 完整版（推荐）
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# Wine 10 历史版本
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-wine10

# NVIDIA GPU 版本
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_nvidia

# Python 版本
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-py311

# 精简版（推荐开发/打包环境）
docker pull registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_dev
```

### 运行容器

```bash
# Wine 11 基础运行
docker run --rm registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# Wine 10 基础运行
docker run --rm registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-wine10

# 挂载目录
docker run --rm -v $(pwd):/workspace registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_latest

# GPU 支持（需要 NVIDIA Container Toolkit）
docker run --rm --gpus all registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_nvidia

# GPU + Wine 10
docker run --rm --gpus all registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_nvidia-wine10

# Python 环境
docker run --rm registry.cn-hangzhou.aliyuncs.com/tekintian/dev:wine_ubuntu-py311 wine python
```

## 🔨 构建镜像

### 使用 Makefile

```bash
# 查看所有可用目标
make help

# Wine 11 构建目标
make build                        # 构建 Wine 11 基础镜像
make build-ubuntu-py311          # 构建 Wine 11 + Python 3.11
make build-nvidia                # 构建 Wine 11 + NVIDIA GPU

# Wine 10 构建目标
make build-ubuntu-wine10         # 构建 Wine 10 基础镜像
make build-ubuntu-wine10-py311   # 构建 Wine 10 + Python 3.11
make build-nvidia-wine10         # 构建 Wine 10 + NVIDIA GPU

# 使用国内镜像加速（推荐）
make build-cn
```

### 使用 Docker 命令

```bash
# 完整版 - Wine 11
docker buildx build -t wine:latest --build-arg USE_CN_MIRRORS=1 .

# 完整版 - Wine 10
docker buildx build --build-arg WINE_VERSION=10.0.0.0~jammy-1 -t wine:wine10 .

# 精简版 - Wine 11
docker buildx build -f Dockerfile.minimal -t wine:dev --build-arg USE_CN_MIRRORS=1 .

# 精简版 - Wine 10
docker buildx build -f Dockerfile.minimal \
  --build-arg WINE_VERSION=10.0.0.0~jammy-1 \
  -t wine:dev-wine10 .
```

### CI/CD 自动构建

项目提供两个独立的 GitHub Actions 工作流：

- **deploy.yml** - 构建完整版镜像（Wine 11 和 Wine 10）
- **deploy-minimal.yml** - 构建精简版镜像（Wine 11 和 Wine 10）

当推送到 main 分支或创建 Release 时，会自动触发构建。也可通过 GitHub UI 手动触发。

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
| `WINE_VERSION` | (未指定) | Wine 版本（如 10.0.0.0~jammy-1）|
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
# Wine 11 构建目标
make build                    # 构建基础镜像
make build-cn                 # 使用国内镜像构建
make build-ubuntu-py311       # 构建 Python 版本
make build-nvidia             # 构建 NVIDIA 版本

# Wine 10 构建目标
make build-ubuntu-wine10      # 构建 Wine 10 基础镜像
make build-ubuntu-wine10-py311  # 构建 Wine 10 + Python 3.11
make build-nvidia-wine10      # 构建 Wine 10 + NVIDIA GPU

# 运行目标
make run                     # 运行基础镜像
make run-ubuntu-py311         # 运行 Python 版本
make run-nvidia              # 运行 NVIDIA 版本
make run-ubuntu-wine10       # 运行 Wine 10 基础镜像
make run-nvidia-wine10       # 运行 Wine 10 + NVIDIA GPU

# 清理目标
make clean                   # 删除所有镜像
make clean-cache             # 清理构建缓存
make help                    # 显示帮助信息
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

# 使用指定历史版本（如 Wine 10）
docker buildx build --build-arg WINE_BRANCH=stable --build-arg WINE_VERSION=10.0.0.0~jammy-1 -t wine:wine10 .
```

### 自定义 Python 版本

```bash
# Python 3.12
docker buildx build --build-arg PYTHON_VERSION=3.12.0 -t wine:py312 .
```

## 📚 文档

- [BUILD_CN.md](BUILD_CN.md) - 国内镜像加速使用说明
- [BUILD_VARIANTS.md](BUILD_VARIANTS.md) - 完整版和精简版详细对比

### 查看 Wine 官方版本

可以通过以下方式查看 WineHQ 官方仓库中的可用版本：

```bash
# 查看 stable 分支的最新版本
curl -s https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main/binary-amd64/Packages | \
  grep "winehq-stable_" | grep "Filename" | tail -1

# 查看 staging 分支的最新版本
curl -s https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main/binary-amd64/Packages | \
  grep "winehq-staging_" | grep "Filename" | tail -1

# 查看所有可用的 stable 版本
curl -s https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main/binary-amd64/Packages | \
  grep "Package: winehq-stable" -A 1 | grep "Filename"
```

**版本号格式说明**：
- `11.0.0.0~jammy-1` - Wine 11 stable 版本
- `10.0.0.0~jammy-1` - Wine 10 stable 版本
- `9.0.0.0~jammy-1` - Wine 9 stable 版本

版本号遵循 WineHQ 官方格式：`主版本号.次版本号.修订号.补丁号~发行版代号-修订`

**相关链接**：
- [WineHQ 包仓库](https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/main/binary-amd64/Packages)
- [WineHQ 官网](https://www.winehq.org/)

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
