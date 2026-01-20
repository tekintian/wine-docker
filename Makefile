# Wine Docker - Build and Run Commands
# ====================================

# Build configuration
REGISTRY ?= registry.cn-hangzhou.aliyuncs.com/tekintian/dev
IMAGE_NAME = wine
BUILD_ARGS = --build-arg BUILDKIT_INLINE_CACHE=1
USE_CN_MIRRORS ?= 0

# Run configuration
RUN_ARGS_BASE = --rm -e LANG=zh_CN.UTF-8 -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix
RUN_ARGS_NVIDIA = $(RUN_ARGS_BASE) --gpus all

# Default target
.DEFAULT_GOAL := help

# Build Commands
# =============

# Stable branch - Base images
.PHONY: build build-ubuntu build-cn
build-ubuntu: build
build:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_latest \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		.

build-cn: USE_CN_MIRRORS=1
build-cn: build

.PHONY: build-ubuntu-win32
build-ubuntu-win32:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-win32 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-win32 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		.

.PHONY: build-nvidia
build-nvidia:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		.

.PHONY: build-nvidia-win32
build-nvidia-win32:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-win32 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-win32 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		.

# Stable branch - Python images (3.11)
.PHONY: build-ubuntu-py311
build-ubuntu-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-py311 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg PYTHON_VERSION=3.11.9 \
		.

.PHONY: build-ubuntu-win32-py311
build-ubuntu-win32-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-win32-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-win32-py311 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		--build-arg PYTHON_VERSION=3.11.9 \
		--build-arg PYTHON_ARCH= \
		.

.PHONY: build-nvidia-py311
build-nvidia-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-py311 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg PYTHON_VERSION=3.11.9 \
		.

.PHONY: build-nvidia-win32-py311
build-nvidia-win32-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-win32-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-win32-py311 \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		--build-arg PYTHON_VERSION=3.11.9 \
		--build-arg PYTHON_ARCH= \
		.

# Development branch - Base images
.PHONY: build-ubuntu-devel
build-ubuntu-devel:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel \
		$(BUILD_ARGS) \
		--build-arg USE_CN_MIRRORS=$(USE_CN_MIRRORS) \
		--build-arg WINE_BRANCH=devel \
		.

.PHONY: build-ubuntu-devel-win32
build-ubuntu-devel-win32:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-win32 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-win32 \
		$(BUILD_ARGS) \
		--build-arg WINE_BRANCH=devel \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		.

.PHONY: build-nvidia-devel
build-nvidia-devel:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-devel \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-devel \
		$(BUILD_ARGS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINE_BRANCH=devel \
		.

.PHONY: build-nvidia-devel-win32
build-nvidia-devel-win32:
	docker buildx build --target ubuntu-base \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-win32 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-win32 \
		$(BUILD_ARGS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINE_BRANCH=devel \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		.

# Development branch - Python images
.PHONY: build-ubuntu-devel-py311
build-ubuntu-devel-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-py311 \
		$(BUILD_ARGS) \
		--build-arg WINE_BRANCH=devel \
		--build-arg PYTHON_VERSION=3.11.9 \
		.

.PHONY: build-ubuntu-devel-win32-py311
build-ubuntu-devel-win32-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-win32-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-win32-py311 \
		$(BUILD_ARGS) \
		--build-arg WINE_BRANCH=devel \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		--build-arg PYTHON_VERSION=3.11.9 \
		--build-arg PYTHON_ARCH= \
		.

.PHONY: build-nvidia-devel-py311
build-nvidia-devel-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-py311 \
		$(BUILD_ARGS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINE_BRANCH=devel \
		--build-arg PYTHON_VERSION=3.11.9 \
		.

.PHONY: build-nvidia-devel-win32-py311
build-nvidia-devel-win32-py311:
	docker buildx build --target python \
		-t $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-win32-py311 \
		--cache-from $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-win32-py311 \
		$(BUILD_ARGS) \
		--build-arg BASE_IMAGE=nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 \
		--build-arg WINE_BRANCH=devel \
		--build-arg WINEARCH=win32 \
		--build-arg GECKO_ARCH=x86 \
		--build-arg PYTHON_VERSION=3.11.9 \
		--build-arg PYTHON_ARCH= \
		.

# Run Commands
# ============

# Stable branch - Base images
.PHONY: run run-ubuntu
run-ubuntu: build-ubuntu
run: build
	docker run $(RUN_ARGS_BASE) $(REGISTRY):$(IMAGE_NAME)_latest

.PHONY: run-ubuntu
run-ubuntu: build-ubuntu
	docker run $(RUN_ARGS_BASE) $(REGISTRY):$(IMAGE_NAME)_ubuntu

.PHONY: run-nvidia
run-nvidia: build-nvidia
	docker run $(RUN_ARGS_NVIDIA) $(REGISTRY):$(IMAGE_NAME)_nvidia

# Stable branch - Python images
.PHONY: run-ubuntu-py311
run-ubuntu-py311: build-ubuntu-py311
	docker run $(RUN_ARGS_BASE) $(REGISTRY):$(IMAGE_NAME)_ubuntu-py311

.PHONY: run-nvidia-py311
run-nvidia-py311: build-nvidia-py311
	docker run $(RUN_ARGS_NVIDIA) $(REGISTRY):$(IMAGE_NAME)_nvidia-py311

# Development branch - Base images
.PHONY: run-ubuntu-devel
run-ubuntu-devel: build-ubuntu-devel
	docker run $(RUN_ARGS_BASE) $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel

.PHONY: run-nvidia-devel
run-nvidia-devel: build-nvidia-devel
	docker run $(RUN_ARGS_NVIDIA) $(REGISTRY):$(IMAGE_NAME)_nvidia-devel

# Development branch - Python images
.PHONY: run-ubuntu-devel-py311
run-ubuntu-devel-py311: build-ubuntu-devel-py311
	docker run $(RUN_ARGS_BASE) $(REGISTRY):$(IMAGE_NAME)_ubuntu-devel-py311

.PHONY: run-nvidia-devel-py311
run-nvidia-devel-py311: build-nvidia-devel-py311
	docker run $(RUN_ARGS_NVIDIA) $(REGISTRY):$(IMAGE_NAME)_nvidia-devel-py311

# Utility Commands
# ================
.PHONY: clean clean-images clean-cache
clean:
	docker rmi $(REGISTRY):$(IMAGE_NAME)_* 2>/dev/null || true

clean-images:
	docker images -q $(REGISTRY) | xargs -r docker rmi -f

clean-cache:
	docker builder prune -f

.PHONY: help
help:
	@echo "Wine Docker - Build and Run Commands"
	@echo "===================================="
	@echo ""
	@echo "Build Targets (Stable):"
	@echo "  make build             Build base wine image (latest)"
	@echo "  make build-cn          Build using China mirrors for faster downloads"
	@echo "  make build-ubuntu      Build ubuntu wine image"
	@echo "  make build-ubuntu-py311 Build ubuntu wine with Python 3.11"
	@echo "  make build-nvidia      Build NVIDIA GPU enabled image"
	@echo "  make build-nvidia-py311 Build NVIDIA image with Python 3.11"
	@echo ""
	@echo "Build Targets (Development):"
	@echo "  make build-ubuntu-devel  Build development wine image"
	@echo "  make build-nvidia-devel  Build NVIDIA development image"
	@echo ""
	@echo "Run Targets:"
	@echo "  make run               Run wine container"
	@echo "  make run-ubuntu-py311   Run wine with Python 3.11"
	@echo "  make run-nvidia        Run wine with NVIDIA GPU"
	@echo "  make run-nvidia-py311  Run NVIDIA wine with Python 3.11"
	@echo ""
	@echo "Utility Targets:"
	@echo "  make clean            Remove all wine images"
	@echo "  make clean-cache      Clean Docker build cache"
	@echo "  make help             Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  REGISTRY              Docker registry (default: registry.cn-hangzhou.aliyuncs.com/tekintian/dev)"
	@echo "  IMAGE_NAME            Image name (default: wine)"
	@echo "  USE_CN_MIRRORS        Use China mirrors (0 or 1, default: 0)"
	@echo ""
	@echo "Examples:"
	@echo "  make build-cn         Build with China mirrors"
	@echo "  make build USE_CN_MIRRORS=1  Same as above"
	@echo "  make REGISTRY=myrepo build  Use custom registry"
