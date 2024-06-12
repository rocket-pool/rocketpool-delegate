source .env

forge verify-contract --rpc-url $ETH_RPC_URL --verifier-url $VERIFIER_URL $ADDRESS src/RocketSignerRegistry.sol:RocketSignerRegistry