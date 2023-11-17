import { SuiClient, getFullnodeUrl } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { hexToBytes } from "@noble/hashes/utils";
import "dotenv/config";
import { packageId, pool, world } from "./config";
import { drandChain, drandClient } from "./drand";
import { G2ChainedBeacon } from "drand-client";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";
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

async function main() {
  const beacon = (await drandClient.latest()) as G2ChainedBeacon;

  const txb = new TransactionBlock();

  txb.moveCall({
    target: `${packageId}::game_system::end_game`,
    arguments: [
      txb.pure(
        Array.from(new Uint8Array(Buffer.from(beacon.signature, "hex"))),
      ),
      txb.pure(
        Array.from(
          new Uint8Array(Buffer.from(beacon.previous_signature, "hex")),
        ),
      ),
      txb.pure(beacon.round),
      txb.object(SUI_CLOCK_OBJECT_ID),
      txb.object(pool),
      txb.object(world),
    ],
  });

  const res = await client.devInspectTransactionBlock({
    transactionBlock: txb,
    sender: address,
  });

  console.log(res);
}

main();
