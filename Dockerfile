FROM harbor.k8s.libraries.psu.edu/library/ruby-2.6.6-node-15:20210507 as base
ARG UID=2000

USER root
RUN apt-get update && \
   apt-get install --no-install-recommends -y \
   sqlite3 \
   default-libmysqlclient-dev \
   libsqlite3-dev \
   shared-mime-info && \
   rm -rf /var/lib/apt/lists*

RUN useradd -u $UID app -d /app
RUN mkdir /app/tmp
RUN chown -R app /app
USER app

COPY Gemfile Gemfile.lock /app/
RUN gem install bundler:2.1.4
RUN bundle config set path 'vendor/bundle'
RUN bundle install --deployment && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache


COPY package.json yarn.lock /app/
RUN yarn --frozen-lockfile && \
  rm -rf /app/.cache && \
  rm -rf /app/tmp


CMD ["/app/bin/startup"]

# Final Target
FROM base as production

USER app

COPY --chown=app . /app

RUN RAILS_ENV=production \
  SECRET_KEY_BASE=rails_bogus_key \
  MYSQL_USER=mysql \
  MYSQL_PASSWORD=mysql \
  MYSQL_HOST=mysql \
  MYSQL_DATABASE=mysql \
  bundle exec rails assets:precompile && \
  rm -rf /app/.cache/ && \
  rm -rf /app/node_modules/.cache/ && \
  rm -rf /app/tmp/

CMD ["/app/bin/startup"]

# dev stage installs chrome, and all the deps needed to run rspec
FROM base as dev

USER root
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -y x11vnc \
    xvfb \
    fluxbox \
    wget \
    libnss3 \
    wmctrl \
    google-chrome-stable

USER app

RUN bundle config set path 'vendor/bundle'

RUN bundle

CMD ["sleep", "99999999"]
