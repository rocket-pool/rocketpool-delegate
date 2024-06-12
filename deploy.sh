source .env

forge create --rpc-url $ETH_RPC_URL --mnemonic "$MNEMONIC" src/RocketSignerRegistry.sol:RocketSignerRegistry