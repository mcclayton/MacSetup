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
  procps \
  sudo \
  vim \
  wget \
  zlib1g-dev

ENV APP_HOME /MacSetup
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD install.sh        $APP_HOME/install.sh
ADD fonts             $APP_HOME/fonts
ADD installation      $APP_HOME/installation
ADD iTerm2            $APP_HOME/iTerm2
ADD Mac_Dot_Files     $APP_HOME/Mac_Dot_Files
ADD misc              $APP_HOME/misc
ADD screensavers      $APP_HOME/screensavers
ADD Spectacle         $APP_HOME/Spectacle
ADD vim               $APP_HOME/vim
ADD VSCode            $APP_HOME/VSCode
ADD gitconfig.txt     $APP_HOME/gitconfig.txt
ADD .tool-versions    $APP_HOME/.tool-versions

# Create a user 'appuser' to test running outside of root
RUN groupadd -g 999 appuser && \
    useradd --create-home --shell /bin/bash -r -u 999 -g appuser appuser
RUN usermod -aG sudo appuser
RUN usermod -p "" appuser
USER appuser

CMD ./install.sh
