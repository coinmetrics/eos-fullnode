# EOS docker image

This is unofficial EOS docker image.

It is being used internally at Coin Metrics, and is published in the hope it will be useful, but without any warranty. No support is available. You are using it at your own risk.

## Using image

[![Docker Repository on Quay](https://quay.io/repository/coinmetrics/fullnode-eos/status "Docker Repository on Quay")](https://quay.io/repository/coinmetrics/fullnode-eos)

```
docker pull quay.io/coinmetrics/fullnode-eos:<version>
```

## Security

This image builds binaries from sources downloaded from https://github.com/EOSIO/eos.

Image is built on Coin Metrics infrastructure. [CI logs](https://gitlab.com/coinmetrics/fullnodes/eos/pipelines)

## License

Content of this repository is made available under MIT license, see LICENSE file.
Note that this repository only contains scripts to download binaries or build ones from source.
Those binaries or sources are distributed under their own licenses.
Please consult upstream documentation for details.
