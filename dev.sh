net=$1

if [ $net == "localnet" ]; then
  nohup obelisk localnode > localnode.nohup.out &
elif [ $net == "devnet" ]; then
  nohup obelisk devnode > devnode.nohup.out &
elif [ $net == "testnet" ]; then
  nohup obelisk testnode > testnode.nohup.out &
elif [ $net == "mainnet" ]; then
  nohup obelisk mainnode > mainnode.nohup.out &
else
  echo "Invalid network name."
  exit 1
fi

ts-node scripts/generateAccount.ts

sleep 5

obelisk faucet --network $net

obelisk publish --network $net

ts-node scripts/storeConfig.ts $net
