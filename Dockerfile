FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
	;

ARG VERSION

RUN set -ex; \
	git clone --depth=1 -b v${VERSION} --recursive https://github.com/EOSIO/eos.git /root/eos; \
	cd /root/eos; \
	INSTALL_LOCATION=/opt/eosio scripts/eosio_build.sh -P -y > /dev/null; \
	scripts/eosio_install.sh; \
	rm -r /root/eos /opt/eosio/opt /opt/eosio/src


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		libicu60 \
		libssl1.1 \
        libpq5 \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/eosio /usr/

RUN set -ex; \
	mkdir -p /opt/config; \
	chown 1000:1000 /opt/config

COPY config.ini genesis.json /opt/config/

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

RUN ["nodeos", "--help"]
ENTRYPOINT ["nodeos", "--config-dir", "/opt/config", "--genesis-json", "/opt/config/genesis.json"]
