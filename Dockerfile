FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

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
