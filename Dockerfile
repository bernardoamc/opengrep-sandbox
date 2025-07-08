FROM alpine/git AS builder

# Set a temporary HOME for the root user in the builder stage for consistent behavior
ENV HOME=/root

WORKDIR /app

RUN apk add --no-cache curl bash

# The script will install to /root/.opengrep/cli/<VERSION> and create a symlink /root/.opengrep/cli/latest
RUN curl -fsSL https://raw.githubusercontent.com/opengrep/opengrep/main/install.sh | bash 2>&1 | tee install_log.txt

# Finds the actual versioned directory that 'latest' points to.
RUN LATEST_TARGET=$(readlink "${HOME}/.opengrep/cli/latest") && \
    if [ -n "$LATEST_TARGET" ] && [ -d "$LATEST_TARGET" ]; then \
        # Calculate the path relative to ${HOME}/.opengrep/
        # This will be something like "cli/v1.5.0"
        RELATIVE_PATH_TO_VERSIONED_DIR=$(echo "$LATEST_TARGET" | sed "s|^${HOME}/.opengrep/||"); \
        tar -czvf opengrep_versioned_dir.tar.gz -C "${HOME}/.opengrep" "${RELATIVE_PATH_TO_VERSIONED_DIR}"; \
    else \
        echo "Error: Could not determine actual Opengrep versioned directory. Check install_log.txt."; \
        exit 1; \
    fi

FROM alpine:latest

RUN echo "network: disabled" > /etc/network/interfaces

ENV APP_USER=opengrepuser
ENV APP_UID=1000
ENV APP_GID=1000

RUN apk add --no-cache bash \
    && addgroup -g ${APP_GID} ${APP_USER} \
    && adduser -u ${APP_UID} -G ${APP_USER} -s /bin/bash -D ${APP_USER} \
    # Create a home directory for the user and set permissions
    && mkdir -p /home/${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} /home/${APP_USER} \
    && chmod 755 /home/${APP_USER}

# Set the HOME directory for the non-root user. This is crucial for Opengrep's paths.
ENV HOME=/home/${APP_USER}

USER ${APP_USER}

RUN mkdir -p ${HOME}/.opengrep

# Copy the tarball containing the opengrep versioned installation directory
# into the new user's .opengrep directory. The tarball contains "cli/vX.Y.Z/opengrep" structure.
COPY --from=builder /app/opengrep_versioned_dir.tar.gz ${HOME}/.opengrep/

RUN mkdir -p ${HOME}/rules && chown ${APP_USER}:${APP_USER} ${HOME}/rules
RUN mkdir -p ${HOME}/files && chown ${APP_USER}:${APP_USER} ${HOME}/files

COPY rules/ ${HOME}/rules/
COPY files/ ${HOME}/files/

# Extract the tarball. This will create: ${HOME}/.opengrep/cli/<version>/opengrep
RUN tar -xzvf ${HOME}/.opengrep/opengrep_versioned_dir.tar.gz -C ${HOME}/.opengrep/ && rm ${HOME}/.opengrep/opengrep_versioned_dir.tar.gz

# After extraction, we need to manually create the 'latest' symlink
# to point to the correct, newly extracted versioned directory in the non-root user's HOME.
# First, find the actual versioned directory's name
RUN VER_DIR_NAME=$(ls -d ${HOME}/.opengrep/cli/v* | head -n 1 | xargs basename) && \
    if [ -n "$VER_DIR_NAME" ]; then \
        ln -s "${VER_DIR_NAME}" "${HOME}/.opengrep/cli/latest"; \
    else \
        echo "Error: Could not find the installed versioned directory in ${HOME}/.opengrep/cli/."; \
        exit 1; \
    fi

RUN chmod +x ${HOME}/.opengrep/cli/latest/opengrep && \
    chown ${APP_USER}:${APP_USER} ${HOME}/.opengrep/cli/latest/opengrep

ENV PATH="${HOME}/.opengrep/cli/latest:${PATH}"

WORKDIR ${HOME}

ENTRYPOINT ["/bin/bash"]
