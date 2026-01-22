ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE} AS ubuntu-base

ARG DEBIAN_FRONTEND=noninteractive
ARG WINE_BRANCH=stable
ARG WINE_VERSION=11.0.0.0~jammy-1
ARG WINEARCH=win64
ARG PYTHON_VERSION=3.11.9

# Set timezone to avoid interactive prompts
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use China mirrors for faster downloads (optional, can be disabled by setting USE_CN_MIRRORS=0)
ARG USE_CN_MIRRORS=1

# Add i386 architecture and install base packages
RUN dpkg --add-architecture i386 && \
    mkdir -p /etc/apt/keyrings

# Install Wine HQ, Winetricks, and dependencies in a single layer
RUN if [ "$USE_CN_MIRRORS" = "1" ]; then \
        sed -i 's|archive.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list && \
        sed -i 's|security.ubuntu.com|mirrors.aliyun.com|g' /etc/apt/sources.list; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        gnupg \
        lsb-release && \
    wget -qO- https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key && \
    echo "deb [arch=amd64,i386 signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    if [ -n "$WINE_VERSION" ]; then \
        apt-get install -y --no-install-recommends winehq-${WINE_BRANCH}=${WINE_VERSION}; \
    else \
        apt-get install -y --no-install-recommends winehq-${WINE_BRANCH}; \
    fi && \
    apt-get install -y --no-install-recommends \
        gosu \
        libvulkan1:i386 \
        binutils \
        cabextract \
        unzip \
        xz-utils \
        lsof \
        xvfb \
        winbind \
        pulseaudio && \
    wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks && \
    chmod +x /usr/local/bin/winetricks && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install fonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        language-pack-zh-hans \
        fontconfig \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-wqy-microhei \
        ttf-mscorefonts-installer && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user first, then configure Wine
RUN useradd -m -s /bin/bash user && \
    mkdir -p /home/user/.cache/winetricks && \
    chown -R user:user /home/user && \
    chmod -R 755 /home/user

# Configure Wine environment
ENV DISPLAY=:99
RUN gosu user xvfb-run env WINEDEBUG=-all wine wineboot --init && \
    gosu user xvfb-run sh -c 'WINEDEBUG=-all winetricks -q --force fakechinese win10 msxml6 mfc40 dotnet48 vcrun2019 vcrun2022; wineserver -w' && \
    chown -R user:user /home/user/.wine

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wine --version || exit 1

# Metadata
LABEL org.opencontainers.image.title="Wine on Docker"
LABEL org.opencontainers.image.description="Wine compatibility layer for running Windows applications on Linux"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.base.name="${BASE_IMAGE}"
LABEL org.opencontainers.image.base.digest="${BASE_IMAGE_DIGEST}"
LABEL maintainer="tekintian <tekintian@gmail.com>"

# Set working directory for user
WORKDIR /home/user
RUN chmod -R 755 /home/user

# Add helper script to run wine as user
RUN echo '#!/bin/bash && \
    xvfb-run -a gosu user env WINEDEBUG=-all wineserver "$@"' > /usr/local/bin/wineserver && \
    chmod +x /usr/local/bin/wineserver

ENTRYPOINT [ "gosu", "user" ]
CMD [ "wine", "notepad" ]


# Install Python
FROM ubuntu-base AS python
ARG DEBIAN_FRONTEND=noninteractive
ARG WINEARCH=win64
ARG PYTHON_VERSION=3.11.9
ARG PYTHON_ARCH=-amd64
ARG USE_CN_MIRRORS=1

# Use China mirror for Python downloads if enabled
ARG PYTHON_MIRROR=https://www.python.org
RUN if [ "$USE_CN_MIRRORS" = "1" ]; then \
        export PYTHON_MIRROR=https://mirrors.huaweicloud.com/python; \
    fi && \
    wget -q --show-progress ${PYTHON_MIRROR}/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}${PYTHON_ARCH}.exe -O /tmp/install-python.exe && \
    gosu user xvfb-run \
        sh -c 'WINEDEBUG=-all wineboot --init && WINEDEBUG=-all wine /tmp/install-python.exe /quiet PrependPath=1 Include_doc=0 Include_tcltk=1 TargetDir=C:\\Python Include_test=0; wineserver -w' && \
    chown -R user:user /home/user/.wine && \
    rm /tmp/install-python.exe

CMD [ "wine", "python" ]

# Metadata
LABEL org.opencontainers.image.title="Wine with Python"
LABEL org.opencontainers.image.description="Wine environment with Python pre-installed for Windows applications"
LABEL org.opencontainers.image.version="${PYTHON_VERSION}"