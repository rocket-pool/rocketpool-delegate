## Rocket Pool Snapshot Signer Registry

In order to facility off-chain voting with Snapshot within Rocket Pool governance, this registry provides a 
one-to-one forward and reverse mapping of delegations of voting power from nodes to a "signing address".

This allows node operators to participate in Snapshot votes in their browser or mobile device without having 
to expose their node keys to a hot wallet.

## Usage

### Test

```shell
$ forge test
```

### Deploy

Copy `.env.example` to `.env` and fill out.

```shell
$ ./deploy.sh
```

### Verify

```shell
$ ./verify.sh
```
