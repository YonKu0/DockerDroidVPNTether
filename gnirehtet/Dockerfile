# Use an initial stage to download and unpack the necessary files
FROM ubuntu:24.04 as builder

# Install necessary packages including wget and unzip
RUN apt-get update -q && \
    apt-get install -y wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use ARG for versioning to allow easy updates of Gnirehtet version
ARG GNIREHTET_VERSION=v2.5.1
ENV GNIREHTET_URL="https://github.com/Genymobile/gnirehtet/releases/download/${GNIREHTET_VERSION}/gnirehtet-java-${GNIREHTET_VERSION}.zip" \
    GNIREHTET_DIR="/gnirehtet"

# Download and setup Gnirehtet
RUN mkdir -p ${GNIREHTET_DIR} && \
    wget -q ${GNIREHTET_URL} -O gnirehtet.zip && \
    unzip gnirehtet.zip -d ${GNIREHTET_DIR} && \
    rm gnirehtet.zip && \
    mv ${GNIREHTET_DIR}/gnirehtet-java/* ${GNIREHTET_DIR}/ && \
    rmdir ${GNIREHTET_DIR}/gnirehtet-java

# Start the final stage
FROM ubuntu:24.04

# Install necessary packages including ADB and Java Runtime Environment
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends adb openjdk-11-jre-headless && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the unpacked files from the builder stage
COPY --from=builder /gnirehtet /home/gnirehtet

# Set environment variables for Gnirehtet directory and binary
ENV GNIREHTET_DIR="/home/gnirehtet" \
    GNIREHTET_BIN="/usr/local/bin/gnirehtet"

# Attempt to remove 'ubuntu' user and its group first, if they exist
RUN if id ubuntu &>/dev/null; then \
    userdel ubuntu || true; \
    rm -rf /home/ubuntu; \
    fi && \
    if getent group ubuntu &>/dev/null; then \
    groupdel ubuntu || true; \
    fi

# Setup necessary users and permissions
RUN groupadd -g 1000 gnirehtet && \
    useradd -m -d "$GNIREHTET_DIR" -s /bin/bash -u 1000 -g gnirehtet gnirehtet && \
    usermod -aG plugdev gnirehtet && \
    ln -sf ${GNIREHTET_DIR}/gnirehtet ${GNIREHTET_BIN} && \
    chown -R gnirehtet:gnirehtet ${GNIREHTET_DIR}

# Switch to the gnirehtet user for running the service
USER gnirehtet
WORKDIR ${GNIREHTET_DIR}

# Copy and setup the startup script
COPY --chown=gnirehtet:gnirehtet start-gnirehtet.sh ${GNIREHTET_DIR}/
RUN chmod +x ${GNIREHTET_DIR}/start-gnirehtet.sh

# Use the script as the entry point
ENTRYPOINT ["/bin/bash", "-c", "./start-gnirehtet.sh"]

# Add a health check
HEALTHCHECK --interval=5s --timeout=1s --start-period=5s --retries=1 \
    CMD grep -q -E '(E Gnirehtet|Exception in thread)' gnirehtetlog.txt && exit 1 || exit 0
