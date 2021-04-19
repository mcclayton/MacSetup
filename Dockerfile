FROM node:13
FROM ruby:2.6.3-slim

ENV APP_HOME /MacSetup
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD install.sh        $APP_HOME/install.sh
ADD Atom              $APP_HOME/Atom
ADD fonts             $APP_HOME/fonts
ADD installation      $APP_HOME/installation
ADD iTerm2            $APP_HOME/iTerm2
ADD Mac_Dot_Files     $APP_HOME/Mac_Dot_Files
ADD misc              $APP_HOME/misc
ADD screensavers      $APP_HOME/screensavers
ADD Spectacle         $APP_HOME/Spectacle
ADD vim               $APP_HOME/vim
ADD VSCode            $APP_HOME/VSCode

# Create a user 'appuser' to test running outside of root
RUN groupadd -g 999 appuser && \
    useradd --create-home --shell /bin/bash -r -u 999 -g appuser appuser
USER appuser

CMD ./install.sh
