FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Add MongoDB repository
RUN apt-get update && apt-get install -y ca-certificates gnupg curl
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | \
       tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Update package index and install all packages in one layer
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
    wget \
    ca-certificates \
    gnupg \
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
    nodejs \
    # Additional system utilities
    sudo

# Clean up apt cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Note: kubectl not installed due to SSL issues in build environment
# Install manually if needed: curl -LO https://dl.k8s.io/release/stable.txt

# Create a non-root user for security
RUN useradd -m -s /bin/bash debugger && \
    usermod -aG sudo debugger

# Copy and install custom scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/test-db-connection \
    /usr/local/bin/test-network \
    /usr/local/bin/test-rabbitmq \
    /usr/local/bin/debug-demo

# Set working directory
WORKDIR /home/debugger

# Switch to non-root user
USER debugger

# Default command
CMD ["/bin/bash"]