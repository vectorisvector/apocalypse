import {
  TransactionBlock,
  Ed25519Keypair,
  MIST_PER_SUI,
  Obelisk,
  NetworkType,
  loadMetadata,
  fromB64,
  TransactionResult,
} from "@0xobelisk/sui-client";

import { hexToBytes } from "@noble/hashes/utils";
import "dotenv/config";

import objectData from "./config";

const network = "devnet" as NetworkType;

const privateKey = hexToBytes(process.env.PRIVATE_KEY as string);
const keypair = Ed25519Keypair.fromSecretKey(privateKey);

const privateKeyU8 = fromB64(keypair.export().privateKey);
const privateKeyHex = Buffer.from(privateKeyU8).toString("hex");

const address = keypair.toSuiAddress();

const metadata = await loadMetadata(network, objectData.packageId);
const obelisk = new Obelisk({
  networkType: network,
  packageId: objectData.packageId,
  metadata: metadata,
  secretKey: privateKeyHex,
});

console.log(`Address: ${address}`);

const SCISSORS = new TextEncoder().encode("scissors"); // ASCII values for "scissors"
const ROCK = new TextEncoder().encode("rock"); // ASCII values for "rock"
const PAPER = new TextEncoder().encode("paper"); // ASCII values for "paper"

async function mint(param: { scissors: number; rock: number; paper: number }) {
  const list = Object.entries(param);
  const txb = new TransactionBlock();
  list.forEach(async ([key, value]) => {
    for (let i = 0; i < value; i++) {
      const [coin] = txb.splitCoins(txb.gas, [txb.pure(2n * MIST_PER_SUI)]);
      // const [prop, coin_] = txb.moveCall({
      //   target: `${objectData.packageId}::pool_system::mint`,
      //   arguments: [txb.pure(key), coin, txb.object(objectData.world)],
      // });
      const params = [txb.pure(key), coin, txb.object(objectData.world)];
      const [prop, coin_] = (await obelisk.tx.pool_system.mint(
        txb,
        params,
        undefined,
        true,
      )) as TransactionResult;
      txb.transferObjects([prop, coin_], txb.pure(address));
    }
  });

  return txb;
}

async function burn() {
  const txb = new TransactionBlock();
  const params = [
    txb.object(
      "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
    ),
    txb.object(objectData.pool),
    txb.object(objectData.world),
  ];

  const coin = (await obelisk.tx.pool_system.burn(
    txb,
    params,
    undefined,
    true,
  )) as TransactionResult;

  // const coin = txb.moveCall({
  //   target: `${objectData.packageId}::pool_system::burn`,
  //   arguments:
  // });
  txb.transferObjects([coin], txb.pure(address));
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
  // txb.moveCall({
  //   target: `${objectData.packageId}::pool_system::stake`,
  //   arguments: [
  //     props,
  //     txb.pure(address),
  //     txb.object(objectData.pool),
  //     txb.object(objectData.world),
  //   ],
  // });

  const params = [
    props,
    txb.pure(address),
    txb.object(objectData.pool),
    txb.object(objectData.world),
  ];
  obelisk.tx.pool_system.stake(txb, params, undefined, true);

  return txb;
}

function unstake() {
  const txb = new TransactionBlock();
  // txb.moveCall({
  //   target: `${objectData.packageId}::pool_system::unstake`,
  //   arguments: [
  //     txb.pure([
  //       "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
  //     ]),
  //     txb.object(objectData.pool),
  //     txb.object(objectData.world),
  //   ],
  // });

  const params = [
    txb.pure([
      "0x0d892ba7878c3b1efeb6a098cf16d1720b16f716d8b6b23ec7c14728a9e156b5",
    ]),
    txb.object(objectData.pool),
    txb.object(objectData.world),
  ];

  obelisk.tx.pool_system.unstake(txb, params, undefined, true);

  return txb;
}

async function main() {
  // const txb = mint({
  //   scissors: 1,
  //   rock: 1,
  //   paper: 1,
  // });

  const txb = await burn();

  // const txb = stake();

  // const txb = unstake();

  // const res = await client.devInspectTransactionBlock({
  //   transactionBlock: txb,
  //   sender: address,
  // });

  const res = await obelisk.signAndSendTxn(txb);

  console.log(res);
}

main();
