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
	yes 1 | ./eosio_build.sh; \
	./eosio_install.sh; \
	rm -r /root/eos


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libssl1.1 \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/eosio /usr/

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

ENTRYPOINT ["nodeos"]
