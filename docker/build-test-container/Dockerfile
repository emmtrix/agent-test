FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

COPY select-ubuntu-mirror.sh /usr/local/bin/select-ubuntu-mirror.sh

RUN chmod +x /usr/local/bin/select-ubuntu-mirror.sh \
    && /usr/local/bin/select-ubuntu-mirror.sh

# Keep this image broadly aligned with GitHub-hosted Ubuntu 24.04 runners
# where that is practical inside a repo-specific build container.
RUN apt-get update && apt-get install -y --no-install-recommends \
    acl \
    aria2 \
    autoconf \
    automake \
    bash \
    bc \
    binutils \
    bison \
    brotli \
    build-essential \
    bzip2 \
    ca-certificates \
    ccache \
    coreutils \
    cmake \
    curl \
    dbus \
    dnsutils \
    dpkg \
    dpkg-dev \
    fakeroot \
    file \
    findutils \
    flex \
    fonts-noto-color-emoji \
    ftp \
    g++ \
    gcc \
    git \
    gnupg2 \
    haveged \
    iproute2 \
    iputils-ping \
    jq \
    libnss3-tools \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libyaml-dev \
    locales \
    lz4 \
    m4 \
    make \
    mediainfo \
    mercurial \
    net-tools \
    netcat-openbsd \
    ninja-build \
    openssh-client \
    p7zip-full \
    p7zip-rar \
    parallel \
    patchelf \
    pigz \
    pollinate \
    pkg-config \
    python-is-python3 \
    python3 \
    python3-pip \
    procps \
    rpm \
    rsync \
    shellcheck \
    sqlite3 \
    sshpass \
    systemd-coredump \
    sudo \
    swig \
    sphinxsearch \
    tar \
    telnet \
    texinfo \
    time \
    tk \
    tree \
    tzdata \
    unzip \
    upx \
    wget \
    xvfb \
    xz-utils \
    zip \
    zstd \
    zsync \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    clang-format \
    clang-18 \
    git-lfs \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libclang-18-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libxml2-utils \
    libzstd-dev \
    lld \
    php-cli \
    php-mbstring \
    python3-pytest \
    unifdef \
    valgrind \
    llvm-18-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /bin/bash /bin/sh

RUN git lfs install --system

RUN python3 -m pip install --break-system-packages \
    chardet \
    msgspec \
    pebble \
    psutil \
    zstandard

WORKDIR /workspace

CMD ["/bin/bash"]
