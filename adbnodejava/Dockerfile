FROM ubuntu:24.04

# Install necessary packages including ADB, Java Runtime Environment, Node.js, and npm
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends adb openjdk-11-jre-headless nodejs npm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables for adbjavanode directory and binary
ENV ADBJAVANODE_DIR="/home/adbjavanode"

# Setup necessary users and permissions
RUN rm -rf /home/ubuntu && \
    userdel ubuntu && \
    groupadd -g 1000 adbjavanode && \
    useradd -m -d "$ADBJAVANODE_DIR" -s /bin/bash -u 1000 -g adbjavanode adbjavanode && \
    usermod -aG plugdev adbjavanode && \
    chown -R adbjavanode:adbjavanode ${ADBJAVANODE_DIR}

# Switch to the adbjavanode user for running the service
USER adbjavanode
WORKDIR ${ADBJAVANODE_DIR}

# Expose port 5037 (ADB port)
EXPOSE 5037

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Use the script as the entry point
ENTRYPOINT ["/bin/bash"]
