FROM ruby:2.5

WORKDIR /usr/src/app

# clone application repo
RUN git clone -b versioning https://github.com/Bioconductor/BiocHubServer.git

WORKDIR /usr/src/app/BiocHubServer


# help from: https://vsupalov.com/docker-arg-env-variable-guide/#the-dot-env-file-env
ARG MYSQL_ROOT_PASSWORD
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG RUBY_MYSQL_CONNECTION

ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV RUBY_MYSQL_CONNECTION=${RUBY_MYSQL_CONNECTION}

# hub server app configuration file
COPY ./config.yml ./config.yml
# wait-for-it script
COPY ./wait-for-it.sh ./wait-for-it.sh
RUN chmod +x ./wait-for-it.sh
# database initialization, migration, and start script
COPY ./app.sh ./app.sh
RUN chmod +x ./app.sh

# additionally installing sqlite
# help from: https://stackoverflow.com/questions/33711818/embed-sqlite-database-to-docker-container
RUN apt-get -y update
RUN apt-get -y upgrade
# install nano to edit files more easily
RUN apt-get install -y nano
# installs for sqlite
# help from: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-sqlite-on-ubuntu-20-04
RUN apt-get install -y sqlite3 libsqlite3-dev
# installs for mysql client
# help from: https://docs.microsoft.com/en-us/azure/mysql/connect-ruby
RUN apt-get install -y build-essential
RUN apt-get install -y default-libmysqlclient-dev default-mysql-client

# needed newer bundler
RUN gem install bundler:2.1.4

RUN bundle install

# Checking on env variables
RUN echo "MySQL connection string is: ${RUBY_MYSQL_CONNECTION}"

# must wait until MySQL database is ready to accept connections to apply database operations,
# database migrations, and start hub server application
# help from: https://www.reddit.com/r/docker/comments/jzhf4r/waitforit_with_mysql_and_wordpress/
CMD ./wait-for-it.sh bioc-hub-server-db:3306 --strict --timeout=300 -- ./app.sh ${RUBY_MYSQL_CONNECTION}
