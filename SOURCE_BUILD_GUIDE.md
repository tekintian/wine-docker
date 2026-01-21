# Wine 源码编译构建指南

本指南介绍如何使用源码编译方式构建指定版本的 Wine 镜像，特别适用于 Windows 应用开发打包场景（如 PyInstaller、NSIS 等）。

## 功能特点

- **指定版本编译**: 可以构建任意 Wine 版本（wine-9.0, wine-10.0, wine-11.0 等）
- **分支选择**: 支持 stable、devel、staging 三个分支
- **开发优化**: 针对应用打包场景优化，预装必要工具
- **Python 支持**: 可选择预装指定版本的 Windows Python

## 使用方式

### 方式一：使用 GitHub Actions（推荐）

通过 GitHub Actions 界面手动触发构建：

1. 进入 GitHub 仓库的 **Actions** 标签页
2. 选择 **Build Wine from Source (Dev/Build Environment)** 工作流
3. 点击 **Run workflow** 按钮
4. 填写以下参数：

| 参数 | 说明 | 示例 |
|------|------|------|
| Wine version | 要构建的 Wine 版本 | `wine-9.0`, `wine-10.0`, `wine-11.0` |
| Wine branch | Wine 分支 | `stable`, `devel`, `staging` |
| Python version | 要安装的 Python 版本 | `3.11.9`, `3.12.8` |
| Push image | 是否推送到镜像仓库 | `true` 或 `false` |
| Image tag suffix | 额外的标签后缀（可选） | `custom`, `test1` |

### 方式二：本地使用 Makefile 命令

#### 构建基础版本

```bash
# 构建默认版本 (wine-11.0 stable)
make build-source

# 构建指定版本
make build-source WINE_SOURCE_VERSION=wine-9.0

# 构建指定分支
make build-source WINE_SOURCE_VERSION=wine-10.0 WINE_BRANCH=devel

# 使用中国镜像加速
make build-source USE_CN_MIRRORS=1
```

#### 构建 Python 版本（推荐用于 PyInstaller）

```bash
# 构建带 Python 3.11.9 的版本
make build-source-py

# 指定 Wine 版本和 Python 版本
make build-source-py WINE_SOURCE_VERSION=wine-9.0 PYTHON_VERSION=3.12.8

# 完整示例
make build-source-py WINE_SOURCE_VERSION=wine-10.0 WINE_BRANCH=stable PYTHON_VERSION=3.11.9 USE_CN_MIRRORS=1
```

### 方式三：直接使用 Docker 命令

```bash
# 构建基础版本
docker buildx build \
  -f Dockerfile.source \
  --target ubuntu-base \
  -t wine-source:wine-11.0 \
  --build-arg WINE_SOURCE_VERSION=wine-11.0 \
  --build-arg WINE_BRANCH=stable \
  --load \
  .

# 构建 Python 版本
docker buildx build \
  -f Dockerfile.source \
  --target python \
  -t wine-source:wine-11.0-py3.11.9 \
  --build-arg WINE_SOURCE_VERSION=wine-11.0 \
  --build-arg WINE_BRANCH=stable \
  --build-arg PYTHON_VERSION=3.11.9 \
  --load \
  .
```

## 使用场景

### 1. PyInstaller 打包

```bash
# 启动容器
docker run --rm -v $(pwd):/workspace wine-source:wine-11.0-py3.11.9 bash

# 在容器内执行 PyInstaller
wine python -m pip install pyinstaller
wine pyinstaller --onefile your_app.py
```

### 2. NSIS 安装包制作

```bash
docker run --rm -v $(pwd):/workspace wine-source:wine-11.0 bash
# 下载并安装 NSIS
# 使用 makensis 命令制作安装包
```

### 3. 其他 Windows 工具构建

适用于需要特定 Wine 版本以确保兼容性的场景。

## 注意事项

1. **构建时间**: 从源码编译 Wine 需要 30-60 分钟，取决于机器性能
2. **镜像大小**: 源码编译的镜像会比预编译版本稍大
3. **分支选择**:
   - `stable`: 稳定版本，推荐用于生产环境
   - `devel`: 开发版本，包含最新功能
   - `staging`: 包含实验性补丁，可能有兼容性问题

## 版本可用性

可以通过以下方式查询可用的 Wine 版本：

```bash
# 访问 Wine 官方源码仓库
curl -s https://dl.winehq.org/wine/source/ | grep -o 'wine-[0-9.]*' | sort -V
```

或访问: https://dl.winehq.org/wine/source/

## 故障排查

### 构建失败

1. 检查 Wine 版本是否存在
2. 确认网络连接（源码下载较大）
3. 尝试使用中国镜像: `USE_CN_MIRRORS=1`

### 运行时问题

1. 验证 Wine 版本: `docker run --rm <image> wine --version`
2. 检查 Python 是否正确安装: `docker run --rm <image> wine python --version`

## 相关文件

- `.github/workflows/build-source.yml` - GitHub Actions 配置
- `Dockerfile.source` - 源码编译专用 Dockerfile
- `Dockerfile.minimal` - 官方预编译版本 Dockerfile
- `Makefile` - 本地构建命令
