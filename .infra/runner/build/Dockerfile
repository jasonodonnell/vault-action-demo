FROM debian:buster-slim

ARG GITHUB_RUNNER_VERSION="2.273.4"

ENV RUNNER_NAME "runner"
ENV GITHUB_TOKEN ""
ENV REPO_OWNER ""
ENV REPO_NAME ""
ENV RUNNER_WORKDIR "_work"
ENV PATH "/usr/local/go/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        iputils-ping \
        unzip \
        build-essential \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && /tmp/aws/install

RUN curl -Ls "https://golang.org/dl/go1.15.2.linux-amd64.tar.gz" \
    | tar xz -C /usr/local

USER github
WORKDIR /home/github

RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
