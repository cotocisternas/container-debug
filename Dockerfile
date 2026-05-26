FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/cotocisternas/container-debug"
LABEL org.opencontainers.image.description="Comprehensive debugging container for Kubernetes environments"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="container-debug"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Add MongoDB repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    && curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg \
    && echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" \
       > /etc/apt/sources.list.d/mongodb-org-8.0.list \
    && rm -rf /var/lib/apt/lists/*

# Install all packages in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Basic utilities
    wget \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    # Network debugging tools
    iputils-ping \
    dnsutils \
    netcat-openbsd \
    telnet \
    traceroute \
    tcpdump \
    nmap \
    net-tools \
    # Text processing and editors
    vim \
    nano \
    jq \
    less \
    # Process and system monitoring
    htop \
    procps \
    # SSL/TLS tools
    openssl \
    # Database clients
    postgresql-client \
    mysql-client \
    redis-tools \
    mongodb-mongosh \
    # Programming tools and scripting
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl and grpcurl (pinned versions, multi-arch)
ARG KUBECTL_VERSION=v1.36.1
ARG GRPCURL_VERSION=1.9.3
RUN DPKG_ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${DPKG_ARCH}/kubectl" \
      -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    case "${DPKG_ARCH}" in \
      amd64) GRPCURL_ARCH="x86_64" ;; \
      arm64) GRPCURL_ARCH="arm64" ;; \
      *) echo "Unsupported arch: ${DPKG_ARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_${GRPCURL_ARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin grpcurl && \
    chmod +x /usr/local/bin/grpcurl

# Create a non-root user for security
RUN useradd -m -s /bin/bash debugger

# Copy and install custom scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/test-db-connection \
    /usr/local/bin/test-network \
    /usr/local/bin/test-rabbitmq \
    /usr/local/bin/debug-demo

WORKDIR /home/debugger

USER debugger

CMD ["/bin/bash"]
