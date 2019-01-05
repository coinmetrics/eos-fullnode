FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
		sudo \
	;

ARG VERSION

RUN set -ex; \
	git clone --depth=1 -b v${VERSION} --recursive https://github.com/EOSIO/eos.git /root/eos; \
	cd /root/eos; \
	sed -i 's/DISK_MIN=20/DISK_MIN=1/' eosio_build.sh; \
	sed -i 's/"${MEM_MEG}" -lt 7000/"${MEM_MEG}" -lt 1000/' scripts/eosio_build_ubuntu.sh; \
	yes 1 | ./eosio_build.sh; \
	./eosio_install.sh; \
	rm -r /root/eos


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		libssl1.1 \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/eosio /usr/

RUN set -ex; \
	mkdir -p /opt/config; \
	curl -L https://raw.githubusercontent.com/CryptoLions/EOS-MainNet/master/config.ini | sed 's/!!YOUR_ENDPOINT_IP_ADDRESS!!//' > /opt/config/config.ini; \
	curl -L -o /opt/config/genesis.json https://raw.githubusercontent.com/CryptoLions/EOS-MainNet/master/genesis.json; \
	true

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

ENTRYPOINT ["nodeos", "--config-dir", "/opt/config"]
