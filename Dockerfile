FROM ubuntu:18.04

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
  vim \
  wget \
  zlib1g-dev

ENV APP_HOME /Sandbox
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD install.sh        $APP_HOME/install.sh
ADD diff.sh           $APP_HOME/diff.sh
ADD sections          $APP_HOME/sections
ADD splash_screen     $APP_HOME/splash_screen
ADD fonts             $APP_HOME/fonts
ADD installation      $APP_HOME/installation
ADD iTerm2            $APP_HOME/iTerm2
ADD Mac_Dot_Files     $APP_HOME/Mac_Dot_Files
ADD misc              $APP_HOME/misc
ADD screensavers      $APP_HOME/screensavers
ADD Rectangle         $APP_HOME/Rectangle
ADD vim               $APP_HOME/vim
ADD VSCode            $APP_HOME/VSCode
ADD gitconfig.txt     $APP_HOME/gitconfig.txt
ADD .tool-versions    $APP_HOME/.tool-versions

# Create a user 'sandbox_user' to test running outside of root
ENV NEW_USER sandbox_user
RUN groupadd -g 999 $NEW_USER && \
    useradd --create-home --shell /bin/bash -r -u 999 -g $NEW_USER $NEW_USER
RUN usermod -aG sudo $NEW_USER
RUN usermod -p "" $NEW_USER
USER $NEW_USER

ENV SANDBOX true

CMD ./install.sh
