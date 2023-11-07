pnpm run localnode

sleep 5

obelisk faucet --network localnet

obelisk publish --network localnet

ts-node scripts/storeConfig.ts localnet
