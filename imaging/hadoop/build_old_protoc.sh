apk --no-cache add --virtual .builddeps \
        autoconf \
        automake \
        build-base \
        libtool \
        zlib-dev \
    && wget -q -O - https://github.com/google/protobuf/archive/v2.5.0.tar.gz \
        | tar -xzf - -C /tmp \
    && cd /tmp/protobuf-* \
    && wget -q -O - https://github.com/google/googletest/archive/release-1.5.0.tar.gz \
        | tar -xzf - \
    && mv googletest-* gtest \
    && ./autogen.sh \
    && CXXFLAGS="$CXXFLAGS -fno-delete-null-pointer-checks" ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    && make \
    && make install \
    && rm -rf /tmp/protobuf-*

