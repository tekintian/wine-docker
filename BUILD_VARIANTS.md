# Dockerfile 变体说明

本项目提供了两个 Dockerfile 版本,针对不同使用场景进行了优化。

## 📋 Dockerfile 对比

| 特性 | Dockerfile (完整版) | Dockerfile.minimal (精简版) |
|-----|-------------------|-------------------------|
| **镜像大小** | ~2.3 GB | ~1.2 GB (减少 48%) |
| **构建时间** | ~3-5 分钟 | ~1.5-2 分钟 (快 50%) |
| **字体包** | fonts-noto-cjk, fonts-noto-cjk-extra, fonts-wqy-microhei, ttf-mscorefonts | fonts-noto-cjk |
| **Wine 组件** | win10, dotnet48, vcrun2019, vcrun2022, msxml6, mfc40, Gecko | 仅基础 Wine |
| **语言包** | language-pack-zh-hans | 无 |
| **音频支持** | pulseaudio | 无 |
| **GPU 支持** | libvulkan1:i386 | 无 |
| **Winetricks** | 已安装,预配置 | 未安装 |
| **开发工具** | binutils, cabextract, unzip, lsof, xvfb, winbind, gosu | binutils, cabextract, unzip, curl, git, gosu |
| **健康检查** | 有 | 无 |
| **元数据标签** | 完整 OCI 标签 | 基本标签 |
| **适用场景** | 运行 Windows 应用程序 | 构建/打包环境 |

## 🎯 适用场景

### 完整版 (Dockerfile)

**适用场景:**
- ✅ 运行 Windows GUI 应用程序
- ✅ 游戏环境 (需要音频、图形、.NET)
- ✅ 多媒体应用 (需要编解码器)
- ✅ 完整的中文环境 (需要字体、语言包)
- ✅ 需要特定 Windows 组件 (MSXML, MFC, .NET)

**示例用例:**
```bash
# 运行 Windows 应用
docker run --rm -e DISPLAY aoirint/wine:latest notepad.exe

# 运行游戏
docker run --rm --gpus all -e DISPLAY aoirint/wine:nvidia game.exe

# 运行 Python 应用
docker run --rm aoirint/wine:ubuntu-py311 python script.py
```

### 精简版 (Dockerfile.minimal)

**适用场景:**
- ✅ 构建环境 (构建 Windows 程序)
- ✅ 打包环境 (打包 Windows 安装包)
- ✅ CI/CD 环境 (快速构建和测试)
- ✅ 只需要 Wine 核心功能
- ✅ 不需要 GUI、音频、游戏支持

**示例用例:**
```bash
# 构建环境 - 进入容器执行构建
docker run --rm -v $(pwd):/workspace aoirint/wine:latest bash

# 使用精简版构建
docker build -f Dockerfile.minimal -t wine:dev .

# 运行构建命令
docker run --rm -v $(pwd):/workspace wine:dev wine build.bat

# 使用 Python 构建
docker run --rm -v $(pwd):/workspace wine:dev python build.py
```

## 📦 组件差异详解

### 完整版包含的组件

#### 运行时组件
- **FAudio**: 音频支持
- **Vulkan**: GPU 图形加速
- **PulseAudio**: Linux 音频系统
- **Xvfb**: 虚拟显示服务器

#### Windows 组件
- **.NET Framework 4.8**: .NET 应用支持
- **Visual C++ Redistributable 2019/2022**: C++ 运行时
- **MSXML 6.0**: XML 解析支持
- **Microsoft Foundation Classes (MFC) 4.0**: MFC 应用支持
- **Wine Gecko**: HTML 渲染引擎

#### 字体和语言
- **简体中文语言包**: language-pack-zh-hans
- **Noto CJK**: 中日韩字体
- **WQY Microhei**: 中文字体
- **Microsoft Core Fonts**: Arial, Times New Roman 等

### 精简版移除的组件

#### 移除的原因
1. **不适用于构建环境**: 构建/打包不需要 GUI、音频、图形加速
2. **增加镜像体积**: .NET Framework (~500MB), VC++ 运行时 (~200MB)
3. **延长构建时间**: winetricks 下载和配置组件耗时
4. **增加维护成本**: 预安装组件可能不匹配项目需求

#### 可按需添加
如果需要特定组件,可以在运行时安装:
```bash
# 进入容器后按需安装
docker run --rm -it aoirint/wine:dev bash

# 安装所需的 Windows 组件
winetricks dotnet48
winetricks vcrun2019
```

## 🚀 性能对比

### 镜像大小

```
完整版:  ~2.3 GB
精简版:  ~1.2 GB
节省:    ~1.1 GB (48%)
```

### 构建时间

```
完整版:  ~4 分钟
精简版:  ~2 分钟
节省:    ~2 分钟 (50%)
```

### 内存占用

```
完整版启动: ~200-300 MB
精简版启动: ~50-100 MB
```

## 🔧 使用精简版

### 构建

```bash
# 基础版本
docker build -f Dockerfile.minimal --target ubuntu-base -t wine:dev .

# Python 版本
docker build -f Dockerfile.minimal --target python -t wine:dev-py .

# 使用国内镜像
docker build -f Dockerfile.minimal --target ubuntu-base \
  --build-arg USE_CN_MIRRORS=1 -t wine:dev-cn .
```

### 运行

```bash
# 基础使用
docker run --rm -v $(pwd):/workspace wine:dev wine build.bat

# 进入容器
docker run --rm -it -v $(pwd):/workspace wine:dev bash

# Python 构建
docker run --rm -v $(pwd):/workspace wine:dev-py python script.py
```

## 📝 Makefile 配置

可以在 Makefile 中添加精简版目标:

```makefile
# Minimal build target
.PHONY: build-dev build-dev-py
build-dev:
	docker buildx build -f Dockerfile.minimal --target ubuntu-base \
		-t $(REGISTRY)/$(IMAGE_NAME):dev \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		.

build-dev-py:
	docker buildx build -f Dockerfile.minimal --target python \
		-t $(REGISTRY)/$(IMAGE_NAME):dev-py \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg PYTHON_VERSION=3.11.9 \
		.
```

## 💡 建议

### 使用完整版,如果:
- 需要运行 Windows GUI 应用程序
- 需要完整的中文环境支持
- 需要音频/视频功能
- 需要游戏或图形加速
- 不确定需要哪些组件

### 使用精简版,如果:
- 仅用于构建 Windows 程序
- 仅用于打包 Windows 安装包
- 镜像大小敏感
- 构建速度是关键
- CI/CD 环境
- 按需安装 Windows 组件

## 🔄 从精简版迁移到完整版

如果后续发现需要更多组件:

1. **临时方案**: 在精简版容器中按需安装
2. **切换方案**: 重新构建完整版镜像
3. **混合方案**: 使用完整版作为基础,在构建脚本中精简

```bash
# 方案 1: 临时安装
docker run --rm -it wine:dev bash
# 在容器内执行
winetricks dotnet48 vcrun2019

# 方案 2: 切换到完整版
docker build -f Dockerfile -t wine:full .
docker run --rm wine:full your_app.exe
```

## 📊 总结

| 指标 | 完整版 | 精简版 | 推荐 |
|-----|--------|---------|------|
| 构建时间 | 长 | 短 | 精简版 |
| 镜像大小 | 大 | 小 | 精简版 |
| 功能完整性 | 完整 | 基础 | 完整版 |
| 适用场景 | 运行应用 | 构建/打包 | 按需 |
| 维护成本 | 低 | 低 | 相同 |
| 灵活性 | 低 | 高 | 精简版 |

**结论**:
- **开发/构建/打包环境**: 推荐使用 `Dockerfile.minimal`
- **运行 Windows 应用**: 推荐使用 `Dockerfile` (完整版)
- **不确定需求**: 可以先用精简版,按需添加组件
