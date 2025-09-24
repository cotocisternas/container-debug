FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install basic system utilities
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
    && rm -rf /var/lib/apt/lists/*

# Install PostgreSQL client
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install MySQL client
RUN apt-get update && apt-get install -y \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB client tools (alternative: install through snap or skip if not critical)
# Note: MongoDB client not available in Ubuntu 22.04 default repos
# We'll include a note in the README about manually installing if needed

# Install Redis client
RUN apt-get update && apt-get install -y \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Python (for scripting)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Note: kubectl not installed due to SSL issues in build environment
# Install manually if needed: curl -LO https://dl.k8s.io/release/stable.txt

# Install additional useful tools
RUN apt-get update && apt-get install -y \
    # Git for troubleshooting
    git \
    # Node.js for testing (basic version from Ubuntu repos)
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN useradd -m -s /bin/bash debugger && \
    usermod -aG sudo debugger

# Copy and install custom scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/test-db-connection \
    /usr/local/bin/test-network \
    /usr/local/bin/test-rabbitmq

# Set working directory
WORKDIR /home/debugger

# Switch to non-root user
USER debugger

# Default command
CMD ["/bin/bash"]