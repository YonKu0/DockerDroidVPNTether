FROM ubuntu:24.04

# Detect architecture
ARG TARGETARCH

# Install necessary packages including ADB, Java Runtime Environment (Java 17), Node.js, npm, wget, and unzip
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends wget unzip openjdk-17-jre-headless nodejs npm android-sdk-platform-tools adb && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set up environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-$TARGETARCH
ENV ANDROID_HOME=/usr/local/android-sdk
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# Download and setup Android SDK command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    rm /tmp/cmdline-tools.zip && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    ln -s /usr/bin/adb $ANDROID_HOME/cmdline-tools/latest/bin/adb

# Accept Android SDK licenses before installing components
RUN yes | sdkmanager --licenses

# Update sdkmanager and install specific build tools without triggering dependency checks for the emulator
RUN sdkmanager --update && \
    sdkmanager "build-tools;34.0.0" "platforms;android-34"

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
