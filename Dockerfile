FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get upgrade -y; \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		ca-certificates \ 
		tzdata \
		git \
		zip unzip \
		libncurses5 wget build-essential \
		cmake curl \
		libcurl4-openssl-dev libgmp-dev libssl-dev libusb-1.0.0-dev libzstd-dev \
		time pkg-config zlib1g-dev libtinfo-dev bzip2 libbz2-dev \
		python3 file \
	;

ARG VERSION

RUN set -ex; \
	git clone --depth=1 -b v${VERSION} --recursive https://github.com/AntelopeIO/leap.git /root/eos; \
	cd /root/eos; \
	scripts/pinned_build.sh /opt/dep /opt/eosio 8 


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get upgrade -y; \
	DEBIAN_FRONTEND=noninteractive \
	apt-get install -y --no-install-recommends \
		ca-certificates \ 
		tzdata \
		zip unzip \
		libncurses5 wget build-essential \
		cmake curl \
		libcurl4-openssl-dev libgmp-dev libssl-dev libusb-1.0.0-dev libzstd-dev \
		time pkg-config zlib1g-dev libtinfo-dev bzip2 libbz2-dev \
		python3 file \
	;
	
COPY --from=builder /opt/eosio/bin /usr/local/bin/
COPY pinned_dep_build.sh /opt/dep/pinned_dep_build.sh
COPY pinned_toolchain.cmake /opt/dep/pinned_toolchain.cmake
RUN useradd -m -u 1000 -s /bin/bash runner
RUN set -ex; \
	chown -R 1000:1000 /opt \
	&& chmod +x /opt/dep/pinned_dep_build.sh 

USER runner

WORKDIR /opt/dep 
RUN set -ex; \
	./pinned_dep_build.sh /opt/dep 8

RUN ["nodeos", "--help"]
ENTRYPOINT ["nodeos"]

