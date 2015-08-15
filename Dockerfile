FROM metakungfu/ruby
COPY . /code
WORKDIR /code
RUN apk-install git \
                libffi-dev=3.2.1-r1\
                readline=6.3.008-r0 \
    && bnl-apk-install-build-deps \
    && bundle install \
    && apk del git build-deps \
    && rm -rf /var/cache/apk/*
