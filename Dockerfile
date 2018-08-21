FROM ubuntu:18.04

ENV NODE_VERSION=v8.11.3
ENV NODE_DISTRO=linux-x64
ENV DEBIAN_FRONTEND=noninteractive
ENV TIMEZONE=Australia/Melbourne

RUN apt update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gettext-base \
    git \
    maven \
    php7.2 \
    php7.2-bz2 \
    php7.2-cli \
    php7.2-curl \
    php7.2-json \
    php7.2-mbstring \
    php7.2-pgsql \
    php7.2-xml \
    php7.2-xsl \
    php7.2-bcmath \
    php7.2-common \
    php7.2-enchant \
    php7.2-gd \
    php7.2-intl \
    php7.2-mysql \
    php7.2-opcache \
    php7.2-tidy \
    php7.2-xmlrpc \
    php7.2-zip \
    python3-pip \
    tzdata \
    software-properties-common \
    sudo \
    && \
    curl -o node.tar.xz https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz && \
    mkdir /usr/local/lib/nodejs && \
    tar -xJvf node.tar.xz -C /usr/local/lib/nodejs && \
    mv /usr/local/lib/nodejs/node-${NODE_VERSION}-${NODE_DISTRO} /usr/local/lib/nodejs/node-${NODE_VERSION} && \
    rm -rf node.tar.xz && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    pip3 install awscli && \
    curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && \
    chmod +x /usr/local/bin/ecs-cli && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -    && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" && \
    apt-get update && \
    apt-get install -y docker-ce yarn && \
    /usr/local/lib/nodejs/node-${NODE_VERSION}/bin/npm install -g grunt-cli bower webpack-cli && \
    apt clean && \
    useradd -ms /bin/bash ci && \
    echo "ci ALL = NOPASSWD : ALL" | tee /etc/sudoers.d/ci && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

USER ci
WORKDIR /home/ci

ENV NODEJS_HOME="/usr/local/lib/nodejs/node-${NODE_VERSION}/bin"
ENV PATH="${NODEJS_HOME}:${PATH}"