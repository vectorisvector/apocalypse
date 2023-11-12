import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { MIST_PER_SUI } from "@mysten/sui.js/utils";
import { hexToBytes } from "@noble/hashes/utils";
import "dotenv/config";

import objectData from "./config";
import { bcs } from "@mysten/sui.js/bcs";

const rpcUrl = getFullnodeUrl("devnet");
const client = new SuiClient({ url: rpcUrl });

const privateKey = hexToBytes(process.env.PRIVATE_KEY as string);
const keypair = Ed25519Keypair.fromSecretKey(privateKey);
const address = keypair.toSuiAddress();

console.log(`Address: ${address}`);

const SCISSORS = new TextEncoder().encode("scissors"); // ASCII values for "scissors"
const ROCK = new TextEncoder().encode("rock"); // ASCII values for "rock"
const PAPER = new TextEncoder().encode("paper"); // ASCII values for "paper"

function mint(param: { scissors: number; rock: number; paper: number }) {
  const list = Object.entries(param);
  const txb = new TransactionBlock();
  list.forEach(([key, value]) => {
    for (let i = 0; i < value; i++) {
      const [coin] = txb.splitCoins(txb.gas, [2n * MIST_PER_SUI]);
      const [prop, coin_] = txb.moveCall({
        target: `${objectData.packageId}::pool_system::mint`,
        arguments: [txb.pure.string(key), coin, txb.object(objectData.world)],
      });
      txb.transferObjects([prop, coin_], address);
    }
  });

  return txb;
}

function burn() {
  const txb = new TransactionBlock();
  const coin = txb.moveCall({
    target: `${objectData.packageId}::pool_system::burn`,
    arguments: [
      txb.object(
        "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
      ),
      txb.object(objectData.pool),
      txb.object(objectData.world),
    ],
  });
  txb.transferObjects([coin], address);
  return txb;
}

function stake() {
  const txb = new TransactionBlock();
  const props = txb.makeMoveVec({
    objects: [
      txb.object(
        "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
      ),
      txb.object(
        "0x1f80028037abb6315f2feadab650d037f1c689faa7b6010816c8a2c86195464a",
      ),
      txb.object(
        "0xb0e660523d930dcce11f1408e55c6b207222271a7c6e4bfa0ffd7cfe2300b29e",
      ),
    ],
  });
  txb.moveCall({
    target: `${objectData.packageId}::pool_system::stake`,
    arguments: [
      props,
      txb.pure(address),
      txb.object(objectData.pool),
      txb.object(objectData.world),
    ],
  });
  return txb;
}

function unstake() {
  const txb = new TransactionBlock();
  txb.moveCall({
    target: `${objectData.packageId}::pool_system::unstake`,
    arguments: [
      txb.pure([
        "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
      ]),
      txb.object(objectData.pool),
      txb.object(objectData.world),
    ],
  });
  return txb;
}

async function main() {
  // const txb = mint({
  //   scissors: 1,
  //   rock: 1,
  //   paper: 1,
  // });

  const txb = burn();

  // const txb = stake();

  // const txb = unstake();

  // const res = await client.devInspectTransactionBlock({
  //   transactionBlock: txb,
  //   sender: address,
  // });

  const res = await client.signAndExecuteTransactionBlock({
    transactionBlock: txb,
    signer: keypair,
  });

  console.log(res);
}

main();
