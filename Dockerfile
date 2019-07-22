FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
	;

ARG VERSION

COPY fuck_eos.patch /root/fuck_eos.patch

RUN set -ex; \
	git clone --depth=1 -b v${VERSION} --recursive https://github.com/EOSIO/eos.git /root/eos; \
	cd /root/eos; \
	INSTALL_LOCATION=/opt/eosio scripts/eosio_build.sh -P -f -y > /dev/null; \
	patch -p1 < /root/fuck_eos.patch; \
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
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/eosio /usr/

RUN set -ex; \
	mkdir -p /opt/config; \
	chown 1000:1000 /opt/config; \
	curl -L https://raw.githubusercontent.com/CryptoLions/EOS-MainNet/master/config.ini | sed -e 's/!!YOUR_ENDPOINT_IP_ADDRESS!!//' -e 's/plugin = eosio::bnet_plugin//' > /opt/config/config.ini; \
	curl -L -o /opt/config/genesis.json https://raw.githubusercontent.com/CryptoLions/EOS-MainNet/master/genesis.json; \
	true

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

ENTRYPOINT ["nodeos", "--config-dir", "/opt/config"]
