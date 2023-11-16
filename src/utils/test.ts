import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { hexToBytes } from "@noble/hashes/utils";
import "dotenv/config";
import { packageId, world } from "./config";

const rpcUrl = getFullnodeUrl("devnet");
const client = new SuiClient({ url: rpcUrl });

const privateKey = hexToBytes(process.env.PRIVATE_KEY as string);
const keypair = Ed25519Keypair.fromSecretKey(privateKey);
const address = keypair.toSuiAddress();

console.log(`Address: ${address}`);

const SCISSORS = new TextEncoder().encode("scissors"); // ASCII values for "scissors"
const ROCK = new TextEncoder().encode("rock"); // ASCII values for "rock"
const PAPER = new TextEncoder().encode("paper"); // ASCII values for "paper"

async function main() {
  const txb = new TransactionBlock();

  txb.moveCall({
    target: `${packageId}::staker_map_schema::get`,
    arguments: [
      txb.pure(world),
      txb.object(
        "0x57df671d8a7f6727407ae8d37d87c43b5dbeb3167a39aa6046e56f29b2598f39",
      ),
    ],
  });

  const res = await client.signAndExecuteTransactionBlock({
    transactionBlock: txb,
    signer: keypair,
    options: {
      showEffects: true,
      showBalanceChanges: true,
      showEvents: true,
      showInput: true,
      showObjectChanges: true,
      showRawInput: true,
    },
  });

  console.log(res);
}

main();
