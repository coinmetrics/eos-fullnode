FROM ubuntu:18.04 as builder

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

ARG VERSION

RUN set -ex; \
	git clone --depth=1 -b v${VERSION} --recursive https://github.com/EOSIO/eos.git /root/eos; \
	cd /root/eos; \
	scripts/pinned_build.sh /opt/dep /opt/eosio 4 


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

RUN set -ex; \
	chown 1000:1000 /opt

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

RUN ["nodeos", "--help"]
ENTRYPOINT ["nodeos"]
