FROM myoung34/github-runner:latest

# Add capability to set ACCESS_TOKEN from a secret
RUN sed -i '3i [[ -f "$ACCESS_TOKEN_FILE" ]] && ACCESS_TOKEN=$(<"$ACCESS_TOKEN_FILE")' /entrypoint.sh

# Change UID/GID of the runner user and set permissions of home directory
ARG RUNNER_UID=3000
ARG RUNNER_GID=988
RUN groupmod -g ${RUNNER_GID} runner && \
    usermod -u ${RUNNER_UID} -g ${RUNNER_GID} runner && \
    chown -R ${RUNNER_UID}:${RUNNER_GID} /home/runner
