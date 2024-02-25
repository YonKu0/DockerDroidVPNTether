FROM ubuntu:22.04

# Install necessary packages including ADB, wget, and unzip, then clean up in the same RUN statement
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends adb openjdk-11-jre-headless wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Set the initial working directory
WORKDIR /gnirehtet

# Use ARG for versioning to allow easy updates of Gnirehtet version
ARG GNIREHTET_VERSION=v2.5.1
ENV GNIREHTET_DIR="/gnirehtet" \
    GNIREHTET_SUBDIR="/gnirehtet/gnirehtet-java" \
    GNIREHTET_BIN="/usr/local/bin/gnirehtet" \
    GNIREHTET_URL="https://github.com/Genymobile/gnirehtet/releases/download/${GNIREHTET_VERSION}/gnirehtet-java-${GNIREHTET_VERSION}.zip"

# Create directory, Download gnirehtet, Unzip and remove the zip file, adjust permissions, and create symlink
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends adb openjdk-11-jre-headless wget unzip && \
    mkdir -p $GNIREHTET_DIR && \
    wget -q $GNIREHTET_URL -O $GNIREHTET_DIR/gnirehtet.zip && \
    unzip $GNIREHTET_DIR/gnirehtet.zip -d $GNIREHTET_DIR && \
    rm $GNIREHTET_DIR/gnirehtet.zip && \
    sed -i 's|gnirehtet.jar|'$GNIREHTET_SUBDIR'/gnirehtet.jar|g' $GNIREHTET_SUBDIR/gnirehtet && \
    ln -sf $GNIREHTET_SUBDIR/gnirehtet $GNIREHTET_BIN && \
    apt-get remove --purge -y wget unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user 'gnirehtetuser' (UID/GID 1000) for secure, consistent file ownership.
RUN groupadd -r gnirehtetgroup -g 1000 && \
    useradd -r -u 1000 -g gnirehtetgroup -m gnirehtetuser

# Setting new working directory to Gnirehtet's subdirectory
WORKDIR $GNIREHTET_SUBDIR

# Copy startup script into the Gnirehtet subdirectory and make it executable
COPY start-gnirehtet.sh ./
RUN chmod +x ./start-gnirehtet.sh

# Adjust permissions for gnirehtetuser
RUN chown -R gnirehtetuser:gnirehtetgroup $GNIREHTET_DIR

# Switch back to the non-root user for running the service
USER gnirehtetuser

# Use the script as the entry point, now located in the working directory
ENTRYPOINT ["/bin/bash", "./start-gnirehtet.sh"]

# Add a health check
HEALTHCHECK --interval=5s --timeout=1s --start-period=1s --retries=3 \
    CMD adb devices | grep 'device$' || exit 1
