ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE}

ARG SANDBOX_PROFILE=old-vim
ENV MACSETUP_SANDBOX_PROFILE=${SANDBOX_PROFILE}
LABEL macsetup=true

RUN \
  apt update -qq && \
  apt install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  file \
  gcc \
  git \
  gnupg \
  libedit-dev \
  libicu-dev \
  libjemalloc-dev \
  libpq-dev \
  libqrencode-dev \
  libreadline-dev \
  libselinux1-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  openssh-client \
  procps \
  sudo \
  uuid-dev \
  vim \
  wget \
  zlib1g-dev

ENV APP_HOME /Sandbox
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD install.sh        $APP_HOME/install.sh
ADD diff.sh           $APP_HOME/diff.sh
ADD sections          $APP_HOME/sections
ADD lib               $APP_HOME/lib
ADD config            $APP_HOME/config
ADD assets            $APP_HOME/assets

# Create a user 'sandbox_user' to test running outside of root
ENV NEW_USER sandbox_user
RUN groupadd -g 999 $NEW_USER && \
    useradd --create-home --shell /bin/bash -r -u 999 -g $NEW_USER $NEW_USER
RUN usermod -aG sudo $NEW_USER
RUN usermod -p "" $NEW_USER
RUN chown -R $NEW_USER:$NEW_USER $APP_HOME && \
    chmod -R u+rwX,go+rX $APP_HOME
USER $NEW_USER

ENV SANDBOX true

CMD ./install.sh
