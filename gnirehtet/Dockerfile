FROM ubuntu:22.04

# Install necessary packages including ADB, wget, and unzip, then clean up
RUN apt-get update && \
    apt-get install -y adb openjdk-11-jre-headless wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /gnirehtet

# Define variables for Gnirehtet
ENV GNIREHTET_DIR="/gnirehtet" \
    GNIREHTET_SUBDIR="/gnirehtet/gnirehtet-java" \
    GNIREHTET_BIN="/usr/local/bin/gnirehtet" \
    GNIREHTET_URL="https://github.com/Genymobile/gnirehtet/releases/download/v2.5.1/gnirehtet-java-v2.5.1.zip"

# Create directory, Download gnirehtet, Unzip and remove the zip file, adjust permissions, and create symlink
RUN mkdir -p $GNIREHTET_DIR && \
    wget $GNIREHTET_URL -O $GNIREHTET_DIR/gnirehtet.zip && \
    unzip $GNIREHTET_DIR/gnirehtet.zip -d $GNIREHTET_DIR && \
    rm $GNIREHTET_DIR/gnirehtet.zip && \
    sed -i 's|gnirehtet.jar|'$GNIREHTET_SUBDIR'/gnirehtet.jar|g' $GNIREHTET_SUBDIR/gnirehtet && \
    ln -sf $GNIREHTET_SUBDIR/gnirehtet $GNIREHTET_BIN && \
    chmod +x $GNIREHTET_BIN

# Create a non-root user
# Ensure the user has appropriate permissions for the work directory and necessary files
RUN useradd -m gnirehtetuser && \
    chown -R gnirehtetuser:gnirehtetuser /gnirehtet

USER gnirehtetuser

# Set gnirehtet working directory
WORKDIR $GNIREHTET_SUBDIR

# Command to run when the container starts
CMD ["sh", "-c", "echo '------------- Starting adb daemon -------------' && adb devices && echo '------------- Starting gnirehtet -------------' && ${GNIREHTET_CMD:-gnirehtet run} 2>&1 | tee gnirehtetlog.txt & GNIREHTET_PID=$!; sleep 10; echo Checking for Gnirehtet error...; if grep -q -E '(E Gnirehtet|Exception in thread)' gnirehtetlog.txt; then echo Error found, attempting to kill Gnirehtet; if ps -p $GNIREHTET_PID > /dev/null; then kill $GNIREHTET_PID; else echo Gnirehtet process not found; fi; else echo No Gnirehtet error found, continuing; fi; wait $GNIREHTET_PID"]

# Add a health check
HEALTHCHECK --interval=5s --timeout=1s --start-period=1s --retries=3 \
    CMD adb devices | grep 'device$' || exit 1
