FROM docker:git

MAINTAINER Sascha Selzer sascha.selzer@gmail.com

ENV OC_VERSION=v3.9.0 \
    OC_TAG_SHA=191fece \
    BUILD_DEPS='tar gzip py-pip py-setuptools ca-certificates groff less' \ 
    RUN_DEPS='python curl gettext jq' \
    AWS_CLI_VERSION=1.15.68

ENV LANG=C.UTF-8

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \ 
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \ 
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \ 
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \ 
        "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \ 
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \ 
    wget \ 
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \ 
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \ 
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \ 
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    apk del glibc-i18n && \
    rm "/root/.wget-hsts" && \ 
    apk del .build-dependencies && \
    rm \ 
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \ 
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN apk update --no-cache && \
    apk add --no-cache $RUN_DEPS   && \
    apk add --no-cache --virtual .build-deps $BUILD_DEPS && \
    wget "https://raw.githubusercontent.com/sgerrand/alpine-pkg-git-crypt/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub"  && \
    wget "https://github.com/sgerrand/alpine-pkg-git-crypt/releases/download/0.6.0-r0/git-crypt-0.6.0-r0.apk" && \
    apk --no-cache add git-crypt-0.6.0-r0.apk && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    curl -sLo /tmp/oc.tar.gz https://github.com/openshift/origin/releases/download/${OC_VERSION}/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit.tar.gz && \
    tar xzvf /tmp/oc.tar.gz -C /tmp/ && \
    mv /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit/oc /usr/local/bin/ && \
    rm -rf /tmp/oc.tar.gz /tmp/openshift-origin-client-tools-${OC_VERSION}-${OC_TAG_SHA}-linux-64bit && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    rm git-crypt-0.6.0-r0.apk && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*
    