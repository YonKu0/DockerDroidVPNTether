FROM ubuntu:22.04

# Install necessary packages including ADB, wget, and unzip, then clean up in the same RUN statement
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends adb openjdk-11-jre-headless wget unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use ARG for versioning to allow easy updates of Gnirehtet version
ARG GNIREHTET_VERSION=v2.5.1
ENV GNIREHTET_URL="https://github.com/Genymobile/gnirehtet/releases/download/${GNIREHTET_VERSION}/gnirehtet-java-${GNIREHTET_VERSION}.zip" \
    GNIREHTET_DIR="/home/gnirehtet" \
    GNIREHTET_BIN="/usr/local/bin/gnirehtet"

# Create non-root user 'gnirehtet' (UID/GID 1000) for secure, consistent file ownership.
RUN groupadd -r gnirehtetgroup -g 1000 && \
    useradd -r -u 1000 -g gnirehtetgroup -m -d /home/gnirehtet gnirehtet

# Download and setup Gnirehtet (as root), move contents, and remove the gnirehtet-java directory
RUN mkdir -p ${GNIREHTET_DIR} && \
    wget -q ${GNIREHTET_URL} -O ${GNIREHTET_DIR}/gnirehtet.zip && \
    unzip ${GNIREHTET_DIR}/gnirehtet.zip -d ${GNIREHTET_DIR} && \
    rm ${GNIREHTET_DIR}/gnirehtet.zip && \
    mv ${GNIREHTET_DIR}/gnirehtet-java/* ${GNIREHTET_DIR}/ && \
    rmdir ${GNIREHTET_DIR}/gnirehtet-java && \
    sed -i 's|gnirehtet.jar|'${GNIREHTET_DIR}'/gnirehtet.jar|g' ${GNIREHTET_DIR}/gnirehtet && \
    ln -sf ${GNIREHTET_DIR}/gnirehtet ${GNIREHTET_BIN}

# Adjust permissions for gnirehtet
RUN chown -R gnirehtet:gnirehtetgroup ${GNIREHTET_DIR}

# Switch to the non-root user for running the service
USER gnirehtet
WORKDIR ${GNIREHTET_DIR}

# Copy startup script into the Gnirehtet directory and make it executable
COPY --chown=gnirehtet:gnirehtetgroup start-gnirehtet.sh ${GNIREHTET_DIR}/
RUN chmod +x ${GNIREHTET_DIR}/start-gnirehtet.sh

# Use the script as the entry point, now located in the Gnirehtet directory
ENTRYPOINT ["/bin/bash", "-c", "./start-gnirehtet.sh"]

# Add a health check
HEALTHCHECK --interval=5s --timeout=1s --start-period=1s --retries=3 \
    CMD adb devices | grep 'device$' || exit 1
