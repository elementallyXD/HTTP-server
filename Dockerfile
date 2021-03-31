FROM amd64/ubuntu:trusty
FROM gcc:latest as build

RUN apt-get update \
    && apt-get install -y g++ wget

RUN wget --max-redirect 3 https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.tar.gz
RUN mkdir -p /usr/include/boost && tar zxf boost_1_75_0.tar.gz -C /usr/include/boost --strip-components=1
RUN cd /usr/include/boost && ./bootstrap.sh \
    && ./b2 --without-python --prefix=/usr/include/boost -j 4 link=shared runtime-link=shared install \
    && cd .. && ldconfig

RUN cd ~
COPY . server
WORKDIR /server

RUN echo -e "\n/usr/include/boost/lib/" | tee -a /etc/ld.so.conf                                                                                                              
RUN ldconfig

EXPOSE 8080
RUN  ./build.sh

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser
USER appuser

CMD  ["./server", "0.0.0.0", "8080", "."]